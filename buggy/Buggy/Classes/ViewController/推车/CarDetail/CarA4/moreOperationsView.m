//
//  moreOperationsView.m
//  Buggy
//
//  Created by goat on 2018/5/9.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "moreOperationsView.h"
#import "MainViewController.h"
#import "DYBaseNaviagtionController.h"
#import "CarA4DetailViewController.h"
#import "BLEA4API.h"
#import "BlueToothManager.h"
#import "RepairViewController.h"
#import "FAQViewController.h"
@interface moreOperationsView()
@property (weak, nonatomic) IBOutlet UIView *repairView;
@property (weak, nonatomic) IBOutlet UIView *replaceName;
@property (weak, nonatomic) IBOutlet UIView *instructions;
@property (weak, nonatomic) IBOutlet UIView *unbound;

@end
@implementation moreOperationsView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    __weak typeof(self) wself = self;
    //一键修复
    [self.repairView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        MainViewController *mainVC = (MainViewController *)[UIViewController presentingVC];
        DYBaseNaviagtionController *Navi = [mainVC selectedViewController];
        CarA4DetailViewController *car = (CarA4DetailViewController *)[Navi topViewController];
        
        RepairViewController *per = [[RepairViewController alloc] init];
        per.device = self.device;
        [car.navigationController pushViewController:per animated:YES];
    }];
    
    //修改设备名称
    [self.replaceName addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        MainViewController *mainVC = (MainViewController *)[UIViewController presentingVC];
        DYBaseNaviagtionController *Navi = [mainVC selectedViewController];
        CarA4DetailViewController *car = (CarA4DetailViewController *)[Navi topViewController];
        
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"修改设备名称", nil) preferredStyle:UIAlertControllerStyleAlert];
        [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(@"输入新的设备名", nil);
        }];
        [vc addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil]];
        [vc addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textfield = vc.textFields.firstObject;
            if (textfield.text.length > 0) {
                wself.deviceName.text = textfield.text;
                car.naviLabel.text = textfield.text;
//                [DeviceViewModel updatecDeviceName:textfield.text UUID:car.peripheralUUID finish:^(BOOL success, NSError *error) {
//                    [MBProgressHUD showToast:NSLocalizedString(@"修改成功", nil)];
//                }];
                [NETWorkAPI updateDeviceName:textfield.text Id:car.deviceModel.objectid callback:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        [MBProgressHUD showToast:NSLocalizedString(@"修改成功", nil)];
                    }
                }];
            }
        }]];
        [car presentViewController:vc animated:YES completion:nil];
    }];
    
    //使用说明
    [self.instructions addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        MainViewController *mainVC = (MainViewController *)[UIViewController presentingVC];
        DYBaseNaviagtionController *Navi = [mainVC selectedViewController];
        CarA4DetailViewController *car = (CarA4DetailViewController *)[Navi topViewController];
        
        FAQViewController *FAQ = [[FAQViewController alloc] init];
        [car.navigationController pushViewController:FAQ animated:YES];
    }];
    
    //解除绑定
    [self.unbound addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        MainViewController *mainVC = (MainViewController *)[UIViewController presentingVC];
        DYBaseNaviagtionController *Navi = [mainVC selectedViewController];
        CarA4DetailViewController *car = (CarA4DetailViewController *)[Navi topViewController];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"是否解除绑定", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [car deviceUnBound];
        }]];
        [car presentViewController:alert animated:YES completion:nil];
    }];
    
}

@end
