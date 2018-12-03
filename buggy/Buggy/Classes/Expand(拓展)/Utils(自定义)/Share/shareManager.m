//
//  shareManager.m
//  Buggy
//
//  Created by ningwu on 16/5/23.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "shareManager.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import "WeiboSDK+Statistics.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import "MainModel.h"
#import "UIImage+COSAdtions.h"

#define WEIBOAPPKEY @"3074598193"
#define WEIBOAPPSECREAT @"811403f7ef7c35ff14478b960e7188ba"
#define WEIBOREDIRECTURI @"http://sns.whalecloud.com/sina2/callback"

#define WEIXINAPPID @"wxe4636c9399ddee3f"
#define WEIXINSECRET @"ef46c5de4156f80d4fc4f7c52cacd657"

#define QQAPPID @"1105156999"
#define QQAPPKEY @"fxd38ZT4LsU5RbFP"

@implementation shareManager

+ (void)shareToQQFriends:(UIImage *)image
{
    [MainModel model].openURLType = 1;
    if (![TencentOAuth iphoneQQInstalled]) {
        [MBProgressHUD showToast:@"您的没有安装QQ或者版本太低"];
        return;
    }
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc]initWithAppId:QQAPPID andDelegate:self];
    NSData *data = UIImagePNGRepresentation(image);
    NSData *preData = UIImageJPEGRepresentation(image, 0.4);
    QQApiImageObject *object = [QQApiImageObject objectWithData: data previewImageData:preData title:@"三爸育儿" description:@"身高信息"];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:object];
    [QQApiInterface sendReq:req];
}

+ (void)shareToQZone:(UIImage *)image
{
     [MainModel model].openURLType = 1;
    if (![TencentOAuth iphoneQQInstalled]) {
        [MBProgressHUD showToast:@"您的没有安装QQ或者版本太低"];
        return;
    }
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc]initWithAppId:QQAPPID andDelegate:self];
    NSData *data = UIImagePNGRepresentation(image);
    NSData *preData = UIImageJPEGRepresentation(image, 0.4);
    QQApiImageObject *object = [QQApiImageObject objectWithData: data previewImageData:preData title:@"三爸育儿" description:@"身高信息"];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:object];
    [QQApiInterface SendReqToQZone:req];
}

+ (void)shareToWeChatMoment:(UIImage *)image
{
    [MainModel model].openURLType = 2;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"三爸育儿";
    message.description = @"三爸育儿智能婴儿车！";
    NSData *data = [UIImage getData:image limit:5];
    UIImage *thumbImage = [UIImage imageWithData:data];
    thumbImage = [thumbImage getScaledImage:0.3];
    [message setThumbImage:thumbImage];
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = UIImagePNGRepresentation(image);
    message.mediaObject = imageObject;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = 1;
    [WXApi sendReq:req];
    if (![WXApi openWXApp]) {
        [MBProgressHUD showToast:@"您的没有安装微信或者版本太低"];
    }
}

+ (void)shareToWeChatFriends:(UIImage *)image
{
    [MainModel model].openURLType = 2;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"三爸育儿";
    message.description = @"三爸育儿智能婴儿车！";
    NSData *data = [UIImage getData:image limit:5];
    UIImage *thumbImage = [UIImage imageWithData:data];
    thumbImage = [thumbImage getScaledImage:0.3];
    [message setThumbImage:thumbImage];
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = UIImagePNGRepresentation(image);
    message.mediaObject = imageObject;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = 0;
    [WXApi sendReq:req];
    if (![WXApi openWXApp]) {
        [MBProgressHUD showToast:@"您的没有安装微信或者版本太低"];
    }
}

+ (void)shareToWeibo:(UIImage *)image
{
    [MainModel model].openURLType = 3;
    if (![WeiboSDK isCanShareInWeiboAPP]) {
        [MBProgressHUD showToast:@"您的没有安装微博或者版本太低"];
        return;
    }
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = WEIBOREDIRECTURI;
    authRequest.scope = @"all";
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = @"三爸育儿智能婴儿车！";
    
    WBImageObject *imageObject = [WBImageObject object];
    imageObject.imageData = UIImagePNGRepresentation(image);
    message.imageObject = imageObject;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
    [WeiboSDK sendRequest:request];
}

@end
