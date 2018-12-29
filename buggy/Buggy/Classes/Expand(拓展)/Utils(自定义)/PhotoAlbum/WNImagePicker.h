//
//  WNImagePicker.h
//  WNImagePicker
//
//  Created by wuning on 16/5/10.
//  Copyright © 2016年 alen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WNImagePicker;

@protocol WNImagePickerDelegate <NSObject>
@optional
- (void)getCutImage:(UIImage *)image;

- (void)onCancel:(WNImagePicker *)vc;
@end

@interface WNImagePicker : UIViewController

@property (nonatomic, weak)id<WNImagePickerDelegate>delegate;     //assign

@end
