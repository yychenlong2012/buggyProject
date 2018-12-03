//
//  FLable.m
//  CarCare
//
//  Created by ileo on 14/10/21.
//  Copyright (c) 2014年 baozun. All rights reserved.
//

#import "FLabel.h"
#import "UIView+Additions.h"
@interface FLabel()

@property (nonatomic, copy) void (^ResetSizeFinish)(UILabel* label);
@property (nonatomic, assign) CGFloat maxWidth;

@end

@implementation FLabel

-(instancetype)initWithMaxWidth:(CGFloat)maxWidth resetSizeFinish:(void (^)(UILabel*))finish{
    self = [super initWithFrame:CGRectMake(0, 0, 20, 30)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.maxWidth = maxWidth;
        self.ResetSizeFinish = finish;
        self.numberOfLines = 0;
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

-(void)setText:(NSString *)text{
    [super setText:text];
    [self resetSize];
}

-(void)setFont:(UIFont *)font{
    [super setFont:font];
    [self resetSize];
}

-(void)resetSize{
    NSDictionary *attributes = @{NSFontAttributeName:self.font};
    self.size = [self.text boundingRectWithSize:CGSizeMake(self.maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    if (_ResetSizeFinish) self.ResetSizeFinish(self);
}

@end