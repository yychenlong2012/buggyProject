//
//  musicModel.h
//  Buggy
//
//  Created by goat on 2018/11/13.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface musicModel : NSObject

@property (nonatomic,copy) NSString *imageurl;
@property (nonatomic,copy) NSString *lyricurl;
@property (nonatomic,copy) NSString *musicname;
@property (nonatomic,copy) NSString *musicurl;
@property (nonatomic,copy) NSString *time;

@property (nonatomic,assign) NSInteger musicid;
@property (nonatomic,assign) NSInteger musictype;

@end

NS_ASSUME_NONNULL_END


//imageurl = "https://lc-1R2oS0W0.cn-n1.lcfile.com/12935023063147cf2d74.png";
//lyricurl = "";
//musicid = 18010206;
//musicname = "\U6c5f\U96ea";
//musictype = 1;
//musicurl = "https://lc-1R2oS0W0.cn-n1.lcfile.com/f63fa8e5e7fe389762d5.mp3";
//time = "01:08";
