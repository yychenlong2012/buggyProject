//
//  CarA3HeaderView.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/26.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarKcalModel.h"
#define  CarA3HeaderViewHeight  305 * _MAIN_RATIO_375

@interface CarA3HeaderView : UIView

- (void)configUIWith:(userTravelInfoModel *)model;

@end

#define CarA3SectionViewHeight 32 * _MAIN_RATIO_375

@interface CarA3SectionView : UIView

@property (nonatomic,strong) UIImageView *lock;   //锁
- (instancetype)initWithFrame:(CGRect)frame withName:(NSString *)name;



@end
