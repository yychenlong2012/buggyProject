//
//  ShareItemView.h
//  writer
//
//  Created by wuning on 16/3/31.
//  Copyright © 2016年 writer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RRLBlock) (NSInteger index);

@interface ShareItemView : UIView

@property (nonatomic, strong)UIButton *sheetBtn;
@property (nonatomic, strong)UILabel *sheetLab;
@property (nonatomic, copy)RRLBlock block;

- (void)selectedIndex:(RRLBlock)block;

@end
