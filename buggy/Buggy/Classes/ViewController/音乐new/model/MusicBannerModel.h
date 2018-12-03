//
//  MusicBannerModel.h
//  Buggy
//
//  Created by goat on 2018/6/12.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MusicAlbumModel;

@interface MusicBannerModel : NSObject
@property (nonatomic,copy) NSString *type;   //banner类别  文章  歌曲
@property (nonatomic,copy) NSString *imgurl; //banner图片
@property (nonatomic,copy) NSString *title;  //banner标题
@property (nonatomic,copy) NSString *url;    //banner链接
@property (nonatomic,assign)NSInteger musictype;  //暂定
@property (nonatomic,copy) NSString *album;  //如果banner是专辑
@property (nonatomic,copy) NSString *date;
@property (nonatomic,assign)NSInteger articles_id;

//如果是音乐banner才会有的数据
@property (nonatomic,copy) NSString *file;
@property (nonatomic,copy) NSString *imageface;
@property (nonatomic,copy) NSString *albumaddress;
@property (nonatomic,copy) NSString *describe;      //专辑描述

//@property (nonatomic,strong) MusicAlbumModel *albuminfo;   //专辑信息
-(MusicAlbumModel *)backMusicAlbumModel;

@end


//"date": "0000-00-00 00:00:00",
//"articles_id": null,
//"musictype": "5",
//"type": "song",
//"imgurl": "http://192.168.10.106/Tp/Uploads/2018-11-20/4b54deef351712605977.png",
//"title": "爸妈小时候听的故事",
//"url": "",
//"album": "5b2b432ffe88c20034d238df",
//"file": "http://192.168.10.106/Tp/Uploads/2018-11-20/4b54deef351712605977.png",
//"albumaddress": "MusicStory",
//"describe": "我们一起走进爸妈们小时候的故事，了解属于他们最珍贵最童真的童年。"


