//
//  BabyModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/2/21.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BaseModel.h"

@interface BabyModel : BaseModel

@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *birthday;
@property (nonatomic, strong)AVFile *userImage;
@property (nonatomic, copy)NSString *bluetoothUUID; // 绑定蓝牙设备的UUID号
@property (nonatomic, copy)NSString *native;
@property (nonatomic, copy)NSString *sex;
@property (nonatomic, copy)NSString *age;           //今日年龄

+ (instancetype)manager;


- (void)getBabyInfo:(void(^)(BabyModel *babyModel))model;

/*
 更新某个属性 param
 item:  更新属性的值
 key:   更新属性的key
 complete:  完成的block
 */
- (void)updateItemInBabyInfo:(NSString *)item key:(NSString *)key complete:(void (^)(NSString * item))success ;
/*
 更新多个属性 param
 item:  更新属性的字典 例： @{@"name":@"sangeyoui",@"sex":@"小公举",@"header",filePath}
 key:   更新属性的key
 complete:  完成的block
 */
- (void)updateItemsInBabyInfo:(NSDictionary *)items complete:(void(^)(NSError *error))success;


/**
 *  上传文件
 *
 *  @param data  文件流
 *  @param block 回调是否失败
 */
- (void)uploadData:(NSData *)data complete:(void(^)(NSError *error))block;
- (void)uploadData:(NSData *)data name:(NSString *)name;
- (NSString *)getAgeSince:(NSDate *)date;
@end
