//
//  NSObject+ShowErrorMessage.m
//  Buggy
//
//  Created by goat on 2017/8/8.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "NSObject+ShowErrorMessage.h"

@implementation NSObject (ShowErrorMessage)
- (void)showErrorMessage:(NSError *)error{
    if (error.code == -1009) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
             [MBProgressHUD showToast:@"网络未连接"];
        });
    }else if(error.code == 0){
    
    }
    else{
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD showToast:@"操作失败"];
//        });
    }
}
+ (void)showErrorMessage:(NSError *)error{
    if (error.code == -1009) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showToast:@"网络未连接"];
        });
    }else if(error.code == 0){}
    else{ 
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD showToast:@"操作失败"];
//        });
    }
}

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
