//
//  ShareItemView.m
//  writer
//
//  Created by wuning on 16/3/31.
//  Copyright © 2016年 writer. All rights reserved.
//

#import "ShareItemView.h"

@implementation ShareItemView

- (instancetype)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      self.sheetBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 43, 43)];
      self.sheetBtn.clipsToBounds = YES;
      self.sheetBtn.layer.cornerRadius = 21.5;
      [self.sheetBtn setCenter:CGPointMake(self.frame.size.width / 2, 50)];
      
      self.sheetLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, self.frame.size.width, 40)];
      [self addSubview:self.sheetLab];
      [self.sheetBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
      
      [self.sheetLab setTextAlignment:NSTextAlignmentCenter];
      self.sheetLab.font = [UIFont systemFontOfSize:12];
      [self addSubview:self.sheetBtn];
   }
   return self;
}

- (void)btnClick:(UIButton *)btn
{
   self.block(self.sheetBtn.tag);
}

- (void)selectedIndex:(RRLBlock)block
{
   self.block = block;
}

@end
