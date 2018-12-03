//
//  TagView.h
//  Buggy
//
//  Created by ningwu on 16/5/29.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagView : UIView

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgTag;
@property (weak, nonatomic) IBOutlet UIView *pointView;

- (void)setText:(NSString *)text;

@end
