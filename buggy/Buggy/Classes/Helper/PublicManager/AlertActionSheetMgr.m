//
//  AlertActionSheetMgr.m
//  carcareIOS
//
//  Created by wr on 16/3/14.
//  Copyright © 2016年 chezheng. All rights reserved.
//

#import "AlertActionSheetMgr.h"
#import "NSString+Bool.h"
@interface AlertActionSheetMgr()<UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic , strong) UIAlertController * alertControlVC;

@property (nonatomic , strong) UIAlertView * alertView;

@property (nonatomic , strong) UIActionSheet * actionSheet;

@property (nonatomic , copy) ClickIndexBlock clickBlock;

@property (nonatomic , assign) TYPE_ALERTVC alertVCType;
@end

@implementation AlertActionSheetMgr

IMP_SINGLETON

- (void)createFromVC:(UIViewController *)vc withAlertType:(TYPE_ALERTVC)alertVCType withTitle:(NSString *)title withMessage:(NSString *)message withCanCelTitle:(NSString *)cancelTitle withRedBtnTitle:(NSString * )redBtnTitle withOtherBtnTitle:(NSString *)otherBtnTitle clickIndexBlock:(ClickIndexBlock)clickIndexBlock
{
    self.alertVCType = alertVCType;
    self.clickBlock = clickIndexBlock;
    if (__IOS_BIGGER_8) {
        self.alertControlVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(alertVCType == TYPE_ALERTVC_ALERT ? UIAlertControllerStyleAlert :UIAlertControllerStyleActionSheet)];
        if ([redBtnTitle isNotNil]) {
            UIAlertAction * alertAction = [UIAlertAction actionWithTitle:redBtnTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                if(self.clickBlock)self.clickBlock((self.alertVCType == TYPE_ALERTVC_ALERT ? 1 : 0));
            }];
            [self.alertControlVC addAction:alertAction];
        }
        if ([otherBtnTitle isNotNil]) {
            UIAlertAction * alertAction = [UIAlertAction actionWithTitle:otherBtnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if(self.clickBlock)self.clickBlock((self.alertVCType == TYPE_ALERTVC_ALERT ? 2 : 1));
            }];
            [self.alertControlVC addAction:alertAction];
        }
        if ([cancelTitle isNotNil]) {
            UIAlertAction * alertAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
            {
               if(self.clickBlock)self.clickBlock((self.alertVCType == TYPE_ALERTVC_ALERT ? 0 : 2));
            }];
            [self.alertControlVC addAction:alertAction];
        }
        
        [vc presentViewController:self.alertControlVC animated:YES completion:nil];
    }else
    {
        switch (alertVCType) {
            case TYPE_ALERTVC_ALERT:
            {
                self.alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:([redBtnTitle isNotNil] ? redBtnTitle : nil),([otherBtnTitle isNotNil] ? otherBtnTitle : nil),nil];
                [self.alertView show];
            }
                break;
            case TYPE_ALERTVC_ACTIONSHEET:
            {
                self.actionSheet = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:([cancelTitle isNotNil] ? cancelTitle : nil) destructiveButtonTitle:redBtnTitle otherButtonTitles:([otherBtnTitle isNotNil] ? otherBtnTitle : nil), nil];
                self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
                [self.actionSheet showInView:vc.view];
                
            }
                break;
            default:
                break;
        }

    
    }
}
#pragma mark - actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.clickBlock)self.clickBlock(buttonIndex);
}

#pragma mark - alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.clickBlock)self.clickBlock(buttonIndex); 
}
- (void)addButtonTitle:(NSString *)btnTitle buttonStyle:(TYPE_ALERTBTN)btnType buttonIndex:(NSInteger)buttonIndex
{
    if (__IOS_BIGGER_8) {
        UIAlertAction * alertAction;
        switch (btnType) {
            case TYPE_ALERTBTN_NONE:
            {
                alertAction = [UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if(self.clickBlock)self.clickBlock(buttonIndex);
                }];
            }
                break;
            case TYPE_ALERTBTN_RED:
            {
                alertAction = [UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    if(self.clickBlock)self.clickBlock(buttonIndex);
                }];
            }
                break;
            default:
                break;
        }
        [self.alertControlVC addAction:alertAction];
    }else
    {
        switch (self.alertVCType) {
            case TYPE_ALERTVC_ALERT:
            {
                [self.alertView addButtonWithTitle:btnTitle];
                [self.alertView show];
            }
                break;
            case TYPE_ALERTVC_ACTIONSHEET:
            {
                [self.actionSheet addButtonWithTitle:btnTitle];
            }
                break;
   
            default:
                break;
        }
    }
}

@end
