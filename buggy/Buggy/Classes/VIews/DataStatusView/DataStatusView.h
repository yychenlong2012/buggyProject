//
//  DataStatusView.h
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/1.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ReloadData)(void);

@interface DataStatusView : UIView

@property (nonatomic ,copy) ReloadData reload;

@end
