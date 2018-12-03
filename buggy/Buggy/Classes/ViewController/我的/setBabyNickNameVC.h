//
//  setBabyNickNameVC.h
//  Buggy
//
//  Created by goat on 2018/6/2.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "BaseVC.h"

@interface setBabyNickNameVC : BaseVC
@property (nonatomic,strong) UILabel *topLabel;   //标题
//@property (nonatomic,strong) AVObject *BabyObject;  //所要修改的宝宝对象
@property (nonatomic,strong) babyInfoModel *addBabyModel;   //添加宝贝
@property (nonatomic,strong) NSString *babyId;

@property (nonatomic,assign) BOOL isResetData;      //是用于修改数据还是添加数据
@property (nonatomic,weak) id sourceVC;             //用于跳转

@property (nonatomic,strong) UILabel *skip;         //跳过设置
@end
