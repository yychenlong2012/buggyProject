//
//  deviceTypeModel.h
//  Buggy
//
//  Created by goat on 2018/11/19.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface deviceTypeModel : NSObject

@property (nonatomic,strong) NSString *bluetoothname;
@property (nonatomic,strong) NSString *company;
@property (nonatomic,strong) NSString *deviceidentifier;
@property (nonatomic,strong) NSString *fuctiontype;
//@property (nonatomic,strong) NSString *objectid;
@property (nonatomic,strong) NSString *musicbluetoothname;

@end

NS_ASSUME_NONNULL_END


//{
//    bluetoothname = "3POMELOS_G";
//    company = 3Pomelos;
//    deviceidentifier = "Pomelos_G";
//    fuctiontype = 0;
//    musicbluetoothname = "3Pomelos_A3";
//},
