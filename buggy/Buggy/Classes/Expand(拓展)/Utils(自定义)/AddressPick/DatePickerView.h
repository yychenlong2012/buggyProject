//
//  DatePickerView.h
//  Buggy
//
//  Created by ningwu on 16/4/24.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatePickerView;
@protocol DatePickerViewDelegate <NSObject>

- (void)selectedDate:(NSDate *)date view:(UIView *)pickerView;

- (void)cancelPickerView:(UIView *)pickerView;

@end

@interface DatePickerView : UIView
@property (weak, nonatomic) IBOutlet UIButton *corfirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *pickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutBottom;
@property (weak, nonatomic)id<DatePickerViewDelegate>delegate;

- (IBAction)onCancel:(id)sender;
- (IBAction)onCorfirm:(id)sender;
- (void)showToView:(UIView *)proView;
@end
