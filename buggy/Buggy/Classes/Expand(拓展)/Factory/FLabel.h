//
//  FLable.h
//  CarCare
//
//  Created by ileo on 14/10/21.
//  Copyright (c) 2014年 baozun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLabel : UILabel

-(instancetype)initWithMaxWidth:(CGFloat)maxWidth resetSizeFinish:(void(^)(UILabel *label))finish;

@end
