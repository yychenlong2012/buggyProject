//
//  RegisterVC.h
//  Buggy
//
//  Created by ningwu on 16/3/12.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "BaseVC.h"

@interface RegisterVC : BaseVC

@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNum;
@property (weak, nonatomic) IBOutlet UITextField *tfVerifyCode;
@property (weak, nonatomic) IBOutlet UIButton *btnVerfigy;
- (IBAction)onNext:(id)sender; 
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIButton *commitbtn;

@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (nonatomic ,assign) BOOL isRePwd;/**<是不是修改密码*/
@end
