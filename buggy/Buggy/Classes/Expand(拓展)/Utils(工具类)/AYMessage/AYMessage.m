//
//  AYMessage.m
//
//  Created by Dandre on 16/3/22.
//  Copyright © 2016年 Dandre. All rights reserved.
//

#import "AYMessage.h"

@implementation AYMessage

static AYMessage *yfMsg = nil;
+ (AYMessage *)shareMessage
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        yfMsg = [[AYMessage alloc] init];
        yfMsg.hudView = [[MBProgressHUD alloc] init];
        
        UIImageView *imageView = [AYView createImageViewFrame:CGRectMake(0, 0, 0, 0)
                                                    imageName:nil
                                                  isUIEnabled:NO];
        imageView.tag = 0x10000;
        UILabel *tipLabel = [AYView createLabelWithFrame:CGRectMake(0, 0, 0, 0)
                                                    text:nil
                                               TextAlign:center
                                                 bgColor:nil
                                                fontSize:16
                                                  radius:0];
        tipLabel.tag = 0x10001;
        tipLabel.textColor = [UIColor colorWithWhite:200/255.0 alpha:1];
        tipLabel.numberOfLines = 0;
        yfMsg.noContentTipView = [AYView createViewWithFrame:CGRectMake(0, 0, 0, 0)
                                                     bgColor:[UIColor clearColor]
                                                      radius:0];
        yfMsg.noContentTipView.userInteractionEnabled = NO;
        [yfMsg.noContentTipView addSubview:imageView];
        [yfMsg.noContentTipView addSubview:tipLabel];
    });
    
    return yfMsg;
}

/**
 *  提示框
 *
 *  @param message 提示的内容
 */
+ (void)alert:(NSString *)massage
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:massage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

/**
 *  提示框
 *
 *  @param message 提示的内容
 */
+ (void)show:(NSString *)massage title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:massage delegate:nil cancelButtonTitle:YFCulture(@"确定") otherButtonTitles:nil, nil];
    [alert show];
}

/**
 *  提示框
 *
 *  @param message 提示的内容
 */
+ (void)show:(id)message
{
    [self alert:[NSString stringWithFormat:@"%@",message]];
}

/**
 *  提示框
 *
 *  @param message 提示的内容
 */
- (void)show:(id)message okTitle:(NSString *)title Clicked:(AlertButtonClickedBlock)block
{
    _block = block;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:YFCulture(@"温馨提示") message:[NSString stringWithFormat:@"%@",message] delegate:self cancelButtonTitle:title otherButtonTitles:title == nil?YFCulture(@"确定"):YFCulture(@"取消"), nil];
    alert.delegate = self;
    [alert show];
}

/**
 *  提示框
 *
 *  @param message 提示的内容
 */
- (void)show:(id)message tipTitle:(NSString *)tipTitle okTitle:(NSString *)okTitle Clicked:(AlertButtonClickedBlock)block
{
    _block = block;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:tipTitle message:[NSString stringWithFormat:@"%@",message] delegate:self cancelButtonTitle:okTitle otherButtonTitles:okTitle == nil?YFCulture(@"确定"):YFCulture(@"取消"), nil];
    alert.delegate = self;
    [alert show];
}

/**
 *  提示框
 *
 *  @param message 提示的内容
 */
- (void)show:(id)message tipTitle:(NSString *)tipTitle oneTitle:(NSString *)okTitle Clicked:(AlertButtonClickedBlock)block
{
    _block = block;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:tipTitle message:[NSString stringWithFormat:@"%@",message] delegate:self cancelButtonTitle:okTitle==nil?YFCulture(@"确定"):okTitle otherButtonTitles:nil, nil];
    alert.delegate = self;
    [alert show];
}

/**
 *  提示框
 *
 *  @param message 提示的内容
 *  @param title  确定按钮现实的文字
 */
+ (void)show:(id)message okTitle:(NSString *)title Clicked:(AlertButtonClickedBlock)block
{
    [[AYMessage shareMessage] show:message okTitle:title Clicked:block];
}

/**
 *  提示框
 *
 *  @param tipTitle 提示的标题
 *  @param message  提示的内容
 *  @param okTitle  确定按钮现实的文字
 */
+ (void)show:(id)message tipTitle:(NSString *)tipTitle okTitle:(NSString *)okTitle Clicked:(AlertButtonClickedBlock)block
{
    [[AYMessage shareMessage] show:message tipTitle:tipTitle okTitle:okTitle Clicked:block];
}

/**
 *  可以自动隐藏的提示
 *
 *  @param message 提示的内容
 *  @param view    提示视图要显示在的视图
 *  @param flag    是否自动隐藏
 */
+ (void)show:(id)message
      onView:(UIView *)view
  autoHidden:(BOOL)flag {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.customView = [[UIImageView alloc] initWithImage:nil];
    HUD.labelText = message;
    
    [HUD show:YES];
    if (flag) {
        [HUD hide:YES afterDelay:1];
    }
    [AYMessage shareMessage].hudView = HUD;
}

/**
 *  创建并显示小菊花
 *
 *  @param view 显示所在的视图
 */
+ (void)showActiveViewOnView:(UIView *)view
{
    [AYMessage showActiveViewWithTipString:YFCulture(@"加载中...") onView:view];
}

/**
 *  创建并显示小菊花
 *
 *  @param tipString 提示的文字
 *  @param view      显示所在的视图
 */
+ (void)showActiveViewWithTipString:(NSString *)tipString onView:(UIView *)view
{
    if ([AYMessage shareMessage].hudView == nil) {
        [AYMessage shareMessage].hudView = [[MBProgressHUD alloc] init];
    }
    
    [view addSubview:[AYMessage shareMessage].hudView];
    [AYMessage shareMessage].hudView.mode = MBProgressHUDModeIndeterminate;
    [AYMessage shareMessage].hudView.labelText = tipString;
    [[AYMessage shareMessage].hudView show:YES];
    
    [[AYMessage shareMessage].hudView hide:YES afterDelay:20];
}

+ (void)showActiveViewMessage:(NSString *)tipString onView:(UIView *)view
{
    if ([AYMessage shareMessage].hudView == nil) {
        [AYMessage shareMessage].hudView = [[MBProgressHUD alloc] init];
    }

    [view addSubview:[AYMessage shareMessage].hudView];
    [AYMessage shareMessage].hudView.mode = MBProgressHUDModeIndeterminate;
    [AYMessage shareMessage].hudView.labelText = tipString;
    [[AYMessage shareMessage].hudView show:YES];
}

/**
 *  隐藏小菊花
 */
+ (void)hideActiveView
{
    [[AYMessage shareMessage].hudView hide:YES];
}

/**
 *  显示无内容提示
 *
 *  @param message 提示的文字
 *  @param image   显示的图片
 *  @param view    显示所在的视图
 */
+ (UIView *)showNoContentTip:(NSString *)message image:(NSString *)image onView:(UIView *)view viewClick:(ViewClick)viewClick
{
    
    if ([AYMessage shareMessage].noContentTipView == nil) {
        UIImageView *imageView = [AYView createImageViewFrame:CGRectMake(0, 0, 0, 0)
                                                    imageName:nil
                                                  isUIEnabled:NO];
        imageView.tag = 0x10000;
        UILabel *tipLabel = [AYView createLabelWithFrame:CGRectMake(0, 0, 0, 0)
                                                    text:nil
                                               TextAlign:center
                                                 bgColor:nil
                                                fontSize:16
                                                  radius:0];
        tipLabel.tag = 0x10001;
        tipLabel.textColor = [UIColor colorWithWhite:200/255.0 alpha:1];
        tipLabel.numberOfLines = 0;
        [AYMessage shareMessage].noContentTipView = [AYView createViewWithFrame:CGRectMake(0, 0, 0, 0)
                                                     bgColor:[UIColor clearColor]
                                                      radius:0];
        [AYMessage shareMessage].noContentTipView.userInteractionEnabled = NO;
        [[AYMessage shareMessage].noContentTipView addSubview:imageView];
        [[AYMessage shareMessage].noContentTipView addSubview:tipLabel];
    }
    [AYMessage shareMessage].noContentTipView.frame = CGRectMake(0, view.frame.size.height/2-180, view.frame.size.width, 210);
    UIImageView *imageView = [[AYMessage shareMessage].noContentTipView viewWithTag:0x10000];
    imageView.image = [UIImage imageNamed:image];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.userInteractionEnabled = YES;
    [[AYMessage shareMessage].noContentTipView setUserInteractionEnabled:YES];
    CGFloat cFloat = [AYMessage shareMessage].noContentTipView.height *0.25;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo([AYMessage shareMessage].noContentTipView).multipliedBy(1);
        make.height.equalTo([AYMessage shareMessage].noContentTipView).multipliedBy(1);
        make.centerY.equalTo([AYMessage shareMessage].noContentTipView).offset(-cFloat);
        make.centerX.equalTo([AYMessage shareMessage].noContentTipView);
        
    }];
    UITapGestureRecognizer *tapClick = [[UITapGestureRecognizer alloc] initWithTarget:[AYMessage shareMessage] action:@selector(tapsClick:)];
    [[AYMessage shareMessage].noContentTipView addGestureRecognizer:tapClick];
    UILabel *label = [[AYMessage shareMessage].noContentTipView viewWithTag:0x10001];
    label.text = message;
    label.numberOfLines = 0;
    [view addSubview:[AYMessage shareMessage].noContentTipView];
    [label setFont:[UIFont systemFontOfSize:17]];
    label.textColor = KHexRGB(0x999999);
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:message];
    label.attributedText = attrStr;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(ScreenWidth-40));
        make.top.equalTo(imageView.mas_bottom).offset(cFloat);
        make.centerX.equalTo(imageView);
    }];
    [AYMessage shareMessage].noContentTipView.hidden = NO;
    [AYMessage shareMessage].viewblock = viewClick;
    return [AYMessage shareMessage].noContentTipView;
}

- (void)tapsClick:(UIGestureRecognizer *)get{
    
    [AYMessage shareMessage].viewblock();
}
/**
 *  隐藏无内容提示视图
 */
+ (void)hideNoContentTipView
{
    [AYMessage shareMessage].noContentTipView.hidden = YES;
}

/**
 *  显示带文本框的AlertView
 */
+ (UIAlertView *)showEditViewWithTitle:(NSString *)title
                      message:(NSString *)msg
                okButtonTitle:(NSString *)okTitle
                ClickedButton:(AlertButtonClickedTextBlock)block
{
   return [[AYMessage shareMessage] showEditViewWithTitle:title message:msg okButtonTitle:okTitle ClickedButton:block];
}

- (UIAlertView *)showEditViewWithTitle:(NSString *)title
                      message:(NSString *)msg
                okButtonTitle:(NSString *)okTitle
                ClickedButton:(AlertButtonClickedTextBlock)block
{
    _textBolck = block;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:YFCulture(msg)
                                                   delegate:self
                                          cancelButtonTitle:okTitle
                                          otherButtonTitles:okTitle == nil?YFCulture(@"确定"):YFCulture(@"取消"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    alert.tag = 10001;
    [alert show];
    return alert;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10001) {
        if (_textBolck) {
            NSString *text = [alertView textFieldAtIndex:0].text;
            _textBolck(buttonIndex,text);
        }
    }else{
        if (_block) {
        _block(buttonIndex);
        }
    }
}

+ (void)show:(id)message
       image:(UIImage *)image
    delegate:(__kindof UIViewController *)viewController
  autoHidden:(BOOL)autoHidden
{
    [[AYMessage shareMessage] showHUD:message image:image delegate:viewController autoHidden:autoHidden];
}

- (void)showHUD:(id)message
          image:(UIImage *)image
       delegate:(__kindof UIViewController *)viewController
     autoHidden:(BOOL)autoHidden
{
    MBProgressHUD *HUD;
    if (viewController!=nil) {
       HUD = [[MBProgressHUD alloc] initWithView:viewController.view];
    }else{
       HUD = [[MBProgressHUD alloc] initWithView:kWindow];
    }
    [viewController.view addSubview:HUD];
    HUD.delegate = viewController;
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.customView = [[UIImageView alloc] initWithImage:image];
    HUD.labelText = message;
    
    [HUD show:YES];
    if (autoHidden) {
        [HUD hide:YES afterDelay:1];
    }
    self.hudView = HUD;
}



@end
