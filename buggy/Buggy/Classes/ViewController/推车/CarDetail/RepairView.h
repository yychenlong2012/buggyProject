//
//  RepairView.h
//  Buggy
//
//  Created by 孟德林 on 2017/6/7.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RepairBlock)(UIButton *bt);

@interface RepairView : UIView

@property (nonatomic ,copy) RepairBlock repairBlock;

/**
 完成修复
 */
- (void)repairFinish;

@end
