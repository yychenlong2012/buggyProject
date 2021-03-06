//
//  NSObject+Block.h
//  CarCare
//
//  Created by ileo on 14-10-14.
//  Copyright (c) 2014年 baozun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ActionUIControlBlock)(id sender);
typedef void (^ActionUIGestureRecognizerBlock)(id recognizer);

@interface NSObject (Block)

-(void)onlyHangdleUIControlEvent:(UIControlEvents)controlEvent withBlock:(ActionUIControlBlock)action;
-(void)onlyHangdleUIGestureRecognizerWithBlock:(ActionUIGestureRecognizerBlock)action;

@end
