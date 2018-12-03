//
//  WatermarkView.h
//  Buggy
//
//  Created by 孟德林 on 2017/7/4.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WatermarkViewHeight 98 *_MAIN_RATIO_375

typedef void(^WaterMarkBlockBack)(NSInteger index);
typedef void(^BabyInfoBlockBack)(BOOL selected);

@interface WatermarkView : UIView

@property (nonatomic ,copy) WaterMarkBlockBack waterblockBack;

@property (nonatomic ,copy) BabyInfoBlockBack babyInfoBlock;

@end
