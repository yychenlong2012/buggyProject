//
//  ImageEditVC.m
//  Buggy
//
//  Created by wuning on 16/5/10.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "ImageEditVC.h"
#import "UIView+Additions.h"
#import "UIImage+COSAdtions.h"
#import "UIImage+WaterMark.h"
#import "TagView.h"
#import "shareManager.h"
#import "ShareAnimationView.h"
//#import "HealthModel.h"
#import "BabyModel.h"
#import "WatermarkView.h"
#import "BabyInfoMarkView.h"

@interface ImageEditVC ()
{
    UIImage *_cutImage;
    UIAlertView *customAlertView;
    WatermarkView *_waterMarkView;
}
@property (nonatomic ,strong) BabyInfoMarkView *babyInfoMarkVeiw;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutFeatureWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutFeatureBottom;

@property (weak, nonatomic) IBOutlet UIView  *featureView;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation ImageEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imgView setImage:self.image];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightBarAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    for (UIView *view in self.buttons) {
        view.layer.borderWidth = 1;
        view.layer.borderColor = [UIColor whiteColor].CGColor;
        view.layer.cornerRadius = 3;
        view.layer.masksToBounds = YES;
    }
    
    self.featureView.hidden = YES;
//    self.heightLabel.text = [NSString stringWithFormat:@"%@%@",[HealthModel manager].height,@"cm"];
//    self.weightLabel.text = [NSString stringWithFormat:@"%@%@",[HealthModel manager].weight,@"kg"];
    NSDateFormatter *dateF = [[NSDateFormatter alloc]init];
    [dateF setDateFormat:@"yyyy年MM月dd日"];
    self.birthdayLabel.text = [self getAgeSince:[dateF dateFromString:[BabyModel manager].birthday]];
    self.heightLabel.adjustsFontSizeToFitWidth = YES;
    self.weightLabel.adjustsFontSizeToFitWidth = YES;
    self.birthdayLabel.adjustsFontSizeToFitWidth = YES;
    
    
    _waterMarkView = [[WatermarkView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, WatermarkViewHeight)];
    _waterMarkView.bottom = ScreenHeight - navigationH - bottomSafeH;
    [self.view addSubview:_waterMarkView];
    
    __weak typeof (self) wself = self;
    _waterMarkView.babyInfoBlock = ^(BOOL selected) {
        if (selected) {
            [wself onBabyInfo];    //宝宝信息
        }else{
            [wself.babyInfoMarkVeiw removeFromSuperview];
        }
    };
    _waterMarkView.waterblockBack = ^(NSInteger index) {   //标签
      
        switch (index) {
            case 0:
            {
                [wself onTag1];
            }
                break;
            case 1:
            {
                [wself onTag2];
            }
                break;
            case 2:
            {
                [wself onTag3];
            }
                break;
            case 3:
            {
                [wself onTagCustom];
            }
                break;
            default:
                break;
        }
    };
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

//    [self onFeature];
    
//    self.featureView.hidden = NO;
    
}

- (NSString *)getAgeSince:(NSDate *)date
{
    if (date == nil) {
        NSLog(@"ImageEditVC 132行");
        return @"";
    }
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:2];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    NSDate *fromDate = [dateFormatter dateFromString:@"2014-06-23 12:02:03"];
    NSDate *toDate = [NSDate date];
    NSDateComponents *dayComponents = [gregorian components:NSCalendarUnitDay fromDate:date toDate:toDate options:0];
    NSString *age = [NSString stringWithFormat:@"%ld",dayComponents.day];
    return age;
}

- (void)onFeature{
//    [self.featureView setTranslatesAutoresizingMaskIntoConstraints:YES];
    CGFloat setOffBottom;
    CGFloat featureWidth;
    if (self.imgView.width/self.imgView.height > self.image.size.width/self.image.size.height) {
        setOffBottom = 0;
        featureWidth = self.image.size.width/self.image.size.height*self.imgView.height;
    }else{
        featureWidth = self.imgView.width;
        setOffBottom = (self.imgView.height - self.imgView.width/(self.image.size.width/self.image.size.height))/2.0f;
    }
    self.layoutFeatureWidth.constant = featureWidth;
    self.layoutFeatureBottom.constant = setOffBottom;
    [self.view layoutIfNeeded];
    
    UIImage *maskImage = [UIImage imageWithUIView:self.featureView];
    maskImage = [maskImage getScaledImage:3.0];
    CGFloat subHeight = self.image.size.width * (maskImage.size.height / maskImage.size.width);
    CGRect rect = CGRectMake(0, self.image.size.height - subHeight, self.image.size.width, subHeight);
    _cutImage = [self.image imageWithWaterMask:maskImage inRect:rect];
}

- (void)onTag1{
    
    TagView *view = [TagView viewWithXib:@"TagView"];
    [view setText:NSLocalizedString(@"赞赞赞", nil)];
    [self.imgView.superview addSubview:view];
    view.userInteractionEnabled = YES;
    view.center = self.imgView.center;
    [self addGestureToView:view];
}

- (void)onTag2 {
    TagView *view = [TagView viewWithXib:@"TagView"];
    [view setText:NSLocalizedString(@"好可耐", nil)];
    [self.imgView.superview addSubview:view];
    view.center = CGPointMake(self.imgView.center.x + 30, self.imgView.center.y + 30);
    [self addGestureToView:view];
}


- (void)onTag3 {
    
    TagView *view = [TagView viewWithXib:@"TagView"];
    [view setText:NSLocalizedString(@"妈妈棒", nil)];
    [self.imgView.superview addSubview:view];
    view.center = CGPointMake(self.imgView.center.x + 30, self.imgView.center.y + 30);
    [self addGestureToView:view];
}

- (void)onBabyInfo {
    
    _babyInfoMarkVeiw = [[BabyInfoMarkView alloc] initWithFrame:CGRectMake(0, 0, BabyInfoMarkViewWeight, BabyInfoMarkViewWeight)];
//    NSString *height = [NSString stringWithFormat:@"%@%@",[HealthModel manager].height,@"cm"];
//    NSString *weight = [NSString stringWithFormat:@"%@%@",[HealthModel manager].weight,@"kg"];
    NSDateFormatter *dateF = [[NSDateFormatter alloc]init];
    [dateF setDateFormat:@"yyyy年MM月dd日"];
    NSString *day = [self getAgeSince:[dateF dateFromString:[BabyModel manager].birthday]];
//    [_babyInfoMarkVeiw setbabyDay:day height:height weight:weight];
    [self.imgView.superview addSubview:_babyInfoMarkVeiw];
    _babyInfoMarkVeiw.top  = 40;
    _babyInfoMarkVeiw.right = ScreenWidth - 20 * _MAIN_RATIO_375;
    _babyInfoMarkVeiw.tag = 10001;
    [self addGestureToView:_babyInfoMarkVeiw];
}


- (void)onTagCustom {
    if (customAlertView==nil) {
        customAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"编辑标签", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
        customAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    }
    UITextField *nameField = [customAlertView textFieldAtIndex:0];
    nameField.placeholder = NSLocalizedString(@"请输入标签内容", nil);
    [customAlertView show];
}

- (void)rightBarAction
{
    _cutImage = [self addMaskImage];
    ShareAnimationView *shareView = [[ShareAnimationView alloc]initWithTitleArray:@[NSLocalizedString(@"微信朋友圈", nil),
                                                                                NSLocalizedString(@"微信好友", nil),
                                                                                NSLocalizedString(@"QQ好友", nil),
                                                                                NSLocalizedString(@"新浪微博", nil)]
                                                                     picarray:@[@"friend",@"wechat",@"QQ",@"sina"]];
    [shareView show];
    [shareView shareWithBlock:^(NSInteger index) {
        
        switch (index) {
            case 1:
            {
                [shareManager shareToWeChatMoment:self->_cutImage];
            }
                break;
            case 2:
            {
                [shareManager shareToWeChatFriends:self->_cutImage];
            }
                break;
            case 3:
            {
                [shareManager shareToQQFriends:self->_cutImage];
            }
                break;
            case 4:
            {
                [shareManager shareToWeibo:self->_cutImage];
            }
                break;
            default:
                break;
        }
    }];
    DLog(@"");
}

- (UIImage *)addMaskImage
{
    UIImage *baseImage = [UIImage imageWithUIView:self.imgView.superview];
    CGRect imgRect = [UIImage getFrameSizeForImage:self.image inImageView:self.imgView];
    imgRect = CGRectMake(imgRect.origin.x * 2, imgRect.origin.y * 2, imgRect.size.width * 2, imgRect.size.height * 2);
    _cutImage = [baseImage getSubImage:imgRect];
    UIImageWriteToSavedPhotosAlbum(_cutImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    return _cutImage;
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = NSLocalizedString(@"保存图片失败", nil) ;
    }else{
        msg = NSLocalizedString(@"保存图片成功", nil) ;
    }
    [MBProgressHUD showToast:msg];
    
}

- (void)panTagView:(UIPanGestureRecognizer *)gr
{
    UIView *view = gr.view;
    if (gr.state == UIGestureRecognizerStateBegan || gr.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gr translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [gr setTranslation:CGPointZero inView:view.superview];
    }
}
- (void)tapView:(UIPanGestureRecognizer *)gr
{
    TagView *view = (TagView *)gr.view;
    [AYMessage showEditViewWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"编辑标签", nil) okButtonTitle:NSLocalizedString(@"确定", nil) ClickedButton:^(NSInteger buttonIndex ,NSString *text) {
        if (buttonIndex == 0) {
            if (text.length == 0) {
                [AYMessage  show:NSLocalizedString(@"编辑内容不能为空", nil) onView:self.view autoHidden:YES];
            }else{
                [view setText:text];
            }
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        UITextField *nameField = [alertView textFieldAtIndex:0];
        TagView *view = [TagView viewWithXib:@"TagView"];
        [view setText:nameField.text];
        [self.imgView.superview addSubview:view];
        view.center = CGPointMake(self.imgView.center.x + 50, self.imgView.center.y + 50);
       [self addGestureToView:view];
        nameField.text = @"";
        //TODO
    }
}

- (void)addGestureToView:(UIView *)view {
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panTagView:)];
    panGR.maximumNumberOfTouches = 1;
    panGR.minimumNumberOfTouches = 1;
    [view addGestureRecognizer:panGR];
    if (view.tag != 10001) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        [view addGestureRecognizer:tap];
    }
    __weak typeof(view) newView = view;
    [view addLongPressActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [newView removeFromSuperview];
    }];
}
@end
