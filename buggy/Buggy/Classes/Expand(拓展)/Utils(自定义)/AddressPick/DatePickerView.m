//
//  DatePickerView.m
//  Buggy
//
//  Created by ningwu on 16/4/24.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "DatePickerView.h"
#import "UIView+Additions.h"

@implementation DatePickerView

- (void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiden)];
    [self addGestureRecognizer:gr];
    [self configSyle:self.cancelBtn];
    [self configSyle:self.corfirmBtn];
    
    
    self.pickerView.maximumDate = [NSDate date];
}

- (IBAction)onCancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cancelPickerView:)]) {
         [self hiden];
        [self.delegate cancelPickerView:self];
       
    }
}

- (IBAction)onCorfirm:(id)sender {
    if ([self.delegate respondsToSelector:@selector(selectedDate:view:)]) {
            [self hiden];
        [self.delegate selectedDate:self.pickerView.date view:self];
    }
}

- (void)showToView:(UIView *)proView
{
    self.frame = proView.bounds;
    CGRect frame = self.frame;
    frame.origin.y = frame.origin.y - bottomSafeH;
    self.frame = frame;
    [proView addSubview:self];
    
    self.layoutBottom.constant = -self.containerView.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.layoutBottom.constant = 0;
        [self.containerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hiden
{
    [UIView animateWithDuration:0.3 animations:^{
        self.layoutBottom.constant = -self.containerView.height;
        [self.containerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)configSyle:(UIView *)view
{
    view.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    view.layer.borderWidth = 1;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 3;
}
@end
