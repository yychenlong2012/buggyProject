//
//  NSNull+addtion.m
//  Buggy
//
//  Created by goat on 2018/9/3.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "NSNull+addtion.h"

@implementation NSNull (addtion)

//- (NSObject*)objectForKeyedSubscript:(id<NSCopying>)key {
//    return nil;
//}
//
//- (NSObject*)objectAtIndexedSubscript:(NSUInteger)idx {
//    return nil;
//}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [NSNull instanceMethodSignatureForSelector:@selector(description)];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    id temp = nil;
    [anInvocation invokeWithTarget:temp];
}

@end
