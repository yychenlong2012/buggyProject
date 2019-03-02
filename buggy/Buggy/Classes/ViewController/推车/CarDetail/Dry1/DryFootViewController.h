//
//  DryFootViewController.h
//  Buggy
//
//  Created by goat on 2019/2/25.
//  Copyright © 2019 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DryFootViewController : UIViewController
@property (nonatomic,strong) NSString *peripheralUUID;   //设备UUID
@property (nonatomic,strong) NSString *deviceName;       //界面导航栏名字
@end

NS_ASSUME_NONNULL_END
