//
//  NSURL+AVLoader.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/15.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (AVLoader)

/**
 自定义schme

 @return
 */
- (NSURL *)customSchemeURL;


/**
 还原scheme

 @return
 */
- (NSURL *)originalSchemeURL;

@end
