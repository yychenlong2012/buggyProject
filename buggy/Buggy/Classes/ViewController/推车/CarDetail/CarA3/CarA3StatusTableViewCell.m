//
//  CarA3TableViewCell.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/26.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CarA3StatusTableViewCell.h"
#import "CarA3BrakeView.h"
#import "CarA3EnergyView.h"
@implementation CarA3StatusTableViewCell{
    
    CarA3BrakeView *_carA3BrakeView;
    CarA3EnergyView *_carA3EnergyView;
    
    UILabel *_brakeLB;
    UILabel *_energyLB;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    _carA3BrakeView = [[CarA3BrakeView alloc] initWithFrame:CGRectMake(0, 0, 160 * _MAIN_RATIO_375, 105 * _MAIN_RATIO_375)];
    [self.contentView addSubview:_carA3BrakeView];
//    [_carA3BrakeView beginWheelAnimation];
    
    _carA3EnergyView = [[CarA3EnergyView alloc] initWithFrame:CGRectMake(0, 0, 160 * _MAIN_RATIO_375, 105 * _MAIN_RATIO_375)];
    [self.contentView addSubview:_carA3EnergyView];
    
    _brakeLB = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth /2, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(16) text:NSLocalizedString(@"未刹车", nil) textColor:COLOR_HEXSTRING(@"#333333") onView:self.contentView textAlignment:NSTextAlignmentCenter];
    _energyLB = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth /2, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(16) text:NSLocalizedString(@"剩余电量0%", nil) textColor:COLOR_HEXSTRING(@"#333333") onView:self.contentView textAlignment:NSTextAlignmentCenter] ;
    
    UIView *bottomLine = [Factory viewWithFrame:CGRectMake(0, 0, ScreenWidth, 6 * _MAIN_RATIO_375) bgColor:COLOR_HEXSTRING(@"#EDF0F3") onView:self.contentView];
    bottomLine.bottom = CarA3StatusTableViewCellHeight;
     BOOL braking = [KUserDefualt_Get(BRAKINGSTATUS) boolValue];
   // [self setBrakeStatus:braking];
    if (!braking) {
        _brakeLB.text = NSLocalizedString(@"未刹车", nil);
        [_carA3BrakeView setBLEConnectStatus:braking];
    }else{_brakeLB.text = NSLocalizedString(@"已刹车", nil);
        [_carA3BrakeView setBLEConnectStatus:braking];
        [_carA3BrakeView beginBrakePadAnimation];
    }
}
- (void)setBrakeStatus:(BOOL )braking{
    
    // 处于刹车状态
    if (braking) {
//        [_carA3BrakeView removeWheelAnimation];
        [_carA3BrakeView beginBrakePadAnimation];
        
        _brakeLB.text = NSLocalizedString(@"已刹车", nil);
    }else{
        [_carA3BrakeView removeBrakePadAnimation];
        [_carA3BrakeView beginWheelAnimation];
        
        _brakeLB.text = NSLocalizedString(@"未刹车", nil);
    }
}

- (void)setBattery:(NSString *)battery{
     
    NSString *theTureBattery = @"0";
    switch (battery.integerValue) {
        case 0:
            theTureBattery = @"0";
            break;
        case 5:
            theTureBattery = @"10";
            break;
        case 15:
            theTureBattery = @"20";
            break;
        case 40:
            theTureBattery = @"60";
            break;
        case 80:
            theTureBattery = @"100";
            break;
            
        default:
            break;
    }
    [_carA3EnergyView setEnergyImageAndEnergyColor:[theTureBattery integerValue]];
    _energyLB.text = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"剩余电量", nil),theTureBattery,@"%"];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _carA3BrakeView.left = 22.5 * _MAIN_RATIO_375;
    _carA3BrakeView.top = 15 * _MAIN_RATIO_375;
    
    _carA3EnergyView.right = ScreenWidth - 22.5 * _MAIN_RATIO_375;
    _carA3EnergyView.centerY = _carA3BrakeView.centerY;
    
    _brakeLB.centerX = _carA3BrakeView.centerX;
    _brakeLB.top = _carA3BrakeView.bottom + 9 * _MAIN_RATIO_375;
    
    _energyLB.centerX = _carA3EnergyView.centerX;
    _energyLB.top = _carA3BrakeView.bottom + 9 * _MAIN_RATIO_375;
}

- (void)setBLEConnectStatus:(BOOL)connect{
    [_carA3EnergyView setBLEConnectStatus:connect];
    [_carA3BrakeView setBLEConnectStatus:connect];
}
//取消刹车
- (void)cancleBrakeStatus:(BOOL)connect{
    [_carA3BrakeView setBLEConnectStatus:connect];
}

//是否将刹车状态置为黑白
- (void)BrakeStatus:(BOOL)connect{
    [_carA3BrakeView setBLEConnectStatus2:YES];
}
//是否为关机状态
- (void)setCloseStatus:(BOOL)connect{
    [_carA3EnergyView setBLEConnectStatus:connect];   //电量   yes则显示彩色电量
    [_carA3BrakeView setBLEConnectStatus:connect];    //刹车   yes则显示彩色刹车状态
    if (connect) {
        return;
    }
}

//智能刹车是否开启
-(void)isSmartBrakeOpen:(BOOL)isOpen{
    [_carA3BrakeView setBLEConnectStatus:isOpen];
}
@end
