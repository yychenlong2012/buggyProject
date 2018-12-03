//
//  AlertManager.m
//  Buggy
//
//  Created by 孟德林 on 2017/6/2.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "AlertManager.h"

static const NSInteger viewWidth = 290;   // 提示的宽度
static const NSInteger cancleHeight = 45; // 取消的高度

static const NSInteger ListViewWidth = 300; // 功能的宽度
static const NSInteger ListCellHieght = 50; // 单个功能的高度

@interface AlertManager()

@property (nonatomic ,strong) UIView *bgView;
@property (nonatomic ,strong) UIView *view;
@end

@implementation AlertManager

- (void)showAlertMessage:(NSString *)message title:(NSString *)title cancle:(NSString *)cancle confirm:(NSString *)confirm others:(NSArray<NSString *> *)others{
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    bgView.backgroundColor = [COLOR_HEXSTRING(@"#000000") colorWithAlphaComponent:0.4];

    bgView.tag = 1081;
    self.bgView = bgView;
    
    UIView *view = [self alertMessage:message title:title cancle:cancle confirm:confirm others:others];
    view.center = bgView.center;
    view.alpha = 0;
    self.view = view;
    
    
}
- (void)show{
    [self.bgView addSubview:self.view];
    __weak typeof(self) wself = self;
    UIWindow *key = [AlertManager keyWindow];
    [UIView animateWithDuration:0.5 animations:^{
        wself.view.alpha = 1;
        [key addSubview:wself.bgView];
    }];
}

- (void)dismiss{
    for (UIView *view in [AlertManager keyWindow].subviews) {
        if (view.tag == 1081) {
            [UIView animateWithDuration:0.5 animations:^{
                view.alpha = 1;
                [view removeFromSuperview];
            }];
        }
        if (view.tag == 1082) {
            [UIView animateWithDuration:0.5 animations:^{
                view.alpha = 1;
                [view removeFromSuperview];
            }];
        }
    }
}

+ (UIWindow *)keyWindow{
    return [UIApplication sharedApplication].keyWindow;
}

- (UIView *)alertMessage:(NSString *)message title:(NSString *)title cancle:(NSString *)cancle confirm:(NSString *)confirm others:(NSArray<NSString *> *)others{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth , 0)];
    view.centerX = ScreenWidth /2;
    view.clipsToBounds = YES;
    view.layer.cornerRadius = 10;
    view.backgroundColor = [UIColor whiteColor];
    float viewHeight = 10;
    
    // 标题
    CGFloat titleLBHeight = [self calculateRowHeight:title fontSize:16 width:viewWidth/2];
    UILabel *titleLB = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight, viewWidth/2, titleLBHeight)];
    titleLB.centerX = viewWidth/2;
    titleLB.top = viewHeight;
    titleLB.text = title;
    titleLB.textAlignment = NSTextAlignmentCenter;
    viewHeight += titleLBHeight + 20;
    view.height = viewHeight;
    [view addSubview:titleLB];
    
    // 内容
    CGFloat messageLBHeight = [self calculateRowHeight:message fontSize:16 width:viewWidth * 0.8];
    UILabel *messageLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewWidth * 0.8, messageLBHeight)];
    messageLB.centerX = viewWidth/2;
    messageLB.top = viewHeight + 5;
    messageLB.text = message;
    messageLB.textAlignment = NSTextAlignmentCenter;
    messageLB.font = FONT_DEFAULT_Light(16);
    messageLB.textColor = COLOR_HEXSTRING(@"#333333");
    messageLB.adjustsFontSizeToFitWidth = YES;
    messageLB.numberOfLines = 0;
    viewHeight += messageLBHeight + 30;
    view.height = viewHeight;
    [view addSubview:messageLB];
    
    // 顶部分割线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight, viewWidth, 0.5)];
    topLine.backgroundColor = COLOR_HEXSTRING(@"#ECECEC");
    viewHeight += topLine.height;
    view.height = viewHeight;
    [view addSubview:topLine];
    
    
    // 操作标题
    if (cancle && confirm) {
        
        // 左标题
        UILabel *cancleLB = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight + 0.5, viewWidth / 2, cancleHeight)];
        viewHeight += cancleLB.height + 0.5;
        cancleLB.font = FONT_DEFAULT_Light(16);
        cancleLB.text = cancle;
        cancleLB.adjustsFontSizeToFitWidth = YES;
        cancleLB.textAlignment = NSTextAlignmentCenter;
        cancleLB.textColor = COLOR_HEXSTRING(@"#333333");
        view.height = viewHeight;
        [view addSubview:cancleLB];
        
//        UIButton *cancleBt = [self eventFactory:CGRectMake(0, cancleLB.top, viewWidth / 2, cancleHeight) cancle:YES];
//        [view addSubview:cancleBt];
//        __weak typeof (self) wself = self;
        [Factory buttonEmptyWithFrame:CGRectMake(0, cancleLB.top, viewWidth / 2, cancleHeight) click:^{
            
            self.indexBlock(0);
            [self dismiss];
            
        } onView:view];
        
        // 中间分割线
        UIView *centerLine = [[UIView alloc] initWithFrame:CGRectMake(0, cancleLB.top, 0.5, cancleHeight)];
        centerLine.centerX = viewWidth/2;
        centerLine.backgroundColor = COLOR_HEXSTRING(@"#ECECEC");
        [view addSubview:centerLine];
        
        // 右标题
        UILabel *confirmOne = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth/2 + 0.5, cancleLB.top, viewWidth / 2, cancleHeight)];
        confirmOne.font = FONT_DEFAULT_Light(16);
        confirmOne.adjustsFontSizeToFitWidth = YES;
        confirmOne.textColor = COLOR_HEXSTRING(@"#F47686");
        confirmOne.text = confirm;
        confirmOne.textAlignment = NSTextAlignmentCenter;
        [view addSubview:confirmOne];
        
//        UIButton *confirmOneBt = [self eventFactory:CGRectMake(viewWidth/2 + 0.5, cancleLB.top, viewWidth / 2, cancleHeight) cancle:NO];
//        [view addSubview:confirmOneBt];
        [Factory buttonEmptyWithFrame:CGRectMake(viewWidth/2 + 0.5, cancleLB.top, viewWidth / 2, cancleHeight) click:^{
            [self dismiss];
            self.indexBlock(1);
        } onView:view];
        
    }else if (cancle && !confirm){
        
        UILabel *cancleLB = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight + 0.5, viewWidth, cancleHeight)];
        viewHeight += cancleLB.height + 0.5;
        cancleLB.font = FONT_DEFAULT_Light(16);
        cancleLB.adjustsFontSizeToFitWidth = YES;
        cancleLB.text = cancle;
        cancleLB.textAlignment = NSTextAlignmentCenter;
        cancleLB.textColor = COLOR_HEXSTRING(@"#333333");
        view.height = viewHeight;
        [view addSubview:cancleLB];
        
//        UIButton *cancleBt = [self eventFactory:CGRectMake(0, viewHeight + 0.5, viewWidth, cancleHeight) cancle:YES];
//        [view addSubview:cancleBt];
        
        [Factory buttonEmptyWithFrame:CGRectMake(0, viewHeight + 0.5, viewWidth, cancleHeight) click:^{
            [self dismiss];
            self.indexBlock(0);
        } onView:view];

        
    }else if (!cancle && confirm){
        
        UILabel *confirmOne = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight + 0.5, viewWidth, cancleHeight)];
        viewHeight += confirmOne.height + 0.5;
        confirmOne.font = FONT_DEFAULT_Light(16);
        confirmOne.text = confirm;
        confirmOne.adjustsFontSizeToFitWidth = YES;
        confirmOne.textColor = COLOR_HEXSTRING(@"#333333");
        confirmOne.textAlignment = NSTextAlignmentCenter;
        view.height = viewHeight;
        [view addSubview:confirmOne];
        
//        UIButton *confirmOneBt = [self eventFactory:CGRectMake(0, viewHeight + 0.5, viewWidth, cancleHeight) cancle:NO];
//        [view addSubview:confirmOneBt];
        [Factory buttonEmptyWithFrame:CGRectMake(0, viewHeight + 0.5, viewWidth, cancleHeight) click:^{
            [self dismiss];
            self.indexBlock(1);
        } onView:view];
        
    }
    
//    if (others.count > 0) {
//        for (NSString *str in others) {
//
//        }
//    }
    
    view.height = viewHeight;
    return view;
    
}
- (UIButton *)eventFactory:(CGRect )rect cancle:(BOOL)cancle{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor purpleColor];
    button.frame = rect;
    if (cancle) {
        [button addTarget:self action:@selector(cancleButton:) forControlEvents:UIControlEventTouchUpInside];
        return button;
    }
    [button addTarget:self action:@selector(confirmButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)cancleButton:(UIButton *)button{
    
    [self dismiss];
    if (self.indexBlock) {
        self.indexBlock(0);
    }
}

- (void)confirmButton:(UIButton *)button{
    
    if (self.indexBlock) {
        self.indexBlock(1);
    }
}

/*计算宽度时要确定高度*/

- (CGFloat)calculateRowWidth:(NSString *)string height:(float)height{
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};  //指定字号
    CGRect rect = [string boundingRectWithSize:CGSizeMake(0, height) options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:dic context:nil];
    return rect.size.width;
}

/*计算高度要先指定宽度*/
- (CGFloat)calculateRowHeight:(NSString *)string fontSize:(NSInteger)fontSize width:(float)width{
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};//指定字号
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:dic context:nil];
    return rect.size.height;
}


#pragma mark --- 功能列表


- (void)showFunctionList:(NSArray *)imageList titleList:(NSArray *)titleList IndexBlock:(IndexBlock)index{
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    bgView.backgroundColor = [COLOR_HEXSTRING(@"#000000") colorWithAlphaComponent:0.25];
    bgView.tag = 1082;
    [bgView addTapGestureRecognizer:^(UITapGestureRecognizer *recognizer, NSString *gestureId) {
        [self dismiss];
    } tapGestureId:@""];
    self.bgView = bgView;
    
    UIView *view = [self functionList:imageList titleList:titleList IndexBlock:index];
    view.alpha = 0;
    self.view = view;
}

- (UIView *)functionList:(NSArray *)imageList titleList:(NSArray *)titleList IndexBlock:(IndexBlock)index{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, _NAV_HEIGHT + 10, viewWidth , titleList.count * ListCellHieght)];
    view.centerX = ScreenWidth /2;
    view.clipsToBounds = YES;
    view.layer.cornerRadius = 10;
    view.backgroundColor = [UIColor whiteColor];
    if (imageList.count > 0) {
        for (NSInteger i =0; i < imageList.count;i ++) {
            UIButton *button = [Factory buttonWithFrame:CGRectMake(0, i * ListCellHieght + (i > 0? 1 : 0), ListViewWidth, ListCellHieght) withImageName:imageList[i] click:^{
                [self dismiss];
                if (index) {
                    index(i);
                }
            } onView:view];
            [button setTitle:titleList[i] forState:UIControlStateNormal];
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, -15)];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft; // 设置文字位置，现设为居左，默认的是居右
            [button setTitleColor:COLOR_HEXSTRING(@"#333333") forState:UIControlStateNormal];
            //对一键修复做特殊处理 如果开启了一键防盗功能 那么关闭一键修复功能
            NSString *title = titleList[i];
            if ([title containsString:@"一键修复"]) {
                if (self.isGuardOpen) {
                    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                }else{
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }
            if ([title containsString:@"固件"] && self.haveNewVersion == YES) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(view.bounds.size.width - 50, 0, 35, 17)];
                label.centerY = button.centerY;
                label.text = @"NEW";
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = [UIColor whiteColor];
                label.backgroundColor = [UIColor colorWithHexString:@"#F47686"];
                label.font = [UIFont systemFontOfSize:12];
                label.layer.cornerRadius = 3;
                label.layer.masksToBounds = YES;
                [view addSubview:label];
            }
            [Factory viewWithFrame:CGRectMake(0, button.bottom, ListViewWidth, (i == imageList.count - 1 ? 0 : 1)) bgColor:COLOR_HEXSTRING(@"#ECECEC") onView:view];
        }
    }else{
        
        for (NSInteger i =0; i < titleList.count;i ++) {
            UIButton *button = [Factory buttonWithFrame:CGRectMake(0, i * ListCellHieght + (i > 0? 1 : 0), ListViewWidth, ListCellHieght) withImageName:nil click:^{
                [self dismiss];
                if (index) {
                    index(i);
                }
            } onView:view];
            [button setTitle:titleList[i] forState:UIControlStateNormal];
            [button setTitleColor:COLOR_HEXSTRING(@"#333333") forState:UIControlStateNormal];
            [Factory viewWithFrame:CGRectMake(0, button.bottom, ListViewWidth, (i == imageList.count - 1 ? 0 : 1)) bgColor:COLOR_HEXSTRING(@"#ECECEC") onView:view];
        }
    }
    return view;
}

@end
