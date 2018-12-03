//
//  moreOperationsView.h
//  Buggy
//
//  Created by goat on 2018/5/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface moreOperationsView : UIView
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceName;

@property (weak,nonatomic) DeviceModel *device;
@end
