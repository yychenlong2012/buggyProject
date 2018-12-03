//
//  MusicLocalModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/4/22.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BaseModel.h"
#import <AVFile.h>
@interface MusicLocalModel : BaseModel

@property (nonatomic ,copy) NSString *musicName;

@property (nonatomic ,strong) AVFile *musicFiles;

@property (nonatomic ,copy) NSString *orderDate;

@property (nonatomic ,strong) AVFile *musicImage;

@property (nonatomic ,assign) NSInteger typeNumber;

@end
