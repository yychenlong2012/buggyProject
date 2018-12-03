//
//  FeedBackViewController.m
//  Buggy
//
//  Created by 孟德林 on 16/9/14.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "FeedBackViewController.h"
#import "CostomFactory.h"
#import "NSString+Bool.h"
#import "CLImageView.h"
#define SIDE_GAP 20
@interface FeedBackViewController ()<UITextViewDelegate>
@property (nonatomic ,strong) UITextView *textView;
@property (nonatomic ,strong) UIButton *sendBT;
@property (nonatomic ,strong) UILabel  *tipsLabel;
@property (nonatomic,strong) UIView *naviView;             //自定义导航栏背景view

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.naviView];
    self.title = NSLocalizedString(@"用户反馈", nil);
    [self.view addSubview:self.sendBT];
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.textView];
    self.tipsLabel.bottom = self.sendBT.top - 10;
    self.textView.height = self.tipsLabel.top - SIDE_GAP - 20;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc{
    NSLog(@"111");
}

- (void)sendMessage{
    if ([Check isNoNull:self.textView.text]) {
        [self.view endEditing:YES];
        [self initLoading];
        __weak typeof(self) wself = self;
        // 将反馈数据传送到数据
        [NETWorkAPI userFeedBackWithMsg:self.textView.text callback:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [wself stopLoading];
                [MBProgressHUD showToast:NSLocalizedString(@"信息反馈成功",nil)];
                [wself.navigationController popViewControllerAnimated:YES];
            }else{
                [wself stopLoading];
                [MBProgressHUD showToast:NSLocalizedString(@"信息反馈失败，请稍后再试！", nil)];
            }
        }];
//        [FeedBackManager feedBackWithSomeThings:self.textView.text success:^(BOOL sucess) {
//            if (sucess) {
//                [wself stopLoading];
//                [MBProgressHUD showToast:NSLocalizedString(@"信息反馈成功",nil)];
//                [wself.navigationController popViewControllerAnimated:YES];
//            }
//        } faile:^(NSError *faile) {
//            [wself stopLoading];
//            [MBProgressHUD showToast:NSLocalizedString(@"信息反馈失败，请稍后再试！", nil)];
//        }];
    }else{
         [MBProgressHUD showToast:NSLocalizedString(@"你还没有发表任何意见哦！", nil)];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL hasNull = NO;
    if (![text isNotNil] && textView.text.length <= 1) {
        hasNull = YES;
    }
    self.sendBT.enabled = !hasNull;
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        [self.view endEditing:YES];
        [self sendMessage];
        return NO;                     //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}

#pragma mark - keyboard
- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveViewWhenKeyBoardChangeToHeight:0 WithDuiation:animationDuration];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self moveViewWhenKeyBoardChangeToHeight:CGRectGetHeight(keyboardRect) WithDuiation:animationDuration];
}

-(void)moveViewWhenKeyBoardChangeToHeight:(CGFloat)height WithDuiation:(NSTimeInterval)duration{
    [UIView animateWithDuration:duration animations:^{
        if (__SCREEN_IS_3_5) {
            CGFloat newH = height;
            if (height > 0) {
                newH = height - 100;
            }
//            self.scrollView.contentSize = CGSizeMake(ScreenWidth, _MAIN_HEIGHT_64 + newH);
            self.sendBT.bottom = _MAIN_HEIGHT_64 - ((newH == 0) ? 30 : newH + 10);
            self.tipsLabel.bottom = self.sendBT.top - 10;
            self.textView.height = self.tipsLabel.top - SIDE_GAP - 20;
            
        }else{
            self.sendBT.bottom = _MAIN_HEIGHT_64 - ((height == 0) ? 30 : height + 10);
            self.tipsLabel.bottom = self.sendBT.top - 10;
            self.textView.height = self.tipsLabel.top - SIDE_GAP - 20;
        }
    }];
}

#pragma mark --- setter and getter
- (UIButton *)sendBT{
    if (_sendBT == nil) {
        __weak typeof(self) wself = self;
        _sendBT = [CostomFactory normalButtonWithFrame:FactoryRectButtonDefault(ScreenHeight - navigationH - BOTTOM_SIDE) title:NSLocalizedString(@"发送", nil) inView:self.view action:^{
            [wself sendMessage];
        }];
    }
    return _sendBT;
}
-(UILabel *)tipsLabel{
    
    if (_tipsLabel == nil) {
        _tipsLabel = [Factory labelWithFrame:CGRectMake(0, self.textView.bottom, self.view.width, 40) font:FONT_DEFAULT_Light(12) text:NSLocalizedString(@"感谢你提出的宝贵意见,我们会尽快改善。", nil) textColor:[UIColor lightGrayColor] onView:self.view textAlignment:NSTextAlignmentCenter];
//        _tipsLabel.bottom = self.sendBT.top - 10;
    }
    return _tipsLabel;
}

-(UITextView *)textView{
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(SIDE_GAP, navigationH+SIDE_GAP, self.view.width - 2 * SIDE_GAP, 200)];
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.font = FONT_DEFAULT_Light(14);
        [_textView becomeFirstResponder];
//        _textView.height = self.tipsLabel.top - SIDE_GAP - 20;
    }
    return _textView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *)naviView{
    if (_naviView == nil) {
        _naviView = [[UIView alloc] init];
        _naviView.frame = CGRectMake(0, 0, ScreenWidth, 44+statusBarH);
        _naviView.backgroundColor = [UIColor colorWithHexString:@"#E04E63"];
        
        CLImageView *naviBackImage = [[CLImageView alloc] init];
        naviBackImage.image = [UIImage imageNamed:@"navi_white_icon"];
        naviBackImage.frame = CGRectMake(15, 13+statusBarH, 20, 20);
        naviBackImage.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [naviBackImage addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [wself.navigationController popViewControllerAnimated:YES];
        }];
        [_naviView addSubview:naviBackImage];
        
        UILabel *naviLabel = [[UILabel alloc] init];
        naviLabel.textColor = kWhiteColor;
        naviLabel.text = NSLocalizedString(@"问题反馈", nil);
        naviLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        naviLabel.textAlignment = NSTextAlignmentCenter;
        naviLabel.frame = CGRectMake((ScreenWidth-200)/2, 13+statusBarH, 200, 18);
        [_naviView addSubview:naviLabel];
    }
    return _naviView;
}

#pragma mark - 隐藏导航栏状态栏
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:NO];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
@end
