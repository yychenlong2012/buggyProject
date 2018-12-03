//
//  PickerView.h
//  writer
//
//  Created by Sophia on 15/6/25.
//  Copyright (c) 2015年 writer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PickerView;

@protocol PickerViewDelegate <NSObject>

@optional

//点击了确定按钮
- (void)didSelectedComponent:(NSInteger)component selectedRow:(NSInteger)row;

//适用于多个Piker
- (void)didSelectedComponent:(NSInteger)component selectedRow:(NSInteger)row pickerView:(PickerView *)pickerView;

//正在选择
- (void)isSelectedComponent:(NSInteger)component selectedRow:(NSInteger)row pickerView:(PickerView *)pickerView;

@optional

- (void)didCancelSelect;

@end

@interface PickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (nonatomic, weak) id<PickerViewDelegate> delegate;     //assign
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

- (void)reloadPickerView;

- (void)showInView:(UIView *)view animation:(BOOL)animation;

- (void)showInView:(UIView *)view titleString:(NSString *)title animation:(BOOL)animation;

- (IBAction)userClickedSaveButton:(id)sender;

- (IBAction)userClickedCancelButton:(id)sender;

@end
