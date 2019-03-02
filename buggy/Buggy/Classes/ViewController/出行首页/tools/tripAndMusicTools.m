//
//  tripAndMusicTools.m
//  Buggy
//
//  Created by goat on 2018/5/17.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "tripAndMusicTools.h"
#import "WNJsonModel.h"
#import "NetWorkStatus.h"
#import "MainViewController.h"

@implementation tripAndMusicTools{
   
}

//下载已绑定的设备
+(void)requestBoundedDeviceList:(deviceList)list{
    [NETWorkAPI requestDeviceListCallback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        if ([modelArray isKindOfClass:[NSArray class]] && error == nil) {
            if (list) {
                list(modelArray);
            }
        }
    }];
}

//  @[
//    @{ @"musicName":@"春",
//       @"is_collected":@"1" },
//    @{ @"musicName":@"春",
//       @"is_down":@"1" }
//   ]
//上传离线操作数据
+ (void)UploadOfflineOperationData{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [NSString stringWithFormat:@"%@isCollected.plist",KUserDefualt_Get(USER_ID_NEW)];
    NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    
    if ([NetWorkStatus isNetworkEnvironment]) {   //有网
        NSMutableArray *temp = [NSMutableArray arrayWithArray:array];
        if (temp.count>0) {
            NSMutableArray *optionArray = [NSMutableArray array];
            for (NSDictionary *dict in temp) {
                NSString *name = dict[@"musicName"];
                NSString *iscollect = dict[@"is_collected"];
                
                [optionArray addObject:@{  @"musicName":name==nil?@"":name,
                                          @"is_collected":iscollect  }];
            }
            
            [NETWorkAPI updateMusicWithOperation:optionArray callback:^(BOOL success, NSError * _Nullable error) {
                if (success && error == nil) {
                    [temp removeAllObjects];
                    [temp writeToFile:filePath atomically:YES];
                }
            }];
        }
    }
}

//下载设备类型列表   测试版没有这张表
+ (void)downloadDeviceTypeList{
    [NETWorkAPI requestDeviceTypeList:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        if ([modelArray isKindOfClass:[NSArray class]] && error == nil) {
            //将数据存储到本地
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *fileName = @"deviceTypeList.plist";
            NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
            NSMutableArray *temp = [NSMutableArray array];
            
            for (deviceTypeModel *model in modelArray) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:model.deviceidentifier==nil?@"":model.deviceidentifier forKey:@"deviceIdentifier"];  //型号标识
                [dict setObject:model.bluetoothname==nil?@"":model.bluetoothname forKey:@"bluetoothName"];   //蓝牙名
                [dict setObject:model.company==nil?@"":model.company forKey:@"company"];   //公司
                [dict setObject:model.musicbluetoothname==nil?@"":model.musicbluetoothname forKey:@"musicBluetoothName"];   //音乐蓝牙名
                [dict setObject:model.fuctiontype==nil?@"":model.fuctiontype forKey:@"fuctionType"];   //所属界面
                [temp addObject:dict];
            }
            
            //手动添加干脚器的信息
//            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//            [dict setObject:@"tModul" forKey:@"deviceIdentifier"];  //型号标识
//            [dict setObject:@"tModul" forKey:@"bluetoothName"];   //蓝牙名
//            [dict setObject:@"3Pomelos" forKey:@"company"];   //公司
//            [dict setObject:@"tModul" forKey:@"musicBluetoothName"];   //音乐蓝牙名
//            [dict setObject:@"5" forKey:@"fuctionType"];   //所属界面
//            [temp addObject:dict];
//
//            NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
//            [dict2 setObject:@"tModule" forKey:@"deviceIdentifier"];  //型号标识
//            [dict2 setObject:@"tModule" forKey:@"bluetoothName"];   //蓝牙名
//            [dict2 setObject:@"3Pomelos" forKey:@"company"];   //公司
//            [dict2 setObject:@"tModule" forKey:@"musicBluetoothName"];   //音乐蓝牙名
//            [dict2 setObject:@"5" forKey:@"fuctionType"];   //所属界面
//            [temp addObject:dict2];
            
            [temp writeToFile:filePath atomically:YES];
        }
    }];
}

//检测新版本
+ (void)checkVersion{
    
    [NETWorkAPI requestAppControlCallback:^(NSString * _Nullable version, BOOL isHidenVersionCell, NSError * _Nullable error) {
        if ([version isKindOfClass:[NSString class]] && error == nil) {
            NSString *newVersion = version;
            
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString *oldVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
            
            NSString *identifer = [NSString stringWithFormat:@"update%@",newVersion];
            BOOL hasVersionUpdate = [self checkUpdateWithOldVersion:oldVersion newVersion:newVersion];
            NSString * isload = KUserDefualt_Get(identifer);
            
            if (hasVersionUpdate && ![isload isEqualToString:@"1"]) {
                UIView *bgView = [[UIView alloc] init];
                bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
                bgView.frame = [UIScreen mainScreen].bounds;
                MainViewController *vc = (MainViewController *)[UIViewController presentingVC];
                [vc.view addSubview:bgView];
                
                UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, RealWidth(300), RealHeight(379))];
                imageV.image = [UIImage imageNamed:@"软件更新"];
                imageV.center = bgView.center;
                [bgView addSubview:imageV];
                imageV.userInteractionEnabled = YES;
                
                [imageV addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                    [bgView removeFromSuperview];
                }];
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setBackgroundImage:[UIImage imageNamed:@"软件更新btn"] forState:UIControlStateNormal];
                btn.frame = CGRectMake((imageV.width-RealWidth(170))/2.0, imageV.height - RealWidth(38)-17, RealWidth(170), RealWidth(38));
                [imageV addSubview:btn];
                [btn addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {   //跳转到appstore更新
                    [bgView removeFromSuperview];
                    NSString *version = [UIDevice currentDevice].systemVersion;
                    if (version.doubleValue >= 10.0) {
                        [[UIApplication sharedApplication] openURL:
                         [NSURL URLWithString:@"https://itunes.apple.com/cn/app/san-ge-you-zi/id1121966499?mt=8"] options:@{} completionHandler:nil];
                    }else{
                        [[UIApplication sharedApplication] openURL:
                         [NSURL URLWithString:@"https://itunes.apple.com/cn/app/san-ge-you-zi/id1121966499?mt=8"]];
                    }
                }];
                KUserDefualt_Set(@"1", identifer);
            }
        }
    }];
}

//判断是否有新版本
+ (BOOL)checkUpdateWithOldVersion:(NSString *)oldVersion newVersion:(NSString *)newVersion{
    NSArray *old = [oldVersion componentsSeparatedByString:@"."];
    NSArray *new = [newVersion componentsSeparatedByString:@"."];
    if (old.count != 3 || new.count != 3)
        return NO;
    NSInteger oldVersionNmuber = 100 * [old[0] integerValue] + 10 * [old[1] integerValue] + [old[2] integerValue];
    NSInteger newVersionNmuber = 100 * [new[0] integerValue] + 10 * [new[1] integerValue] + [new[2] integerValue];
    return (newVersionNmuber > oldVersionNmuber) ? YES : NO;
}

@end
