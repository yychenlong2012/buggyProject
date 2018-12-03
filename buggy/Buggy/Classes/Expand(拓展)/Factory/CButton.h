//
//  CButton.h
//  Buggy
//
//  Created by 孟德林 on 16/9/14.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CButton : UIButton
-(id)initWithFrame:(CGRect)frame title:(NSString *)title normalColor:(UIColor *)normal highlightColor:(UIColor *)highlight disabledColor:(UIColor *)disabled action:(void(^)(void))action;



@end
