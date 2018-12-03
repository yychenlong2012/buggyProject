//
//  NSString+AVLeanCloud.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/17.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFile.h>
#import "AVFileHandle.h"
@interface NSString (AVLeanCloud)

+ (NSString *)downFileName:(NSString *)fileName extensionPath:(NSString *)extensionPath;

+ (BOOL)fileExistsAccordingToLeanCloudCache:(AVFile *)leanCloudCacheFileName loadFile:(NSString *)loadFileName;

+ (BOOL)fileExitsInDownloadWithFileName:(NSString *)fileName;

@end
