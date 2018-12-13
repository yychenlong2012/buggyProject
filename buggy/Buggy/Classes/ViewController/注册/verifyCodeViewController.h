//
//  verifyCodeViewController.h
//  Buggy
//
//  Created by goat on 2018/12/12.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    REGISTER_TYPE = 0,            // 注册
    RESET_PASSWORD_TYPE,          // 重置密码
    BAND_PHONE_TYPE               // 绑定手机
} VERIFY_CODE_TYPE;      //操作类型

NS_ASSUME_NONNULL_BEGIN

@interface verifyCodeViewController : UIViewController

@property (nonatomic,assign) VERIFY_CODE_TYPE verifyType;   //是否为注册

@end

NS_ASSUME_NONNULL_END
