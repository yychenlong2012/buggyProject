//
//  CButton.m
//  Buggy
//
//  Created by 孟德林 on 16/9/14.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "CButton.h"
#import "KVCHelper.h"
#import "NSObject+Block.h"

@interface CButton()


@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, strong) UIColor *disabledColor;

@property (nonatomic, strong) KVCHelper *kvcHighlight;
@property (nonatomic, strong) KVCHelper *kvcDisabled;

@end

@implementation CButton

-(void)dealloc{
    
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title normalColor:(UIColor *)normal highlightColor:(UIColor *)highlight disabledColor:(UIColor *)disabled action:(void (^)(void))action
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.normalColor = normal;
        self.highlightColor = highlight;
        self.disabledColor = disabled;
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = FONT_DEFAULT_Light(15);
        self.backgroundColor = self.normalColor;
        
        __weak __typeof(self) wSelf = self;
        
        [self onlyHangdleUIControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            if (action) {
                action();
            }
        }];
        
        [self setExclusiveTouch:YES];
        
        self.kvcHighlight = [[KVCHelper alloc] initWithSubject:self forKeyPath:@"highlighted" change:^{
            [wSelf setBackgroundColorEachState];
        }];
        
        self.kvcDisabled = [[KVCHelper alloc] initWithSubject:self forKeyPath:@"enabled" change:^{
            [wSelf setBackgroundColorEachState];
        }];
        
    }
    return self;
}

-(void)setBackgroundColorEachState{
    switch (self.state) {
        case UIControlStateDisabled:
            self.backgroundColor = self.disabledColor;
            break;
        case UIControlStateHighlighted:
            self.backgroundColor = self.highlightColor;
            break;
        case UIControlStateNormal:
            self.backgroundColor = self.normalColor;
            break;
            
        default:
            break;
    }
}

@end
