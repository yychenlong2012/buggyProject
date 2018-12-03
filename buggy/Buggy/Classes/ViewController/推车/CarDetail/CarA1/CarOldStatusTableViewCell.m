//
//  CarOldStatusTableViewCell.m
//  Buggy
//
//  Created by 孟德林 on 2017/6/10.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "CarA3EnergyView.h"
#import "CarA1TemperatureView.h"
#import "CarOldStatusTableViewCell.h"

@implementation CarOldStatusTableViewCell{
    
    CarA1TemperatureView *_carA1TemperatureView;
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
    
    _carA1TemperatureView = [[CarA1TemperatureView alloc] initWithFrame:CGRectMake(0, 0, 160 * _MAIN_RATIO_375, 105 * _MAIN_RATIO_375)];
    [self.contentView addSubview:_carA1TemperatureView];
    
    
    _carA3EnergyView = [[CarA3EnergyView alloc] initWithFrame:CGRectMake(0, 0, 160 * _MAIN_RATIO_375, 105 * _MAIN_RATIO_375)];
    [self.contentView addSubview:_carA3EnergyView];
    
    _brakeLB = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth /2, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(16) text:NSLocalizedString(@"车内温度", nil) textColor:COLOR_HEXSTRING(@"#333333") onView:self.contentView textAlignment:NSTextAlignmentCenter];
    _energyLB = [Factory labelWithFrame:CGRectMake(0, 0, ScreenWidth /2, 20 * _MAIN_RATIO_375) font:FONT_DEFAULT_Light(16) text:NSLocalizedString(@"剩余电量0%", nil) textColor:COLOR_HEXSTRING(@"#333333") onView:self.contentView textAlignment:NSTextAlignmentCenter] ;
    
    UIView *bottomLine = [Factory viewWithFrame:CGRectMake(0, 0, ScreenWidth, 6 * _MAIN_RATIO_375) bgColor:COLOR_HEXSTRING(@"#EDF0F3") onView:self.contentView];
    bottomLine.bottom = CarOldStatusTableViewCellHeight;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _carA1TemperatureView.left = 22.5 * _MAIN_RATIO_375;
    _carA1TemperatureView.top = 15 * _MAIN_RATIO_375;
    
    _carA3EnergyView.right = ScreenWidth - 22.5 * _MAIN_RATIO_375;
//    _carA3EnergyView.centerY = _carA1TemperatureView.centerY;
    _carA3EnergyView.top = 15 * _MAIN_RATIO_375;
    
    
    _brakeLB.centerX = _carA1TemperatureView.centerX;
    _brakeLB.top = _carA1TemperatureView.bottom + 9 * _MAIN_RATIO_375;
    
    _energyLB.centerX = _carA3EnergyView.centerX;
    _energyLB.top = _carA1TemperatureView.bottom + 9 * _MAIN_RATIO_375;
}

- (void)setupEnergy:(NSString *)energy tem:(NSString *)tem {
    if (energy == nil) {
        energy = @" ";
    }
    if (tem == nil) {
        tem = @" ";
    }
    [_carA3EnergyView setEnergyImageAndEnergyColor:[energy integerValue]];
    _energyLB.text = [NSString stringWithFormat:@"%@%ld%@",NSLocalizedString(@"剩余电量", nil),(long)[energy integerValue],@"%"];
    [_carA1TemperatureView setTemperture:[tem floatValue]];
}

- (void)setBLEConnectStatus:(BOOL)connect{
    [_carA3EnergyView setBLEConnectStatus:connect];
    [_carA1TemperatureView setBLEConnectStatus:connect];
}

@end
