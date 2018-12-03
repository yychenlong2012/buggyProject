//
//  shareManager.h
//  Buggy
//
//  Created by ningwu on 16/5/23.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface shareManager : NSObject

+ (void)shareToQQFriends:(UIImage *)image;

+ (void)shareToQZone:(UIImage *)image;

+ (void)shareToWeChatMoment:(UIImage *)image;

+ (void)shareToWeChatFriends:(UIImage *)image;

+ (void)shareToWeibo:(UIImage *)image;

@end
