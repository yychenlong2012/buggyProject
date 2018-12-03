//
//  NSURL+AVLoader.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/15.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "NSURL+AVLoader.h"

@implementation NSURL (AVLoader)

- (NSURL *)customSchemeURL{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}

- (NSURL *)originalSchemeURL{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"https";
    return [components URL];
}

@end
