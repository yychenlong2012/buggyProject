//
//  MusicBannerModel.m
//  Buggy
//
//  Created by goat on 2018/6/12.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "MusicBannerModel.h"
#import "MusicAlbumModel.h"
//#import <objc/runtime.h>

@implementation MusicBannerModel

-(MusicAlbumModel *)backMusicAlbumModel{
    MusicAlbumModel *model = [[MusicAlbumModel alloc] init];
    model.file = self.imgurl;
    model.imageface = self.file;
    model.musictype = [NSString stringWithFormat:@"%ld",self.musictype];
    model.albumaddress = self.albumaddress;
    model.title = self.title;
    model.describe = self.describe;
    return model;
}

//+ (NSDictionary *)objectClassInArray{
//    return @{
//             @"albuminfo" : @"MusicAlbumModel"
//            };
//}

//-(MusicAlbumModel *)albumModel{
//    if (_album == nil || [_album isKindOfClass:[NSNull class]]) {
//        return nil;
//    }
//    if (![_album isKindOfClass:[AVObject class]]) {
//        return nil;
//    }
//    MusicAlbumModel *albumModel = [[MusicAlbumModel alloc] init];
//    albumModel.imageFace = _album[@"imageFace"];
//    albumModel.musicType = [_album[@"musicType"] integerValue];
//    albumModel.albumAddress = _album[@"albumAddress"];
//    albumModel.title = _album[@"title"];
//    albumModel.describe = _album[@"describe"];
//    albumModel.bgColor = _album[@"bgColor"];
//    
//    return albumModel;
//}

//- (void)encodeWithCoder:(NSCoder *)coder
//{
//    //告诉系统归档的属性是哪些
//    unsigned int count = 0;//表示对象的属性个数
//    Ivar *ivars = class_copyIvarList([MusicBannerModel class], &count);
//    for (int i = 0; i<count; i++) {
//        //拿到Ivar
//        Ivar ivar = ivars[i];
//        const char *name = ivar_getName(ivar);//获取到属性的C字符串名称
//        NSString *key = [NSString stringWithUTF8String:name];//转成对应的OC名称
//        //归档 -- 利用KVC
//        [coder encodeObject:[self valueForKey:key] forKey:key];
//    }
//    free(ivars);
//}
//
//- (instancetype)initWithCoder:(NSCoder *)coder
//{
//    self = [super init];
//    if (self) {
//        //解档
//        unsigned int count = 0;
//        Ivar *ivars = class_copyIvarList([MusicBannerModel class], &count);
//        for (int i = 0; i<count; i++) {
//            //拿到Ivar
//            Ivar ivar = ivars[i];
//            const char *name = ivar_getName(ivar);
//            NSString *key = [NSString stringWithUTF8String:name];
//            //解档
//            id value = [coder decodeObjectForKey:key];
//            // 利用KVC赋值
//            [self setValue:value forKey:key];
//        }
//        free(ivars);
//    }
//    return self;
//}
@end
