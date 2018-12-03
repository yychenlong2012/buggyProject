//
//  MusicLikeModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/4/22.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BaseModel.h"

@interface MusicLikeModel : BaseModel

//@property (nonatomic ,assign) int typeNumber;

@property (nonatomic ,copy) NSString *musicName;

@property (nonatomic ,strong) AVFile  *musicFiles;

@property (nonatomic ,copy) NSString *url;

@property (nonatomic ,strong) AVFile *musicImage;

@end
