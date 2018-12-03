//
//  AlertActionSheetMgr.h
//  carcareIOS
//
//  Created by wr on 16/3/14.
//  Copyright © 2016年 chezheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ALERTACTIONSHEETMGR [AlertActionSheetMgr sharedInstance]

typedef NS_ENUM(NSInteger , TYPE_ALERTVC) {
    TYPE_ALERTVC_ALERT = 888,//类型为alert
    TYPE_ALERTVC_ACTIONSHEET,//类型为ActionSheet
};
typedef NS_ENUM(NSInteger , TYPE_ALERTBTN) {
    TYPE_ALERTBTN_NONE = 88,//alert的按钮类型为常规的
    TYPE_ALERTBTN_RED,//alert的按钮类型为红色的
};
typedef void(^ClickIndexBlock)(NSInteger index);

@interface AlertActionSheetMgr : NSObject

DEF_SINGLETON

/**
    创建alert或actionsheet vc为所创建的对象 title标题 message信息 cancelTitle取消按钮标题 redBtnTitle对于actionsheet是红色按钮标题 otherBtnTitle其他按钮标题 clickIndexBlock按钮回调事件
 */
- (void)createFromVC:(UIViewController *)vc withAlertType:(TYPE_ALERTVC)alertVCType withTitle:(NSString *)title withMessage:(NSString *)message withCanCelTitle:(NSString *)cancelTitle withRedBtnTitle:(NSString * )redBtnTitle withOtherBtnTitle:(NSString *)otherBtnTitle clickIndexBlock:(ClickIndexBlock)clickIndexBlock;

/**
    添加按钮 用来添加alert或actionSheet的按钮 btnTitle按钮标题 btnType按钮的类型 buttonIndex按照添加了n个button 输入坐标为（n－1） 对于iOS8以下有问题
 */
//- (void)addButtonTitle:(NSString *)btnTitle buttonStyle:(TYPE_ALERTBTN)btnType buttonIndex:(NSInteger)buttonIndex;

@end
