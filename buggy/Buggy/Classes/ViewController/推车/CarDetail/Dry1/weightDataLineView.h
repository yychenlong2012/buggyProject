//
//  weightDataLineView.h
//  Buggy
//
//  Created by goat on 2019/2/25.
//  Copyright © 2019 ningwu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define LandScape 50.0    //每一个点的横向距离
#define NumberOfRow 5     //行数
#define RowWeight 50.0    //每一行表示50斤
#define maxWeight (RowWeight * NumberOfRow)   //设置体重上限


@interface weightDataLineView : UIView
@property (nonatomic,strong) NSArray *pointArray;
@end

NS_ASSUME_NONNULL_END
