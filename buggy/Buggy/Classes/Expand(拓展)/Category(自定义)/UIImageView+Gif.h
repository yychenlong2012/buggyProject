//
//  UIImageView+Gif.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/25.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Gif)

/**
 生成gif图片

 @param imageUrl gif资源
 */
- (void)gif_setImage:(NSURL *)imageUrl;

@end
