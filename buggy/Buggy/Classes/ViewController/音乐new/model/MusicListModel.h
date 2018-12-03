//
//  MusicListModel.h
//  Buggy
//
//  Created by 孟德林 on 2017/4/10.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "BaseModel.h"

@interface MusicListModel : BaseModel

//@property (nonatomic ,assign) int typeNumber;
    
@property (nonatomic ,copy) NSString *musicName;    //歌名       春  数据库中的名字

//@property (nonatomic ,copy) NSString *musicFileName;//歌曲文件名  兔小贝儿歌001春.mp3

//@property (nonatomic ,strong) AVFile  *musicFiles;

@property (nonatomic ,assign) int musicOrder;

//@property (nonatomic ,strong) AVFile *musicImage;

#pragma mark - 3.0版本添加

@property (nonatomic ,copy) NSString *time;    //时长

@property (nonatomic ,assign) NSInteger musicId;   //歌曲唯一标识

@property (nonatomic ,copy) NSString *musicUrl;   //音乐url

@property (nonatomic ,copy) NSString *imageUrl;   //图片url

@property (nonatomic ,copy) NSString *lyricUrl;   //歌词url

@property (nonatomic ,assign) NSInteger musicType;  //专辑子分类

@end
