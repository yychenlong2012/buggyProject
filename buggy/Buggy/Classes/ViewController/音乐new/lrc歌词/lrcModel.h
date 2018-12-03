//
//  lrcModel.h
//  Buggy
//
//  Created by goat on 2018/6/13.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface lrcModel : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSTimeInterval time;

- (instancetype)initWithLrclineString:(NSString *)lrclineString;
+ (instancetype)lrcLineWithLrclineString:(NSString *)lrclineString;
@end
