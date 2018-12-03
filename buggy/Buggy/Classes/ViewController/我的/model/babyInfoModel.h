//
//  babyInfoModel.h
//  Buggy
//
//  Created by goat on 2018/11/14.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface babyInfoModel : NSObject

@property (nonatomic ,copy) NSString *birthday;
@property (nonatomic, copy) NSString *birthday_fromnow;  
@property (nonatomic ,copy) NSString *header;
@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,copy) NSString *sex;
@property (nonatomic ,copy) NSString *objectid;

@end

NS_ASSUME_NONNULL_END


//{
//    birthday = "1\U5e740\U67086";
//    header = "";
//    name = "\U4e8c\U5b9d";
//    objectid = 5760e16a7f57850054564103;
//    }
