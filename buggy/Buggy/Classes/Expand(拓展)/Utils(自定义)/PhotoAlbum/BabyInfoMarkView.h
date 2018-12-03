//
//  BabyInfoMarkView.h
//  Buggy
//
//  Created by 孟德林 on 2017/7/4.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BabyInfoMarkViewHight 117 * _MAIN_RATIO_375
#define BabyInfoMarkViewWeight 125 * _MAIN_RATIO_375

@interface BabyInfoMarkView : UIView

- (void)setbabyDay:(NSString *)day height:(NSString *)height weight:(NSString *)weight;

@end
