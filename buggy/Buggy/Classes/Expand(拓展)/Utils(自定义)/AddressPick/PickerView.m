//
//  PickerView.m
//  writer
//
//  Created by Sophia on 15/6/25.
//  Copyright (c) 2015年 writer. All rights reserved.
//

#import "PickerView.h"
#import "UIView+Additions.h"

@implementation PickerView
{
    NSInteger _selectedComponent;
    NSInteger _selectedRow;
}

#pragma mark- Public Methods

- (void)showInView:(UIView *)view animation:(BOOL)animation;
{
    [self showInView:view titleString:nil animation:animation];
}

- (void)showInView:(UIView *)view titleString:(NSString *)title animation:(BOOL)animation
{
    self.frame = view.bounds;
    [self configureView];
    [view addSubview:self];
    if (title)
        self.title.text = title;
    [self checkData];

   self.pickerView.translatesAutoresizingMaskIntoConstraints = NO;
   NSArray *constraints1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:@{@"view":self.pickerView}];
   NSArray *constraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:nil views:@{@"view":self.pickerView}];
   [view addConstraints:constraints1];
   [view addConstraints:constraints2];
   
    if (animation) {
        float containerY = self.containerView.originY;
        self.containerView.originY = view.height;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
            self.containerView.originY = containerY;
           [self layoutIfNeeded];
            } completion:^(BOOL finished) {
        }];
    }
}

- (void)reloadPickerView
{
    [self checkData];
    //[self.pickerView reloadAllComponents];
}

#pragma mark- Private Methods

- (void)animationOut
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.containerView.originY = self.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)configureView
{
//    if ([UIDevice deviceIsPad])
//    {
//        float maxWidth = self.width / 2.0;
//        float maxHeight = self.height / 2.0;
//        self.containerView.frame = CGRectMake((self.width - maxWidth) / 2.0, (self.height - maxHeight) / 2.0, maxWidth, maxHeight);
//    }
    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userClickedCancelButton:)];
    [self addGestureRecognizer:tapView];
}

- (void)checkData
{
    if ([self.dataSource count] > 0) {
        self.loadingView.hidden = YES;
        [self.loadingView stopAnimating];
        self.containerView.hidden = NO;
    }
    else
    {
        self.loadingView.hidden = NO;
        [self.loadingView startAnimating];
        self.containerView.hidden = YES;
    }
}

#pragma mark- Initialization Methods

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    [self.pickerView reloadAllComponents];
    [self checkData];
}

#pragma mark- User Actions

- (IBAction)userClickedSaveButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectedComponent:selectedRow:)]) {
        [self.delegate didSelectedComponent:_selectedComponent selectedRow:_selectedRow];
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectedComponent:selectedRow:pickerView:)]) {
        [self.delegate didSelectedComponent:_selectedComponent selectedRow:_selectedRow pickerView:self];
    }
    
    [self animationOut];
}

- (IBAction)userClickedCancelButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didCancelSelect)]) {
        [self.delegate didCancelSelect];
    }
    [self animationOut];
}

#pragma mark- UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self.dataSource count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    NSArray *rows = [self.dataSource objectAtIndex:component];
    title = (NSString *)[rows objectAtIndex:row];
    
    return title;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *rows = [self.dataSource objectAtIndex:component];
    return [rows count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor lightTextColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:19]];
    }
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedRow = row;
    _selectedComponent = component;
    
    if ([self.delegate respondsToSelector:@selector(isSelectedComponent:selectedRow:pickerView:)]) {
        [self.delegate isSelectedComponent:component selectedRow:row pickerView:self];
    }
}

@end
