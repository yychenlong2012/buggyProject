//
//  
//  ay
//
//  Created by zrg on 16/3/22.
//  Copyright © 2016年 Dandre. All rights reserved.
//

#import "AYObject.h"

@implementation AYObject

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    DLog(@"key %@ is missed! value：%@",key,value);
}

@end
