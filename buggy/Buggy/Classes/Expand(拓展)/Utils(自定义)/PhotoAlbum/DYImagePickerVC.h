//
//  DYImagePickerVC.h
//  DYwardrobe
//
//  Created by wuning on 16/1/6.
//  Copyright © 2016年 DY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@class DYImagePickerVC;
@protocol DYImagePickerVCDelegate <NSObject>

- (void)cancel:(DYImagePickerVC *)vc;

@end

@interface DYImagePickerVC : BaseVC

@property (weak, nonatomic) IBOutlet UIImageView *imageSelected;
@property (nonatomic, weak)id<DYImagePickerVCDelegate>delegate;

@end
