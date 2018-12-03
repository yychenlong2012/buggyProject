//
//  RepairViewController.m
//  Buggy
//
//  Created by 孟德林 on 2017/6/7.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "RepairViewController.h"
#import "RepairView.h"
#import "BlueToothManager.h"
#import "BLEDataCallBackAPI.h"
//#import "DeviceLogViewModel.h"

@interface RepairViewController ()<BlueToothManagerDelegate,BLEDataCallBackAPIDelegate>{
    
}
@property (nonatomic ,strong) BLEDataCallBackAPI *bleDataCallBackAPI;
@property (nonatomic,strong) RepairView *repairView;

@end

@implementation RepairViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BLEMANAGER.delegate = self;
    _bleDataCallBackAPI = [[BLEDataCallBackAPI alloc] init];
    _bleDataCallBackAPI.delegate = self;
    self.navigationItem.title = NSLocalizedString(@"一键修复", nil);
    [self.view addSubview:self.repairView];
    __weak typeof(self) wself = self;
    self.repairView.repairBlock = ^(UIButton *bt) {
        [wself.bleDataCallBackAPI sendOrderToRepair];
        DLog(@"修复触发");
    };
}

#pragma mark --- BlueToothManagerDelegate
- (void)getValueForPeripheral{
    NSArray *dataArray = BLEMANAGER.deviceCallBack;
    NSLog(@"%@",dataArray);
    [_bleDataCallBackAPI parserData:dataArray];
}

/**
 修复完成的回调 (如果老设备硬件更新或者新设备则logType参数需要判定设备类型，在这里为A3车仅有，logType为1，后来者再接再厉)
 @param success 成功
 */
- (void)deviceRepairFinish:(NSData *)repairData{
    NSString *logStr = [NSString stringWithFormat:@"%@",repairData];
    [NETWorkAPI uploadDeviceRepairData:self.device.deviceidentifier deviceAddress:@"" repair:logStr bleUUID:self.device.bluetoothuuid callback:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            //延迟3秒提示修复完成
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.repairView repairFinish];
                });
            });
        }
    }];
    
    // 上传修复日志
//    NSString *logStr = [NSString stringWithFormat:@"%@",repairData];
//    NSDictionary *dic = @{@"repairInfo":logStr,@"logType":@(1),@"bluetoothUUID":[BLEMANAGER.currentPeripheral.identifier UUIDString]};
//    if (repairData.length != 0) {
//        [DeviceLogViewModel uploadDeviceRepairLog:dic completeHander:^(BOOL success, NSError *error) {
//            DLog(@"上传日志成功！");
//        }];
//
//        //延迟3秒提示修复完成
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.repairView repairFinish];
//            });
//        });
//    }
}

#pragma mark - setter and getter

- (RepairView *)repairView{
    if (_repairView == nil) {
        _repairView = [[RepairView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, _MAIN_HEIGHT_64)];
    }
    return _repairView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    
}

@end
