//
//  ShareAnimationView.h
//  writer
//
//  Created by wuning on 16/3/31.
//  Copyright © 2016年 writer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickBlock)(NSInteger index);

@interface ShareAnimationView : UIView
@property (nonatomic ,strong)ClickBlock block;


- (id)initWithTitleArray:(NSArray *)titlearray  picarray:(NSArray *)picarray;

- (void)show;

- (void)shareWithBlock:(ClickBlock)block;

@end
