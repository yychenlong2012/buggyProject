//
//  DeviceTableViewCell.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/24.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "DeviceTableViewCell.h"
#import "CacheManager.h"
#import "BabyModel.h"
#import "BlueToothManager.h"
#import "MainModel.h"
#import "CarA3DetailsViewController.h"
#import "CarOldDetailViewController.h"
#import "NetWorkStatus.h"
@interface DeviceTableViewCell(){
    UILabel *_orderLB;
    UILabel *_deviceNameLB;
    UIButton *_bandingBT; 
}


@end

@implementation DeviceTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _orderLB = [Factory labelWithFrame:CGRectMake(0, 0, 40 * _MAIN_RATIO_375, 22 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(15 * _MAIN_RATIO_375) text:@"" textColor:COLOR_HEXSTRING(@"#666666") onView:self.contentView textAlignment:NSTextAlignmentCenter];
    
    _deviceNameLB = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth/2, 21 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(15 * _MAIN_RATIO_375) text:@"3Pomelos" textColor:COLOR_HEXSTRING(@"#333333") onView:self.contentView textAlignment:NSTextAlignmentLeft];
    
    _bandingBT = [Factory buttonWithFrame:CGRectMake(0, 0,68 * _MAIN_RATIO_375, 22 * _MAIN_RATIO_375) bgColor:nil title:@"现在绑定" textColor:COLOR_HEXSTRING(@"#F47686") click:^{} onView:self.contentView];
    _bandingBT.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    _bandingBT.titleLabel.font = FONT_DEFAULT_Light(13 * _MAIN_RATIO_375);
     //[_bandingBT addTarget:self action:@selector(bandingDevice:) forControlEvents:UIControlEventTouchUpInside];
    _bandingBT.titleLabel.adjustsFontSizeToFitWidth = YES;
    _bandingBT.userInteractionEnabled = NO;
    _bandingBT.layer.borderWidth = 0.5;
    _bandingBT.layer.borderColor = COLOR_HEXSTRING(@"#F47686").CGColor;
    self.tag = 0;
    
    UIView *bottomLine = [Factory viewWithFrame:CGRectMake(40 * _MAIN_RATIO_375, 0, ScreenWidth - 70 * _MAIN_RATIO_375, 0.5) bgColor:COLOR_HEXSTRING(@"#cccccc") onView:self.contentView];
    bottomLine.bottom = DeviceTableViewCellHeight;
}
//-------
- (void)setSelectbgColor {
    self.tag = 1;
    [_bandingBT setTitle:@"查看设备" forState:UIControlStateNormal];
    [_bandingBT setTitleColor:COLOR_HEXSTRING(@"#37B559") forState:UIControlStateNormal];
    _bandingBT.titleLabel.adjustsFontSizeToFitWidth = YES;
    _bandingBT.layer.borderWidth = 0.0;
}
- (void)setUnSelectbgColor {
    self.tag = 0;
    [_bandingBT setTitle:@"现在绑定" forState:UIControlStateNormal];
    [_bandingBT setTitleColor:COLOR_HEXSTRING(@"#F47686") forState:UIControlStateNormal];
    _bandingBT.titleLabel.adjustsFontSizeToFitWidth = YES;
    _bandingBT.layer.borderWidth = 0.5;
}
//--------
-(void)layoutSubviews{
    [super layoutSubviews];
    
    _orderLB.centerY = self.contentView.centerY;
    _deviceNameLB.left = _orderLB.right;
    _deviceNameLB.centerY = self.contentView.centerY;

    _bandingBT.centerY = self.contentView.centerY;
    _bandingBT.right = ScreenWidth - 30 * _MAIN_RATIO_375;
}

- (void)setOrder:(NSInteger)index isBandingDevice:(BOOL)isBanding{
    _orderLB.text = [NSString stringWithFormat:@"%ld",(long)index];
    if (isBanding) {
        [self setSelectbgColor ];
    }else{
        [self setUnSelectbgColor ];
    }
}

- (void)setPeripheral:(NSDictionary *)peripheral{
    _peripheral = peripheral;
    _deviceNameLB.text = peripheral[@"name"];
}

- (NSString *)getTitle{
    return  [_bandingBT titleLabel].text;
}

//将用户和蓝牙进行绑定
-(void)band{
    if ([NetWorkStatus isNetworkEnvironment] == NO) {
        [MBProgressHUD showError:NSLocalizedString(@"网络中断", nil)];
    }else{
        
        //获得设备类型列表用于筛选蓝牙
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [cachePath stringByAppendingPathComponent:@"deviceTypeList.plist"];
        NSArray *deviceTypeList = [NSArray arrayWithContentsOfFile:filePath];
        
        NSString *identifier = @"";
        NSString *fuctionType = @"";
        NSString *company = @"";
        for (NSDictionary *dict in deviceTypeList) {
            if ([self->_peripheral[@"name"] isEqualToString:dict[@"bluetoothName"]]) {
                identifier = dict[@"deviceIdentifier"];
                fuctionType = dict[@"fuctionType"];
                company = dict[@"company"];
            }
        }
        NSDictionary *dict = @{   @"deviceIdentifier":identifier,
                                 @"bluetoothBind":@"1",
                                 @"bluetoothName":self->_peripheral[@"name"],
                                 @"fuctionType":fuctionType,
                                 @"bluetoothUUID":self->_peripheral[@"UUID"],
                                 @"bluetoothDeviceId":@"",
                                 @"company":company,
                                 @"type":@"Ios"
                               };
        
        /*
         2019-02-20 17:36:54.490056+0800 Buggy[443:143674] {
         bluetoothBind = 1;
         bluetoothDeviceId = "";
         bluetoothName = "3POMELOS_G";
         bluetoothUUID = "80AF5A0F-55C0-4BED-DC2D-8CDC71FEA700";
         company = 3Pomelos;
         deviceIdentifier = "Pomelos_G";
         fuctionType = 0;
         type = Ios;
         }
         
         2019-02-20 17:37:05.299268+0800 Buggy[443:143674] 绑定设备：参数错误！ 类型：{
         data = "<null>";
         msg = "\U53c2\U6570\U9519\U8bef\Uff01";
         status = 2;
         }
         
         2019-02-20 17:37:23.865505+0800 Buggy[443:143674] {
         bluetoothBind = 1;
         bluetoothDeviceId = "";
         bluetoothName = "3POMELOS_NEW_A3";
         bluetoothUUID = "29825458-A866-B0C4-6BA4-406E0871CF05";
         company = 3Pomelos;
         deviceIdentifier = "3POMELOS_A3_New";
         fuctionType = 4;
         type = Ios;
         }
         
         
         2019-02-20 17:37:25.666842+0800 Buggy[443:143674] 绑定设备：操作成功！ 类型
         */
        [NETWorkAPI bindDeviceWithDict:dict callback:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [MBProgressHUD showSuccess:@"绑定成功"];
                [self setSelectbgColor];   //改变cell文字的颜色
            }
        }];
        
//        AVQuery *query = [AVQuery queryWithClassName:@"DeviceUUIDList"];
//        [query whereKey:@"bluetoothUUID" equalTo:self->_peripheral[@"UUID"]];
//        [query whereKey:@"post" equalTo:[AVUser currentUser]];
//        [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//            if (error != nil && object == nil && error.code == 101) {
//                //绑定
//                //获得设备类型列表用于筛选蓝牙
//                NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//                NSString *filePath = [cachePath stringByAppendingPathComponent:@"deviceTypeList.plist"];
//                NSArray *deviceTypeList = [NSArray arrayWithContentsOfFile:filePath];
//
//                AVObject *obj = [AVObject objectWithClassName:@"DeviceUUIDList"];
//                NSString *identifier = @"";
//                NSString *fuctionType = @"";
//                NSString *company = @"";
//                for (NSDictionary *dict in deviceTypeList) {
//                    if ([self->_peripheral[@"name"] isEqualToString:dict[@"bluetoothName"]]) {
//                        identifier = dict[@"deviceIdentifier"];
//                        fuctionType = dict[@"fuctionType"];
//                        company = dict[@"company"];
//                    }
//                }
//                [obj setObject:[AVUser currentUser] forKey:@"post"];
//                [obj setObject:identifier forKey:@"deviceIdentifier"];
//                [obj setObject:@(YES) forKey:@"bluetoothBind"];
//                [obj setObject:self->_peripheral[@"name"] forKey:@"bluetoothName"];
//                [obj setObject:fuctionType forKey:@"fuctionType"];
//                [obj setObject:self->_peripheral[@"UUID"] forKey:@"bluetoothUUID"];
//                [obj setObject:company forKey:@"company"];
//                [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                    if (succeeded == YES && error == nil) {
//                        [MBProgressHUD showSuccess:@"绑定成功"];
//                        [self setSelectbgColor];   //改变cell文字的颜色
//                    }
//                }];
//
//            }else{
//                //已经绑定过了
//            }
//        }];
    }
}

- (void)banding{
    //更新babyinfo表中的蓝牙uuid信息
    [[BabyModel manager] updateItemInBabyInfo:_peripheral[@"UUID"] key:@"bluetoothUUID" complete:^(NSString *item){
         [self setSelectbgColor];   //改变cell文字的颜色
         //更新完成
        [MainModel model].blueToothName = self->_peripheral[@"name"];
         [MainModel model].isContectDevice = YES;
        [MainModel model].bluetoothUUID = self->_peripheral[@"UUID"];
         if (![MainModel model].isHaveNetWork) {
             [MBProgressHUD showSuccess:@"绑定成功"];
         }else{
             [self query];  
         }
     }];
}

-(void)query{
    //查找设备标识
//    AVQuery *query = [AVQuery queryWithClassName:@"Cart_List_Details"];
//    [query whereKey:@"bluetoothName" equalTo:_peripheral[@"name"]];
//    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
//        if (error == nil && object) {
//            DeviceModel *model = [[DeviceModel alloc] init];
//            model.bluetoothuuid = self->_peripheral[@"UUID"];
//            model.deviceidentifier = [object objectForKey:@"deviceIdentifier"];
//            model.fuctiontype = [object objectForKey:@"fuctionType"] ;
//            model.company = [object objectForKey:@"company"];
//            model.bluetoothbind = YES;
//            model.bluetoothdeviceid = @"";
//            [DeviceViewModel updatecSelectedDevice:model finish:^(BOOL success, NSError *error) {
//                if (success) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [MBProgressHUD showSuccess:@"绑定成功"];
//                    });
//                }else{
//                    [self showErrorMessage:error];
//                }
//            }];
//        }else{
//
//        }
//    }];
}

@end
