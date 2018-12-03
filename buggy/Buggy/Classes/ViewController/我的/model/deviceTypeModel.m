//
//  deviceTypeModel.m
//  Buggy
//
//  Created by goat on 2018/11/19.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import "deviceTypeModel.h"

@implementation deviceTypeModel

//可以在这里设置默认值，可以在生成模型时将数据转化成想要的格式
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property{
    if (oldValue == nil || [oldValue isKindOfClass:[NSNull class]]) {
        if ([property.name isEqualToString:@"bluetoothname"]) {
            return @"";
        }else if([property.name isEqualToString:@"company"]){
            return @"";
        }else if([property.name isEqualToString:@"deviceidentifier"]){
            return @"";
        }else if([property.name isEqualToString:@"fuctiontype"]){
            return @"";
        }else if([property.name isEqualToString:@"musicbluetoothname"]){
            return @"";
        }
    }
    return oldValue;
}

@end

