//
//  MineNewViewController.m
//  Buggy
//
//  Created by goat on 2018/5/4.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MineNewViewController.h"
#import "mineNewTableViewCell.h"
#import "MineDataTools.h"
#import "DeviceViewController.h"
#import "DeviceModel.h"
#import "DYBaseNaviagtionController.h"
#import "BabyInfoViewController.h"
#import "WNImagePicker.h"
#import "MusicLikeViewController.h"
#import "MusicLocalViewController.h"
#import "FeedBackViewController.h"
#import "FAQViewController.h"
#import "SetupViewController.h"
#import "CarA3DetailsViewController.h"
#import "CarA4DetailViewController.h"
#import "CarOldDetailViewController.h"
#import "BabyModel.h"
#import "BlueToothManager.h"
#import "UIImage+COSAdtions.h"
#import "CLImageView.h"
#import "setBabyBirthdayVC.h"
#import "WNJsonModel.h"
#import "MainViewController.h"
#import "mineNewBabyCell.h"
#import "mineNewDeviceCell.h"
#import "CLLabel.h"
#import "FAQNewViewController.h"
#import <MJExtension.h>

@interface MineNewViewController ()<UITableViewDelegate,UITableViewDataSource,WNImagePickerDelegate,BlueToothManagerDelegate>

@property (nonatomic,strong) UIView *topHeaderView;   //用户信息
@property (nonatomic,strong) UILabel *userNameLabel;
@property (nonatomic,strong) UIImageView *userImageView;

//@property (nonatomic,strong) NSMutableArray<DeviceModel *>* deviceArray;  //推车数据

@end

@implementation MineNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.babyArray = [NSMutableArray array];
//    self.deviceArray = [NSMutableArray array];
    [self.view addSubview:self.tableview];
    [self guideView];
    if (@available(iOS 11.0, *)) {
        self.tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
//    if ([NETWorkAPI.userInfo isKindOfClass:[userInfoModel class]]) {
        [self requestParentData];
//    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    BLEMANAGER.delegate = self;
    if (self.babyArray.count == 0) {
        [self requestChildData];
    }
    
//    if (NETWorkAPI.deviceArray.count == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self requestDeviceData];
        });
//    }
    
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
}

//请求已绑定的推车信息
-(void)requestDeviceData{
    [NETWorkAPI requestDeviceListCallback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        if (modelArray != nil && [modelArray isKindOfClass:[NSArray class]] && error == nil) {
            NETWorkAPI.deviceArray = [NSMutableArray arrayWithArray:modelArray];
            [self.tableview reloadData];
        }else{
            
        }
    }];
}

//获取宝宝列表
-(void)requestChildData{
    [NETWorkAPI requestBabyListcallback:^(NSArray * _Nullable modelArray, NSInteger currentPage, NSError * _Nullable error) {
        if (modelArray != nil && [modelArray isKindOfClass:[NSArray class]] && error == nil) {
            [self.babyArray removeAllObjects];
            [self.babyArray addObjectsFromArray:modelArray];
            [self.tableview reloadData];
        }else{
            
        }
    }];
}

//获取父母信息
-(void)requestParentData{
    if (NETWorkAPI.userInfo != nil) {
        [self displayParentData];
    }else{
        [NETWorkAPI requestUserDataCallback:^(id  _Nullable model, NSError * _Nullable error) {
            if (model == nil) {
                return ;
            }
            [self displayParentData];
        }];
    }
}

-(void)displayParentData{
    if ([NETWorkAPI.userInfo.nickname isKindOfClass:[NSString class]]) {
        self.userNameLabel.text = NETWorkAPI.userInfo.nickname;
    }
    if ([NETWorkAPI.userInfo.header isKindOfClass:[NSString class]]) {
        NSURL *url = [NSURL URLWithString:NETWorkAPI.userInfo.header];
        if (url) {
            [self.userImageView sd_setImageWithURL:url];
        }
    }
}

//新手引导
-(void)guideView{
    if (![KUserDefualt_Get(@"isFirstLaunchMine") isEqualToString:@"1"]) {
        UIImageView *imageView= [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-bottomSafeH);
        if (ScreenHeight == 812) {  //X
            imageView.image = ImageNamed(@"1125个人主页");
        }else{
            imageView.image = ImageNamed(@"750个人主页");
        }
        imageView.userInteractionEnabled = YES;
        __weak typeof(imageView) weakImage = imageView;
        [imageView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [weakImage removeFromSuperview];
            KUserDefualt_Set(@"1", @"isFirstLaunchMine");
        }];
        MainViewController *main = (MainViewController *)[UIViewController presentingVC];
        [main.view addSubview:imageView];
    }
}

//打开正确的推车界面
-(void)openRightCarWith:(DeviceModel *)model{
    NSUUID *justuuid = [[NSUUID UUID]initWithUUIDString:model.bluetoothuuid];
    CBPeripheral * justperi =[[BLEMANAGER.centralManager  retrievePeripheralsWithIdentifiers:@[justuuid]] firstObject];   //根据uuid恢复设备
    
    //新版本的判断
    if (model.deviceidentifier != nil) {
        if ([model.fuctiontype isEqualToString:@"1"]) {   //Pomelos_A3
            CarA3DetailsViewController *device = [[CarA3DetailsViewController alloc] init];
            device.peripheralUUID = model.bluetoothuuid;
            if (model.bluetoothname != nil && ![model.bluetoothname isEqualToString:@""]) {
                device.deviceName = model.bluetoothname;
            }else{
                device.deviceName = [model getTheDeviceName];
            }
            [device connectionBLE:justperi];
            device.deviceModel = model;
            device.canConnectPeripheral = justperi;
            [self.navigationController pushViewController:device animated:YES];
            return;
        }else if ([model.fuctiontype isEqualToString:@"0"]){   //Pomelos_G
            CarOldDetailViewController *device = [[CarOldDetailViewController alloc] init];
            device.peripheralUUID = model.bluetoothuuid;
            if (model.bluetoothname != nil && ![model.bluetoothname isEqualToString:@""]) {
                device.deviceName = model.bluetoothname;
            }else{
                device.deviceName = [model getTheDeviceName];
            }
            device.peripheral = justperi;
            device.deviceModel = model;
            [device connectionBLE:justperi];
            [self.navigationController pushViewController:device animated:YES];
            return;
        }else if ([model.fuctiontype isEqualToString:@"2"] || [model.fuctiontype isEqualToString:@"3"]){  //Pomelos_8101   3POMELOS_A6
            CarA4DetailViewController *car = [[CarA4DetailViewController alloc] init];
            car.fuctionType = model.fuctiontype.integerValue;
            if (model.bluetoothname != nil && ![model.bluetoothname isEqualToString:@""]) {
                car.deviceName = model.bluetoothname;
            }else{
                car.deviceName = [model getTheDeviceName];
            }
            car.peripheralUUID = model.bluetoothuuid;
            car.deviceModel = model;
            [self.navigationController pushViewController:car animated:YES];
            return;
        }else{  //默认
            CarA4DetailViewController *car = [[CarA4DetailViewController alloc] init];
            if (model.bluetoothname != nil && ![model.bluetoothname isEqualToString:@""]) {
                car.deviceName = model.bluetoothname;
            }else{
                car.deviceName = [model getTheDeviceName];
            }
            car.peripheralUUID = model.bluetoothuuid;
            car.deviceModel = model;
            [self.navigationController pushViewController:car animated:YES];
        }
    }
}

//获得已连接的和已绑定的设备
-(NSMutableArray<DeviceModel *> *)getTheConnectedDevice{
    NSMutableArray *array = [NSMutableArray array];
    if (BLEMANAGER.currentPeripheral) {
        for (DeviceModel *model in NETWorkAPI.deviceArray) {
            if ([model.bluetoothuuid isEqualToString:BLEMANAGER.currentPeripheral.identifier.UUIDString]) {
                [array addObject:model];
            }
        }
    }
    return array;
}

#pragma mark -- WNImagePickerDelegate
- (void)getCutImage:(UIImage *)image controller:(WNImagePicker *)vc{
    [self.navigationController popToViewController:self animated:YES];
    
    //上传用户头像
    NSData *imageData = [image compressImageWithImage:image aimWidth:300 aimLength:300*1024 accuracyOfLength:1024];
    [NETWorkAPI updateUserInfoWithOptionType:UPLOAD_USER_HEADER optionValue:imageData callback:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            self.userImageView.image = image;
        }
    }];
}

#pragma mark - BlueToothManagerDelegate
-(void)didDisconnectPeripheral:(NSError *)error{
    [self.tableview reloadData];
}
#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{return 4;}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (self.babyArray.count>0) {
            return self.babyArray.count;
        }else{
            return 1;
        }
    }else if (section == 1){
        if (NETWorkAPI.deviceArray.count>0) {
            return NETWorkAPI.deviceArray.count;
        }else{
            return 1;
        }
    }else if (section == 2){
        return 2;
    }else if (section == 3){
        return 3;
    }else{
        return 0;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section ==  0)
        return RealWidth(283)+12;
    else
        return RealWidth(56);
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.topHeaderView;
    }else if (section == 1){
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, RealWidth(66))];
        header.backgroundColor = kWhiteColor;
        
        UILabel *myDevice = [[UILabel alloc] initWithFrame:CGRectMake(20, 22, 200, 20)];
        myDevice.text = NSLocalizedString(@"我的设备", nil);
        myDevice.textAlignment = NSTextAlignmentLeft;
        myDevice.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
        [header addSubview:myDevice];
        
        CLImageView *addDevice = [[CLImageView alloc] initWithImage:ImageNamed(@"添加按钮")];
        addDevice.frame = CGRectMake(ScreenWidth-45, 19.5, 25, 25);
        addDevice.userInteractionEnabled = YES;
        [addDevice addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            DeviceViewController *device = [[DeviceViewController alloc] init];
//            device.bandPeripherals = NETWorkAPI.deviceArray;
            [self.navigationController pushViewController:device animated:YES];
        }];
        [header addSubview:addDevice];
        return header;
    }else if (section == 2){
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, RealWidth(66))];
        header.backgroundColor = kWhiteColor;
        
        UILabel *myMusic = [[UILabel alloc] initWithFrame:CGRectMake(20, 22, 120, 20)];
        myMusic.text = NSLocalizedString(@"我的音乐", nil);
        myMusic.textAlignment = NSTextAlignmentLeft;
        myMusic.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
        [header addSubview:myMusic];
        return header;
    }else if (section == 3){
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, RealWidth(66))];
        header.backgroundColor = kWhiteColor;
        
        UILabel *myMusic = [[UILabel alloc] initWithFrame:CGRectMake(20, 22, 120, 20)];
        myMusic.text = NSLocalizedString(@"使用帮助", nil);
        myMusic.textAlignment = NSTextAlignmentLeft;
        myMusic.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
        [header addSubview:myMusic];
        return header;
    }else{
        return [[UIView alloc] init];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{return 14;}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = kWhiteColor;
    footer.frame = CGRectMake(0, 0, ScreenWidth, 14);
    
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [UIColor colorWithMacHexString:@"#F9F9F9"].CGColor;
    layer.frame = CGRectMake(0, 7, ScreenWidth, 7);
    [footer.layer addSublayer:layer];
    return footer;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (self.babyArray.count==0) {
            return 49;
        }
    }
    if (indexPath.section == 1) {
        if (NETWorkAPI.deviceArray.count==0) {
            return 102;
        }
    }
    return 46;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    mineNewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[mineNewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.arrow.hidden = YES;
    
    if (indexPath.section == 0) {
        if (self.babyArray.count == 0) {
            UITableViewCell *emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]; //防止重用cell时label无法隐藏，重新创建一个cell
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-200)/2, 0, 200, 17)];
            label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
            label.text = NSLocalizedString(@"还没有添加宝宝哦...", nil);
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
            emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [emptyCell.contentView addSubview:label];
            return emptyCell;
        }else{
            mineNewBabyCell *babyCell = [tableView dequeueReusableCellWithIdentifier:@"babyCell"];
            if (babyCell == nil) {
                babyCell = [[mineNewBabyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"babyCell"];
                babyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            babyInfoModel *model = self.babyArray[indexPath.row];
            babyCell.itemLabel.text = model.name;
            babyCell.icon.image = ImageNamed(@"Group 2 Copy");
            if ([model.header isKindOfClass:[NSString class]]) {
                NSURL *url = [NSURL URLWithString:model.header];
                if (url) {
                    [babyCell.icon sd_setImageWithURL:url placeholderImage:ImageNamed(@"Group 2 Copy")];
                }
            }
            babyCell.detailLabel.text = model.birthday_fromnow;
            return babyCell;
        }
    }else if (indexPath.section == 1){
        if (NETWorkAPI.deviceArray.count == 0) {  //无推车数据
            UITableViewCell *emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];//防止重用cell时label无法隐藏，重新创建一个cell
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-200)/2, 30, 200, 17)];
            label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
            label.text = NSLocalizedString(@"点击右上角添加设备", nil);
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
            emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [emptyCell.contentView addSubview:label];
            return emptyCell;
        }else{
            mineNewDeviceCell *deviceCell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell"];
            if (deviceCell == nil) {
                deviceCell = [[mineNewDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deviceCell"];
                deviceCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            DeviceModel *model = NETWorkAPI.deviceArray[indexPath.row];
            deviceCell.itemLabel.text = [model getTheDeviceName];
            if (model.deviceidentifier != nil && [model.deviceidentifier isKindOfClass:[NSString class]]) {
                deviceCell.icon.image = ImageNamed(model.deviceidentifier);
            }else{
                deviceCell.icon.image = ImageNamed(@"推车");
            }
            deviceCell.itemLabel.textColor = kBlackColor;
            if (BLEMANAGER.currentPeripheral) {
                if ([BLEMANAGER.currentPeripheral.identifier.UUIDString isEqualToString:model.bluetoothuuid]) {
                    deviceCell.itemLabel.textColor = COLOR_HEXSTRING(@"#37B559");
                }
            }
            return deviceCell;
        }
    }else if (indexPath.section == 2){
        cell.detailLabel.hidden = NO;
        cell.itemLabel.textColor = [UIColor colorWithMacHexString:@"#101010"];
        if (indexPath.row == 0) {
            cell.itemLabel.text = NSLocalizedString(@"收藏歌曲", nil);
            cell.icon.image = ImageNamed(@"收藏");
            cell.detailLabel.text = [NSString stringWithFormat:@"%ld首",(long)[MineDataTools getSelectedMusicCount]];
        }else{
            cell.itemLabel.text = NSLocalizedString(@"下载歌曲", nil);
            cell.icon.image = ImageNamed(@"下载");
            cell.detailLabel.text = [NSString stringWithFormat:@"%ld首",(long)[MineDataTools getDownloadMusicCount]];
        }
    }else{
        cell.detailLabel.hidden = YES;
        cell.arrow.hidden = NO;
        if (indexPath.row == 0) {
            cell.itemLabel.text = NSLocalizedString(@"使用说明", nil);
            cell.icon.image = ImageNamed(@"说明书");
        }else if (indexPath.row == 1){
            cell.itemLabel.text = NSLocalizedString(@"问题反馈", nil);
            cell.icon.image = ImageNamed(@"问题反馈");
        }else{
            cell.itemLabel.text = NSLocalizedString(@"设置", nil);
            cell.icon.image = ImageNamed(@"设置");
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (self.babyArray.count > 0) {
            BabyInfoViewController *vc = [[BabyInfoViewController alloc] init];
            vc.lastVC = self;
            babyInfoModel *model = self.babyArray[indexPath.row];
            vc.babyId = model.objectid;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == 1){
        if (NETWorkAPI.deviceArray.count > 0) {
            DeviceModel *model = NETWorkAPI.deviceArray[indexPath.row];
            if (BLEMANAGER.currentPeripheral) {
                if (![BLEMANAGER.currentPeripheral.identifier.UUIDString isEqualToString:model.bluetoothuuid]) {
                    [BLEMANAGER cancelConnect];
                }
            }
            [self openRightCarWith:model];
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            MusicLikeViewController *like = [[MusicLikeViewController alloc] init];
//            like.deviceModel = @"蓝牙(BlueTooth)";    //这里是否可以写固定的值
            [self.navigationController pushViewController:like animated:YES];
        }else{
            MusicLocalViewController *local = [[MusicLocalViewController alloc] init];
//            local.deviceModel = @"蓝牙(BlueTooth)";
            [self.navigationController pushViewController:local animated:YES];
        }
    }else if (indexPath.section == 3){
        if (indexPath.row == 0) {  //使用说明
            FAQNewViewController *FAQ = [[FAQNewViewController alloc] init];
            [self.navigationController pushViewController:FAQ animated:YES];
        }else if (indexPath.row == 1){  //问题反馈
            FeedBackViewController *feedBack = [[FeedBackViewController alloc] init];
            [self.navigationController pushViewController:feedBack animated:YES];
        }else if (indexPath.row == 2){  //设置
            SetupViewController *setup = [[SetupViewController alloc] init];
            [self.navigationController pushViewController:setup animated:YES];
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (self.babyArray.count > 0) {
            return YES;
        }
    }
    if (indexPath.section == 1) {
        if (NETWorkAPI.deviceArray.count > 0) {
            return YES;
        }
    }
    return NO;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NSLocalizedString(@"删除信息", nil);
    }
    if (indexPath.section == 1) {
        return NSLocalizedString(@"解绑", nil);
    }
    return NSLocalizedString(@"删除", nil);
}

- (UITableViewCellEditingStyle )tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0) {
            if (self.babyArray.count > 0) {  //删除宝宝信息
                if (self.babyArray != nil && indexPath.row < self.babyArray.count) {
                    babyInfoModel *model = self.babyArray[indexPath.row];
                    [NETWorkAPI deleteBabyWithId:model.objectid callback:^(BOOL success, NSError * _Nullable error) {
                        if (success) {
                            [self.babyArray removeObjectAtIndex:indexPath.row];
                            [self.tableview reloadData];
                        }
                    }];
                }
                return;
            }
        }
        if (indexPath.section == 1) {       //删除推车信息
            if (NETWorkAPI.deviceArray != nil && indexPath.row < NETWorkAPI.deviceArray.count) {
                DeviceModel *model = NETWorkAPI.deviceArray[indexPath.row];
                [NETWorkAPI deleteDeviceWithId:model.objectid callback:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        //解绑的是当前连接的设备 则断开连接
                        if ([model.bluetoothuuid isEqualToString:BLEMANAGER.currentPeripheral.identifier.UUIDString]) {
                           [BLEMANAGER cancelConnect];
                        }
                        [AYMessage show:NSLocalizedString(@"解除绑定成功", nil) onView:self.view autoHidden:YES];
                        [NETWorkAPI.deviceArray removeObjectAtIndex:indexPath.row];
                        //删除本地该推车的本地缓存
                        [self.tableview reloadData];
                    }else{
                        [MBProgressHUD showError:NSLocalizedString(@"解绑失败", nil)];
                    }
                }];
            }
        }
    }
}

//获得年龄
-(NSString *)getTheIntervalWithDate1:(NSDate *)date1 date2:(NSDate *)date2{
    if (date1 == nil || date2 == nil) {
        return @"";
    }
    NSCalendar *chineseClendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    //从一个日期里面把这些内容取出来
    NSDateComponents *cps = [chineseClendar components:unitFlags fromDate:date1  toDate:date2  options:0];
    //时间间隔
    NSInteger Year = [cps year];
    NSInteger Mon  = [cps month];
    NSInteger Day  = [cps day];
    
    NSString *yearStr = Year == 0 ? @"" : [NSString stringWithFormat:@"%ld岁",(long)Year];
    NSString *monStr = Mon == 0 ? @"" : [NSString stringWithFormat:@"%ld个月",(long)Mon];
    NSString *dayStr = Day == 0 ? @"" : [NSString stringWithFormat:@"%ld天",(long)Day];
    
    NSString *str;
    if (Year == 0 && Mon == 0 && Day == 0) {
        str = NSLocalizedString(@"刚刚出生", nil);
    }else{
        if (Year == 0) {
            str = [NSString stringWithFormat:@"%@%@",monStr,dayStr];
        }else{
            str = [NSString stringWithFormat:@"%@%@",yearStr,monStr];
        }
    }
    return str;
}
#pragma mark - action
/**<解除绑定*/
//- (void)deleteDevice:(NSIndexPath *)indexPath{
//    if (self.deviceArray.count == 0 || self.deviceArray.count <= indexPath.row)
//        return;
//
//    DeviceModel *model = self.deviceArray[indexPath.row];
//    if (!model) {
//        return;
//    }
//    [self.deviceArray removeObjectAtIndex:indexPath.row];
////    [[BabyModel manager] updateItemInBabyInfo:@"" key:@"bluetoothUUID" complete:^(NSString *item) {
////        [MainModel model].bluetoothUUID = @"";
////        [MainModel model].blueToothName = @"3POMELOS_L";
////        [BLEMANAGER cancelConnect];
////    }];
//    [DeviceViewModel deleteSelectedDeviceUUID:model.bluetoothuuid finish:^(BOOL success, NSError *error) {
//        [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        if (success) {
//            //                [[NSNotificationCenter defaultCenter] postNotificationName:kACCESSESEQUIPMENTLIST object:nil];
//            // [AYMessage show:@"解除绑定成功" onView:self.view autoHidden:YES];
//        }else{
//            [MBProgressHUD showError:NSLocalizedString(@"解绑失败", nil)];
//        }
////        [self requestDeviceList];
//    }];
//}
#pragma mark - 隐藏导航栏
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - lazy
-(UITableView *)tableview{
    if (_tableview == nil) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-tabbarH) style:UITableViewStyleGrouped];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.bounces = NO;
    }
    return _tableview;
}

-(UIView *)topHeaderView{
    if (_topHeaderView == nil) {
        _topHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, RealWidth(283)+22)];
        _topHeaderView.backgroundColor = kWhiteColor;
        
        __weak typeof(self) wself = self;
        UIImageView *BGImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, RealWidth(258))];
        BGImage.image = ImageNamed(@"背景");
        [_topHeaderView addSubview:BGImage];
        
        //头像
        UIImageView *userIcon = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-RealWidth(75))/2, RealWidth(64.5), RealWidth(75), RealWidth(75))];
        userIcon.image = ImageNamed(@"home_default");
        self.userImageView = userIcon;
        userIcon.userInteractionEnabled = YES;
        [_topHeaderView addSubview:userIcon];
        //圆形边框
        CAShapeLayer *shape = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:userIcon.bounds];
        shape.path = path.CGPath;
        userIcon.layer.mask = shape;
        CAShapeLayer *shape2 = [CAShapeLayer layer];
        shape2.path = path.CGPath;
        shape2.strokeColor = kWhiteColor.CGColor;
        shape2.fillColor = kClearColor.CGColor;
        shape2.lineWidth = 1;
        [userIcon.layer addSublayer:shape2];
        userIcon.layer.mask = shape;
        [userIcon addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            WNImagePicker *pickerVC  = [[WNImagePicker alloc]init];
            pickerVC.delegate = wself;
            [wself.navigationController pushViewController:pickerVC animated:YES];
        }];
        
        //昵称
        CLLabel *label = [[CLLabel alloc] initWithFrame:CGRectMake(0, userIcon.bottom+10, 0, 15)];
        label.extraWidth = 15;  //额外点击区域
        self.userNameLabel = label;
        label.text = NSLocalizedString(@"小宝贝的守护者", nil);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        label.textColor = [UIColor colorWithMacHexString:@"#131313"];
        label.userInteractionEnabled = YES;
        [label addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            //修改昵称
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"编辑昵称", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedString(@"请输入昵称", nil);  //配置textField
            }];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleDestructive handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (alert.textFields.firstObject.text.length >0) {
                    //上传昵称信息
//                    [[AVUser currentUser] setObject:alert.textFields.firstObject.text forKey:@"nickName"];
//                    [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                        NSLog(@"%d %@",succeeded,error);
//                    }];
                    [NETWorkAPI updateUserInfoWithOptionType:UPLOAD_USER_NAME optionValue:alert.textFields.firstObject.text callback:^(BOOL success, NSError * _Nullable error) {
                        if (success) {
                            wself.userNameLabel.text = alert.textFields.firstObject.text;
                            [wself.tableview reloadData];
                        }
                    }];
                }
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }];
        
        //白色背景
        UIView *labelBGView = [[UIView alloc] init];
        labelBGView.backgroundColor = [UIColor colorWithMacHexString:@"#FFFFFF"];
        labelBGView.layer.cornerRadius = 3;
        [_topHeaderView addSubview:labelBGView];
        [_topHeaderView addSubview:label];
        //设置约束
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(userIcon.mas_centerX);
            make.centerY.equalTo(userIcon.mas_bottom).offset(18+7.5);
        }];
        [labelBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label.mas_top).offset(-6.5);
            make.bottom.equalTo(label.mas_bottom).offset(6.5);
            make.left.equalTo(label.mas_left).offset(-20);
            make.right.equalTo(label.mas_right).offset(20);
        }];
        
        UILabel *baby = [[UILabel alloc] initWithFrame:CGRectMake(20, RealWidth(258), 100, 20)];
        baby.text = NSLocalizedString(@"宝宝", nil);
        baby.textAlignment = NSTextAlignmentLeft;
        baby.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
        [_topHeaderView addSubview:baby];
        
        //添加宝宝按钮
        CLImageView *addBaby = [[CLImageView alloc] initWithImage:ImageNamed(@"添加按钮")];
        addBaby.frame = CGRectMake(ScreenWidth-45, RealWidth(258)-2.5, 25, 25);
        addBaby.userInteractionEnabled = YES;
        [addBaby addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            setBabyBirthdayVC *birthday = [[setBabyBirthdayVC alloc] init];
            birthday.isResetData = NO;
//            birthday.BabyObject = [AVObject objectWithClassName:@"BabyInfo"];
//            [birthday.BabyObject setObject:[AVUser currentUser] forKey:@"post"];
            birthday.sourceVC = self;
            birthday.view.backgroundColor = kWhiteColor;
            [self.navigationController pushViewController:birthday animated:YES];
        }];
        [_topHeaderView addSubview:addBaby];
    }
    return _topHeaderView;
}
@end
