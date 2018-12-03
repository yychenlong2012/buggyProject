//
//  ShareAnimationView.m
//  writer
//
//  Created by wuning on 16/3/31.
//  Copyright © 2016年 writer. All rights reserved.
//

#import "ShareAnimationView.h"
#import "ShareItemView.h"
//#import "ShareManager.h"

#define  HH  176
#define SCREENWIDTH      [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT    [UIScreen mainScreen].bounds.size.height

@interface ShareAnimationView()

@property (nonatomic,strong) UIView *largeView;
@property (nonatomic) CGFloat count;
@property (nonatomic,strong) UIButton *chooseBtn;

@end

@implementation ShareAnimationView

- (id)initWithTitleArray:(NSArray *)titlearray  picarray:(NSArray *)picarray
{
   self = [super init];
   if (self) {
      self.frame = [UIScreen mainScreen].bounds;
      self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
      self.largeView = [[UIView alloc]init];
      [_largeView  setFrame:CGRectMake(0, SCREENHEIGHT-bottomSafeH ,SCREENWIDTH,HH)];
      [_largeView setBackgroundColor:[UIColor whiteColor]];
      [self addSubview:_largeView];
      
      __weak typeof (self) selfBlock = self;
      UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc]initWithTarget:selfBlock action:@selector(dismiss)];
      [selfBlock addGestureRecognizer:dismissTap];
      
      _chooseBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, HH - 50, SCREENWIDTH, 50)];
      [_chooseBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
      [_chooseBtn setBackgroundColor:[UIColor whiteColor]];
      [_chooseBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
      [_chooseBtn addTarget:self action:@selector(chooseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
      [self.largeView addSubview:_chooseBtn];
      
      UIView *line = [[UIView alloc]initWithFrame:CGRectMake(15, HH - 51, SCREENWIDTH - 30, 1)];
      [line setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
      [self.largeView addSubview:line];
      
      for (int i = 0; i < 4; i ++) {
         ShareItemView *rr = [[ShareItemView alloc]initWithFrame:CGRectMake(i %4 *(SCREENWIDTH / 4), 20, SCREENWIDTH/4, 90)];
         rr.tag = 10 + i;
         rr.sheetBtn.tag = i + 1;
         [rr.sheetBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",picarray[i]]] forState:UIControlStateNormal];
         [rr.sheetLab setText:[NSString stringWithFormat:@"%@",titlearray[i]]];
         
         [rr selectedIndex:^(NSInteger index) {
            [self dismiss];
            [self selectItem:index];
         }];
         [self.largeView addSubview:rr];
      }
   }
   return self;
}

-(void)show
{
   UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
   [window addSubview:self];
   
   [UIView animateWithDuration:0.2 animations:^{
      [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
       self->_largeView.transform = CGAffineTransformMakeTranslation(0,  - HH);
   } completion:^(BOOL finished) {
   }];
   for (int i = 0; i < 4; i ++) {
      CGPoint location = CGPointMake(SCREENWIDTH/4* (i%4) + (SCREENWIDTH/8), 45);
      ShareItemView *rr =  (ShareItemView *)[self viewWithTag:10 + i];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i*0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [UIView animateWithDuration:1.0 delay:0.1 usingSpringWithDamping:0.8 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
            rr.center=location; //CGPointMake(160, 284);
         } completion:nil];
      });
   }
}

#pragma mark -- 点击选中Item
- (void)selectItem:(NSInteger)index
{
   NSLog(@"click shareView index ==%ld",(long)index);
   switch (index) {
      case 1:
      {
//         [ShareManager shareToWeChatMoment];
         self.block(index);
//          [leanCloudMgr event:YOUZI_ShareWeChatMoments];
      }
         break;
      case 2:
      {
//         [ShareManager shareToWeChatFriends];
         self.block(index);
//          [leanCloudMgr event:YOUZI_ShareWeChatFriends];
      }
         break;
      case 3:
      {
//         [ShareManager shareToQQFriends];
         self.block(index);
//          [leanCloudMgr event:YOUZI_ShareQQ];
      }
         break;
      case 4:
      {
//         [ShareManager shareToWeibo];
//          [leanCloudMgr event:YOUZI_ShareSina];
         self.block(index);
      }
         break;
      default:
         break;
   }
}

- (void)shareWithBlock:(ClickBlock)block
{
   self.block = block;
}

- (void)chooseBtnClick:(UIButton *)button
{
   [self dismiss];
}

- (void)tap:(UITapGestureRecognizer *)tapG {
   [self dismiss];
}

- (void)dismiss {
   [UIView animateWithDuration:0 animations:^{
      [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
       self->_largeView.transform = CGAffineTransformIdentity;
   } completion:^(BOOL finished) {
      [self removeFromSuperview];
   }];
}
@end
