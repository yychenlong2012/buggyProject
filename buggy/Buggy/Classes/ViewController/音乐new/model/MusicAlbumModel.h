//
//  MusicAlbumModel.h
//  Buggy
//
//  Created by goat on 2018/6/15.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicAlbumModel : NSObject
//@property (nonatomic,strong) AVFile *imageFace;     //专辑图片   不知道是AVFile类型还是nsstring类型

@property (nonatomic,copy) NSString *file;
@property (nonatomic,copy) NSString *imageface;
@property (nonatomic,copy) NSString *musictype;
@property (nonatomic,copy) NSString *albumaddress;  //专辑歌曲后台表名
@property (nonatomic,copy) NSString *title;         //专辑名
@property (nonatomic,copy) NSString *describe;      //专辑描述
@end


//{
//    albumaddress = MusicStory;
//    describe = "\U6211\U4eec\U4e00\U8d77\U8d70\U8fdb\U7238\U5988\U4eec\U5c0f\U65f6\U5019\U7684\U6545\U4e8b\Uff0c\U4e86\U89e3\U5c5e\U4e8e\U4ed6\U4eec\U6700\U73cd\U8d35\U6700\U7ae5\U771f\U7684\U7ae5\U5e74\U3002";
//    file = "https://lc-1R2oS0W0.cn-n1.lcfile.com/4b54deef351712605977.png";
//    imageface = "https://lc-1r2os0w0.cn-n1.lcfile.com/4b54deef351712605977.png";
//    musictype = 5;
//    title = "\U7238\U5988\U5c0f\U65f6\U5019\U542c\U7684\U6545\U4e8b";
//},

