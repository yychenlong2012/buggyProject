//
//  UILabel+Additions.m
//  Buggy
//
//  Created by ningwu on 16/5/22.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "UILabel+Additions.h"
#import "UIView+Additions.h"

@implementation UILabel (Additions)

- (CGSize )sizeToString:(NSString *)text
{
    UILabel *label = (UILabel *)[UIView duplicate:self];
    label.text = text;
    [label sizeToFit];
    CGSize size = CGSizeMake(label.width + 3, label.height + 2);
    return size;
}

@end
