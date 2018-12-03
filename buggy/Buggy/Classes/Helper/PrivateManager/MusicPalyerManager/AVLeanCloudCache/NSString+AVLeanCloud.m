//
//  NSString+AVLeanCloud.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/17.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "NSString+AVLeanCloud.h"

@implementation NSString (AVLeanCloud)

+ (NSString *)downFileName:(NSString *)fileName extensionPath:(NSString *)extensionPath{
    
    NSString *name = [NSString stringWithFormat:@"%@.%@",fileName,extensionPath];
    return name;
}

+ (BOOL)fileExistsAccordingToLeanCloudCache:(AVFile *)leanCloudCacheFileName loadFile:(NSString *)loadFileName{
//    NSLog(@"%d %@",leanCloudCacheFileName.isDataAvailable,[AVFileHandle loadFileExistsWithFileName:loadFileName]);
    if (!leanCloudCacheFileName.isDataAvailable && ![AVFileHandle loadFileExistsWithFileName:loadFileName]) {
        NSLog(@"不存在");
        return NO;
    }
    return YES;
}

+ (BOOL)fileExitsInDownloadWithFileName:(NSString *)fileName
{
    NSString *path = [AVFileHandle loadFileExistsWithFileName:fileName];
    
    return path ? YES : NO;
}

@end
