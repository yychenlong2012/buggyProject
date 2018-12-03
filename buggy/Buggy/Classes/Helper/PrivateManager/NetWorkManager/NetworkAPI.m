//
//  NetworkAPI.m
//  Buggy
//
//  Created by goat on 2018/11/12.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import "NetworkAPI.h"
#import "ScreenMgr.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "AppDelegate.h"
#import "WeiboSDK.h"
#import "CarA4PushDataModel.h"
#import "NetWorkStatus.h"

//开发版
#define API_HEADER @"http://192.168.10.106"
//正式版
//#define API_HEADER @"http://47.92.221.199"
#define HOME_API @""API_HEADER"/Tp/index.php/App/Index/index.html"                      //首页数据
#define PUNCH_LIST @""API_HEADER"/Tp/index.php/App/Index/punch_list.html"               //打卡列表
#define HISTORY_PUNCH @""API_HEADER"/Tp/index.php/App/Index/historical_data.html"       //用户历史打卡记录
#define TRAVEL_ANALYZE @""API_HEADER"/Tp/index.php/App/Index/week_analysis.html"        //出行周分析
#define DAY_MILEAGE @""API_HEADER"/Tp/index.php/App/Index/day_mileage.html"             //日里程
#define DAY_MILEAGE_SUBS @""API_HEADER"/Tp/index.php/App/Index/day_mileage_data.html"           //日里程分段数据
#define MONTH_WEEK_FREQUENCY @""API_HEADER"/Tp/index.php/App/Index/frequency_week_month.html"   //周频率 月频率
#define UPDATE_WEATHER @""API_HEADER"/Tp/index.php/App/Index/update_weather.html"       //更新天气
#define BANNER_DATA @""API_HEADER"/Tp/index.php/App/music/music_banner.html"            //首页轮播
#define HOT_MUSIC @""API_HEADER"/Tp/index.php/App/music/hot_music.html"                 //热门音乐
#define RECOMMEND_MUSIC @""API_HEADER"/Tp/index.php/App/music/recommend_music.html"     //推荐音乐
#define ALL_MUSIC @""API_HEADER"/Tp/index.php/App/music/all_music.html"                 //全部音乐
#define SCENE_MUSIC @""API_HEADER"/Tp/index.php/App/music/scenes_list.html"             //场景音乐
#define ALBUM_LIST @""API_HEADER"/Tp/index.php/App/music/album_list.html"               //专辑音乐
#define COLLECT_DOWN @""API_HEADER"/Tp/index.php/App/music/collected_down.html"         //收藏与下载
#define BABY_INFO @""API_HEADER"/Tp/index.php/App/user/babyinfo.html"                   //宝宝信息
#define USER_INFO @""API_HEADER"/Tp/index.php/App/user/userinfo.html"                   //用户头像昵称信息
#define BABY_LIST @""API_HEADER"/Tp/index.php/App/user/babylist.html"                   //宝宝列表
#define DEVICE_LIST @""API_HEADER"/Tp/index.php/App/user/deviceuuid_list.html"          //已绑定的推车列表
#define UPDATE_USER_INFO @""API_HEADER"/Tp/index.php/App/user/update_user.html"         //更新用户信息
#define UPDATE_BABY_INFO @""API_HEADER"/Tp/index.php/App/user/update_baby.html"         //更新宝宝信息
#define DEL_BABY @""API_HEADER"/Tp/index.php/App/user/del_baby.html"                    //删除宝宝信息
#define DEL_DEVICE @""API_HEADER"/Tp/index.php/App/user/del_device.html"                //删除推车设备，解绑
#define FEED_BACK @""API_HEADER"/Tp/index.php/App/user/feed_back.html"                  //用户反馈
#define INSTRUCTIONS @""API_HEADER"/Tp/index.php/App/user/instructions.html"            //使用说明
#define USER_PROTOCOL @""API_HEADER"/Tp/index.php/App/user/userprotocol.html"           //用户协议
#define UPDATE_DEVICE_NAME @""API_HEADER"/Tp/index.php/App/user/update_devicename.html" //更新设备名
#define USER_TRAVEL_INFO @""API_HEADER"/Tp/index.php/App/user/get_device_details.html"  //获取用户出行里程
#define BIND_DEVICE @""API_HEADER"/Tp/index.php/App/public/bind_device.html"            //绑定推车
#define REPAIR_ONCE @""API_HEADER"/Tp/index.php/App/Public/add_hardwareinfo.html"       //一键修复
#define UPDATE_AVERAGE_SPEED @""API_HEADER"/Tp/index.php/App/public/update_speed_mileage.html"     //上传总里程和平均速度今日里程
#define UPDATE_TRAVEL_ONCE @""API_HEADER"/Tp/index.php/App/public/update_travelonce.html"          //上传分段里程
#define NEWEST_MILEAGE @""API_HEADER"/Tp/index.php/App/public/get_new_mileage.html"                //获取最新的一条分段里程数据
#define SLEEP_TIMES @""API_HEADER"/Tp/index.php/App/public/update_use_times.html"    //上传关机次数
#define SENSITIVITY @""API_HEADER"/Tp/index.php/App/public/update_sensitivity.html"  //上传刹车灵敏度
#define ADD_BABY @""API_HEADER"/Tp/index.php/App/user/add_baby.html"                 //添加宝贝
#define APP_CONTROL @""API_HEADER"/Tp/index.php/App/Index/get_control.html"          //获取版本 已绑定的蓝牙列表 设备类型列表
#define CHECK_LOGIN @""API_HEADER"/Tp/index.php/App/Login/check_login.html"          //验证登录状态
#define REGISTER @""API_HEADER"/Tp/index.php/App/Login/register.html"                //注册
#define LOGIN @""API_HEADER"/Tp/index.php/App/Login/index.html"                      //手机登录
#define RESET_PASSWORD @""API_HEADER"/Tp/index.php/App/Login/reset_passwd.html"      //修改密码
#define LOGOUT @""API_HEADER"/Tp/index.php/App/Login/loginout.html"                  //退出登录
#define CRASH_LOG @""API_HEADER"/Tp/index.php/App/public/add_crash.html"             //崩溃信息


#define NSLog(format,...) printf("%s",[[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])
@interface NetworkAPI()

@property (nonatomic,strong) TencentOAuth *tencent;
@end
@implementation NetworkAPI

static NetworkAPI* _instance = nil;

+(instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    return _instance ;
}

-(AFHTTPSessionManager *)manager{
    if (_manager == nil) {
        _manager = [AFHTTPSessionManager manager];
        [_manager.requestSerializer setValue:KUserDefualt_Get(USER_LOGIN_TOKEN)==nil?@"":KUserDefualt_Get(USER_LOGIN_TOKEN) forHTTPHeaderField:@"Token"];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",@"image/jpg",@"application/x-javascript",@"keep-alive", nil];
//        [_manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        _manager.requestSerializer.timeoutInterval = 10.f;
//        [_manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        //允许不进行证书验证
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
//        securityPolicy.validatesDomainName = NO;
//        securityPolicy.allowInvalidCertificates = YES;
//        _manager.securityPolicy = securityPolicy;
        
        //设置response将要缓存时的回调 在这里修改响应头的缓存字段信息 系统将按照缓存缓存字段设置缓存
        [_manager setDataTaskWillCacheResponseBlock:^NSCachedURLResponse * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSCachedURLResponse * _Nonnull proposedResponse) {
            NSLog(@"%@",[dataTask.currentRequest.URL absoluteString]);
            NSDictionary *dict = @{
//                                   HOME_API:@"1",
//                                    PUNCH_LIST:@"1",
                                    BANNER_DATA:@"1",
                                    HOT_MUSIC:@"1",
                                    RECOMMEND_MUSIC:@"1",
                                    ALL_MUSIC:@"1",
                                    SCENE_MUSIC:@"1",
                                    ALBUM_LIST:@"1",
                                    DEVICE_LIST:@"1",
                                    INSTRUCTIONS:@"1",
                                    USER_PROTOCOL:@"1"
                                 };
            NSString *urlStr = [[dataTask.currentRequest.URL absoluteString] componentsSeparatedByString:@"?"].firstObject;    //去掉url后面的参数
            if ([dict[urlStr] isEqualToString:@"1"]) {
                NSURLResponse *response = proposedResponse.response;
                NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse*)response;
                NSDictionary *headers = HTTPResponse.allHeaderFields;
                NSCachedURLResponse *cachedResponse;
                //这里就可以针对Cache-Control进行更改，然后直接我们通过某方法获取NSCachedURLResponse的时候就可以先去判断下头域信息
                NSMutableDictionary *modifiedHeaders = headers.mutableCopy;
                [modifiedHeaders setObject:@"max-age=604800" forKey:@"Cache-Control"];
                NSHTTPURLResponse *modifiedResponse = [[NSHTTPURLResponse alloc] initWithURL:HTTPResponse.URL statusCode:HTTPResponse.statusCode HTTPVersion:@"HTTP/1.1" headerFields:modifiedHeaders];
                cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:modifiedResponse data:proposedResponse.data userInfo:proposedResponse.userInfo storagePolicy:proposedResponse.storagePolicy];
                NSLog(@"%@",modifiedHeaders);
                return cachedResponse;
            }
            return nil;    //返回nil表示不缓存
        }];
        
        //创建缓存文件夹
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:CACHE_PATH]) {
            [manager createDirectoryAtPath:CACHE_PATH withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _manager;
}

//重新设置token字段
-(void)resetHTTPHeader{
    [self.manager.requestSerializer setValue:KUserDefualt_Get(USER_LOGIN_TOKEN)==nil?@"":KUserDefualt_Get(USER_LOGIN_TOKEN) forHTTPHeaderField:@"Token"];
}

#pragma mark - 注册登录
//验证登录状态
-(void)uploadRefreshToken{
    NSDictionary *dict = @{ @"refresh_token":KUserDefualt_Get(USER_REFRESH_TOKEN) };
    [self.manager POST:CHECK_LOGIN parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"验证登录状态:%@",dict);
        switch ([dict[@"status"] integerValue]) {
            case 8:{
                KUserDefualt_Set(@"", USER_LOGIN_TOKEN);                 //需要重新登录
                KUserDefualt_Set(@"", USER_REFRESH_TOKEN);
                KUserDefualt_Set(@"", USER_ID_NEW);
                [self resetHTTPHeader];
                [MBProgressHUD showSuccess:dict[@"msg"]];
                [SCREENMGR changeToLoginScreen];
            }break;
            case 7:{
                NSDictionary *data = dict[@"data"];                    //是刷新token之后到的登录成功则保存新token
                KUserDefualt_Set(data[@"token"], USER_LOGIN_TOKEN);
                KUserDefualt_Set(data[@"refresh_token"], USER_REFRESH_TOKEN);
                [MBProgressHUD showSuccess:dict[@"msg"]];               //登录成功
                [SCREENMGR showMainScreen];
                //保存用户id
                if ([data isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *userInfo = data[@"userinfo"];
                    if ([userInfo isKindOfClass:[NSDictionary class]]) {
                        KUserDefualt_Set(userInfo[@"uid"]==nil?@"":userInfo[@"uid"], USER_ID_NEW);
                        //保存用户信息
                        self.userInfo = [userInfoModel mj_objectWithKeyValues:data[@"userinfo"]];
                    }
                }
            }break;
            default:{
                KUserDefualt_Set(@"", USER_LOGIN_TOKEN);
                KUserDefualt_Set(@"", USER_REFRESH_TOKEN);
                [MBProgressHUD showError:dict[@"msg"]];
                [SCREENMGR changeToLoginScreen];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showError:@"网络错误！"];
    }];
}

//token检验
-(void)checkToken{
    [self.manager POST:CHECK_LOGIN parameters:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"token检验%@%@",dict[@"msg"],dict);
        switch ([dict[@"status"] integerValue]) {
            case 9:
                [self uploadRefreshToken];      //刷新token
                break;
            case 7:{
                [MBProgressHUD showSuccess:dict[@"msg"]];         //登录成功
                [SCREENMGR showMainScreen];
                //保存用户id
                NSDictionary *data = dict[@"data"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *userInfo = data[@"userinfo"];
                    if ([userInfo isKindOfClass:[NSDictionary class]]) {
                        KUserDefualt_Set(userInfo[@"uid"]==nil?@"":userInfo[@"uid"], USER_ID_NEW);
                        //保存用户信息
                        self.userInfo = [userInfoModel mj_objectWithKeyValues:data[@"userinfo"]];
                    }
                }
            }break;
            default:{
                KUserDefualt_Set(@"", USER_LOGIN_TOKEN);
                KUserDefualt_Set(@"", USER_REFRESH_TOKEN);
                [MBProgressHUD showError:dict[@"msg"]];
                [SCREENMGR changeToLoginScreen];
            }
        }
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showError:@"网络错误！"];
   }];
}

//手机登录
-(void)loginWithMobilePhone:(NSString *)phone password:(NSString *)password callback:(statusBlock _Nonnull)callback{
    NSDictionary *dict = @{  @"phoneNumber":phone==nil?@"":phone,
                            @"password":password==nil?@"":password };
    [self.manager POST:LOGIN parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
       NSLog(@"手机登录：%@ 类型：%@\n",dict[@"msg"],dict);
       if ([dict[@"status"] integerValue] == 7) {
           [MBProgressHUD showSuccess:dict[@"msg"]];    //登录成功
           //保存token
           NSDictionary *data = dict[@"data"];
           if ([data isKindOfClass:[NSDictionary class]]) {
               KUserDefualt_Set(data[@"token"], USER_LOGIN_TOKEN);
               KUserDefualt_Set(data[@"refresh_token"], USER_REFRESH_TOKEN);
               [self resetHTTPHeader];
               //保存用户id
               NSDictionary *userInfo = data[@"userinfo"];
               if ([userInfo isKindOfClass:[NSDictionary class]]) {
                   KUserDefualt_Set(userInfo[@"uid"]==nil?@"":userInfo[@"uid"], USER_ID_NEW);
               }
               //保存用户信息
               self.userInfo = [userInfoModel mj_objectWithKeyValues:data[@"userinfo"]];
           }
           callback(YES,nil);
       }else{
           [MBProgressHUD showError:dict[@"msg"]];
       }
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          callback(NO,error);
   }];
}

//手机注册
-(void)registerWithMobilePhone:(NSString *)phone password:(NSString *)password callback:(statusBlock _Nonnull)callback{
    NSDictionary *dict = @{   @"phoneNumber":phone==nil?@"":phone,
                             @"password":password==nil?@"":password  };
    [self.manager POST:REGISTER parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
       NSLog(@"手机注册：%@ 类型：%@\n",dict[@"msg"],dict);
       if ([dict[@"status"] integerValue] == 7) {
           [MBProgressHUD showSuccess:dict[@"msg"]];    //登录成功
           //保存token
           NSDictionary *data = dict[@"data"];
           if ([data isKindOfClass:[NSDictionary class]]) {
               KUserDefualt_Set(data[@"token"], USER_LOGIN_TOKEN);
               KUserDefualt_Set(data[@"refresh_token"], USER_REFRESH_TOKEN);
               [self resetHTTPHeader];
           }
            callback(YES,nil);
       }else{
           [MBProgressHUD showError:dict[@"msg"]];
       }
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           callback(NO,error);
   }];
}

//重置密码
-(void)resetPassword:(NSString *)password mobilePhone:(NSString *)phone callback:(statusBlock _Nonnull)callback{
    NSDictionary *dict = @{   @"phoneNumber":phone==nil?@"":phone,
                             @"password":password==nil?@"":password  };
    [self.manager POST:RESET_PASSWORD parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"重置密码：%@ 类型：%@\n",dict[@"msg"],dict);
        if ([dict[@"status"] integerValue] == 0) {
            [MBProgressHUD showSuccess:@"密码修改成功"];
                callback(YES,nil);
        }else{
            [MBProgressHUD showError:dict[@"msg"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           callback(NO,error);
    }];
}

//退出登录
-(void)logoutWithCallback:(statusBlock _Nonnull)callback{
    NSDictionary *dict = @{ @"refresh_token":KUserDefualt_Get(USER_REFRESH_TOKEN)==nil?@"":KUserDefualt_Get(USER_REFRESH_TOKEN) };
    [self.manager POST:LOGOUT parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"退出登录：%@ 类型：%@\n",dict[@"msg"],dict);
        if ([dict[@"status"] integerValue] == 0) {
            [MBProgressHUD showSuccess:@"退出登录成功"];
            KUserDefualt_Set(@"", USER_LOGIN_TOKEN);    //退出登录 清空token
            KUserDefualt_Set(@"", USER_REFRESH_TOKEN);
            KUserDefualt_Set(@"", USER_ID_NEW);
            [self resetHTTPHeader];
            callback(YES,nil);
        }else{
            [MBProgressHUD showError:dict[@"msg"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

#pragma mark - 微信登录
-(void)getWeiXInCode{   //构造SendAuthReq结构体
    KUserDefualt_Set(@"2", THIRD_PARTY_LOGIN_TYPE);
    SendAuthReq* req = [[SendAuthReq alloc] init ];
    req.scope = @"snsapi_userinfo";
    req.state = @"123";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

//请求微信token
-(void)requestWeiXinTokenAndIdWithCode:(NSString *)code{
    NSString *urlstr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WEIXINAPPID,WEIXINSECRET,code];
    [self.manager GET:urlstr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"%@",dict);
        //这里可以获得openid  token  过期时间
        //如果需要获取用户的相信信息 需要使用token调用以下接口  GET
        //https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"111");
    }];
}

#pragma mark - QQ登录
-(void)loginWithQQ{
//    AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
    KUserDefualt_Set(@"1", THIRD_PARTY_LOGIN_TYPE);
    self.tencent = [[TencentOAuth alloc] initWithAppId:QQAPPID andDelegate:self];
    [self.tencent authorize:@[@"get_user_info", @"get_simple_userinfo", @"add_t"] inSafari:NO];
}
-(void)tencentDidLogin{
    DLog(@"%@",self.tencent.accessToken);
    DLog(@"%@",self.tencent.openId);
}
-(void)tencentDidNotLogin:(BOOL)cancelled{
    
}
-(void)tencentDidNotNetWork{
    //    _labelTitle.text=@"无网络连接，请设置网络";
}

#pragma mark - 微博登录
-(void)loginWithWeiBo{
    KUserDefualt_Set(@"3", THIRD_PARTY_LOGIN_TYPE);
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = WEIBOREDIRECTURI;
    request.scope = @"all";
    request.userInfo = nil;
    [WeiboSDK sendRequest:request];
}

#pragma mark - 上传天气
-(void)uploadWeahter:(NSString *)weather airQuality:(NSString *)airQuality callback:(statusBlock _Nonnull)callback{
    NSDictionary *parma = @{  @"weather":weather==nil?@"":weather,
                              @"airQuality":airQuality==nil?@"":airQuality  };
    [self.manager POST:UPDATE_WEATHER parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"上传天气：%@ 类型：%@\n",dict[@"msg"],dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}


#pragma mark - 首页
-(void)requestHomeData:(HomeDataBlock _Nonnull)homeData{
    [self.manager POST:HOME_API parameters:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"HomeData：%@ 类型：%@\n",dict[@"msg"],dict);
        homeDataModel *model = [homeDataModel mj_objectWithKeyValues:dict[@"data"]];
        homeData(model,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        homeData(nil,error);
    }];
}

//打卡列表
-(void)requestPunchListWithPage:(NSString *)page pageNum:(NSString *)pageNum callback:(DataListBlock _Nonnull)listData{
    NSDictionary *parma = @{  @"page":page==nil?@"":page,
                             @"page_num":pageNum==nil?@"":pageNum  };
    [self.manager POST:PUNCH_LIST parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSDictionary *data = dict[@"data"];
        NSLog(@"打卡列表：%@ \n数据：%@",dict[@"msg"],dict);
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSArray *array = [punchListModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
            listData(array,[data[@"page"] integerValue],nil);
        }else{  //请求成功但无数据
            listData(nil,[data[@"page"] integerValue],nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        listData(nil,-1,error);
    }];
}

//用户历史打卡记录
-(void)requestUserHistoryPunchWithYear:(NSString *)year month:(NSString *)month callBcak:(DataListBlock _Nonnull)listData{
    NSDictionary *parma = @{  @"year":year==nil?@"2011":year,
                              @"month":month==nil?@"10":month  };
    [self.manager POST:HISTORY_PUNCH parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"用户历史打卡记录：%@ 类型：%@\n",dict[@"msg"],dict);
        NSDictionary *data = dict[@"data"];
        if ([data isKindOfClass:[NSDictionary class]]) {
        NSArray *array = data[@"traveldate"];
            if ([array isKindOfClass:[NSArray class]] && array.count>0) {
                listData(array,0,nil);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        listData(nil,0,error);
    }];
}


//周分析   @"2016-05-02"
-(void)requsetTravelWeekAnalyzeWithDate:(NSString *)date callback:(stringDataBlock _Nonnull)callback{
    NSDictionary *parma = @{ @"date":date };
    [self.manager POST:TRAVEL_ANALYZE parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSDictionary *data = dict[@"data"];
        NSLog(@"周分析：%@ 类型：%@\n",dict[@"msg"],dict);
        if ([data isKindOfClass:[NSDictionary class]]) {
            callback(data[@"travelanalysis"],nil);
        }else{
            callback(@"",nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(nil,error);
    }];
}

//日里程
-(void)requestDayMileageWithPage:(NSString *)page pageNum:(NSString *)pageNum callback:(DataListBlock _Nonnull)listData{
    NSDictionary *parma = @{ @"page":page,
                            @"page_num":pageNum };
    [self.manager POST:DAY_MILEAGE parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"日里程：%@ 类型：%@\n",dict[@"msg"],dict);
        NSDictionary *data = dict[@"data"];
        NSArray *array = [dayMileageModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        listData(array,[data[@"page"] integerValue],nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        listData(nil,-1,error);
    }];
}

//日里程分段数据 @"2018-11-03"
-(void)requestDayMileageSubsWithPage:(NSString *)page pageNum:(NSString *)pageNum date:(NSString *)date callback:(DataListBlock _Nonnull)listData{
    NSDictionary *parma = @{  @"travelDate":date,
                             @"page":page,
                             @"page_num":pageNum  };
    [self.manager POST:DAY_MILEAGE_SUBS parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"日里程分段数据：%@ 类型：%@\n",dict[@"msg"],dict);
        NSDictionary *data = dict[@"data"];
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSArray *array = [TravelInfoModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
            listData(array,0,nil);
        }else{
            listData(nil,0,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        listData(nil,0,error);
    }];
}

//周频率 月频率
-(void)requestWeekAndMonthFrequency:(FREQUENCY_TYPE)type page:(NSString *)page pageNum:(NSString *)pageNum callback:(DataListBlock _Nonnull)listData{
    NSString *apiType;
    if (type == WEEK_TYPE) {
        apiType = @"week";
    }else{
        apiType = @"month";
    }
    NSDictionary *parma = @{   @"type":apiType,   //type  week/month
                              @"page":page==nil?@"":page,
                              @"page_num":pageNum==nil?@"":pageNum  };
    [self.manager POST:MONTH_WEEK_FREQUENCY parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
          NSLog(@"周频率 月频率：%@ 类型：%@\n",dict[@"msg"],dict);
          NSDictionary *data = dict[@"data"];
          NSArray *array = [frequencyWeekModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
          listData(array,[data[@"page"] integerValue],nil);
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            listData(nil,-1,error);
      }];
}

#pragma mark - 音乐
//请求轮播图数据
-(void)requestBannerDatacallback:(DataListBlock _Nonnull)callback{
    [self.manager GET:BANNER_DATA parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"请求轮播图数据：%@ 类型：%@\n",dict[@"msg"],dict);
        NSArray *array = [MusicBannerModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
        callback(array,0,nil);
        //保存数据
//        NSArray *dictarray = [MusicBannerModel mj_keyValuesArrayWithObjectArray:array];
//        [dictarray writeToFile:[CACHE_PATH stringByAppendingPathComponent:@"banner.plist"] atomically:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSString *path = [CACHE_PATH stringByAppendingPathComponent:@"banner.plist"];
//        NSArray *dictarray = [NSArray arrayWithContentsOfFile:path];
//        if (dictarray != nil) {
//            NSArray *array = [MusicBannerModel mj_objectArrayWithKeyValuesArray:dictarray];
//            callback(array,0,nil);
//        }else{
            callback(nil,0,error);
//        }
    }];
}

//热门歌单
-(void)requestHotMusiccallback:(DataListBlock _Nonnull)callback{
    [self.manager GET:HOT_MUSIC parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict = [NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSHTTPURLResponse *re = (NSHTTPURLResponse *)task.response;
//        NSLog(@"%@",re.allHeaderFields);
        NSLog(@"热门歌单：%@ 类型：%@\n",dict[@"msg"],dict);
        NSArray *array = [MusicAlbumModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
        callback(array,0,nil);
        //保存数据
//        NSArray *dictarray = [MusicAlbumModel mj_keyValuesArrayWithObjectArray:array];
//        [dictarray writeToFile:[CACHE_PATH stringByAppendingPathComponent:@"hotMusic.plist"] atomically:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSString *path = [CACHE_PATH stringByAppendingPathComponent:@"hotMusic.plist"];
//        NSArray *dictarray = [NSArray arrayWithContentsOfFile:path];
//        if (dictarray != nil) {
//            NSArray *array = [MusicAlbumModel mj_objectArrayWithKeyValuesArray:dictarray];
//            callback(array,0,nil);
//        }else{
            callback(nil,0,error);
//        }
    }];
}

//推荐歌单
-(void)requestRecommendMusiccallback:(DataListBlock _Nonnull)callback{
    [self.manager GET:RECOMMEND_MUSIC parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"推荐歌单：%@ 类型：%@\n",dict[@"msg"],dict);
        NSDictionary *data = dict[@"data"];
        NSArray *array = [MusicAlbumModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        callback(array,0,nil);
        //保存数据
//        NSArray *dictarray = [MusicAlbumModel mj_keyValuesArrayWithObjectArray:array];
//        [dictarray writeToFile:[CACHE_PATH stringByAppendingPathComponent:@"recommendMusic.plist"] atomically:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSString *path = [CACHE_PATH stringByAppendingPathComponent:@"recommendMusic.plist"];
//        NSArray *dictarray = [NSArray arrayWithContentsOfFile:path];
//        if (dictarray != nil) {
//            NSArray *array = [MusicAlbumModel mj_objectArrayWithKeyValuesArray:dictarray];
//            callback(array,0,nil);
//        }else{
            callback(nil,0,error);
//        }
    }];
}

//全部歌单
-(void)requestAllMusicPage:(NSString *)page pageNum:(NSString *)pageNum callback:(DataListBlock _Nonnull)callback{
    NSDictionary *parma = @{  @"page":page,
                             @"page_num":pageNum  };
    [self.manager GET:ALL_MUSIC parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"全部歌单：%@ 类型：%@\n",dict[@"msg"],dict);
        NSDictionary *data = dict[@"data"];
        NSArray *array = [MusicAlbumModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        callback(array,[data[@"page"]integerValue],nil);
        //保存数据
//        NSArray *dictarray = [MusicAlbumModel mj_keyValuesArrayWithObjectArray:array];
//        [dictarray writeToFile:[CACHE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"allMusic%@.plist",data[@"page"]]] atomically:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSString *path = [CACHE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"allMusic%@.plist",page]];
//        NSArray *dictarray = [NSArray arrayWithContentsOfFile:path];
//        if (dictarray != nil) {
//            NSArray *array = [MusicAlbumModel mj_objectArrayWithKeyValuesArray:dictarray];
//            callback(array,[page integerValue],nil);
//        }else{
            callback(nil,-1,error);
//        }
    }];
}

//场景音乐
-(void)requestSceneMusicPage:(NSString *)page pageNum:(NSString *)pageNum musicType:(NSInteger)musicType callback:(DataListBlock _Nonnull)callback{
    NSDictionary *parma = @{  @"page":page,
                             @"page_num":pageNum,
                              @"musicType":[NSString stringWithFormat:@"%ld",(long)musicType]  };
    [self.manager GET:SCENE_MUSIC parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"场景音乐：%@ 类型：%@\n",dict[@"msg"],dict);
        NSDictionary *data = dict[@"data"];
        NSArray *array = [musicModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        callback(array,[data[@"page"] integerValue],nil);
        //保存数据
//        NSArray *dictarray = [musicModel mj_keyValuesArrayWithObjectArray:array];
//        [dictarray writeToFile:[CACHE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"sceneMusic%ld_%@.plist",(long)musicType,data[@"page"]]] atomically:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSString *path = [CACHE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"sceneMusic%ld_%@.plist",(long)musicType,page]];
//        NSArray *dictarray = [NSArray arrayWithContentsOfFile:path];
//        if (dictarray != nil) {
//            NSArray *array = [musicModel mj_objectArrayWithKeyValuesArray:dictarray];
//            callback(array,[page integerValue],nil);
//        }else{
            callback(nil,-1,error);
//        }
    }];
}

//专辑音乐  album该转接所在的表名 MusicStory
-(void)requestAlbumMusicPage:(NSString *)page pageNum:(NSString *)pageNum musicType:(NSString *)musicType album:(NSString *)album callback:(DataListBlock _Nonnull)callback{
    NSDictionary *parma = @{  @"page":page,
                             @"page_num":pageNum,
                             @"musicType":musicType,
                             @"albumAddress":album  };
    [self.manager GET:ALBUM_LIST parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"专辑音乐：%@ 类型：%@\n",dict[@"msg"],dict);
        NSDictionary *data = dict[@"data"];
        NSArray *array = [musicModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        callback(array,[data[@"page"] integerValue],nil);
        //保存数据
//        NSArray *dictarray = [musicModel mj_keyValuesArrayWithObjectArray:array];
//        [dictarray writeToFile:[CACHE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"albumMusic%@_%@_%@.plist",musicType,data[@"page"],album]] atomically:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSString *path = [CACHE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"albumMusic%@_%@_%@.plist",musicType,page,album]];
//        NSArray *dictarray = [NSArray arrayWithContentsOfFile:path];
//        if (dictarray != nil) {
//            NSArray *array = [musicModel mj_objectArrayWithKeyValuesArray:dictarray];
//            callback(array,[page integerValue],nil);
//        }else{
            callback(nil,-1,error);
//        }
    }];
}

//收藏与下载操作
-(void)updateMusicWithOperation:(NSArray *)array callback:(statusBlock _Nonnull)callback{
    NSDictionary *parma = @{  @"data":array };
    [self.manager POST:COLLECT_DOWN parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"收藏与下载操作：%@ 类型：%@\n",dict[@"msg"],dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

#pragma mark - 个人中心
//用户信息
-(void)requestUserDataCallback:(ModelBlock _Nonnull)callback{
    [self.manager POST:USER_INFO parameters:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"用户信息：%@ 类型：%@\n",dict[@"msg"],dict);
        userInfoModel *model = [userInfoModel mj_objectWithKeyValues:dict[@"data"]];
        callback(model,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(nil,error);
    }];
}

//修改用户信息   nickName或者header
-(void)updateUserInfoWithOptionType:(USER_INFO_TYPE)optionType optionValue:(id)optionValue callback:(statusBlock _Nonnull)callback{

    NSMutableDictionary *parma = [NSMutableDictionary dictionary];
    switch (optionType) {
        case UPLOAD_USER_NAME:
            [parma setObject:optionValue forKey:@"nickName"];
            break;
        case UPLOAD_USER_WEIGHT:
            [parma setObject:optionValue forKey:@"weight"];
            break;
        case UPLOAD_USER_HEADER:
            break;
    }
    
    [self.manager POST:UPDATE_USER_INFO parameters:parma constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //如果是上传头像 则添加图片data
        if (optionType == UPLOAD_USER_HEADER) {
            
            // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名  要解决此问题， 可以在上传时使用当前的系统事件作为文件名
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            // 设置时间格式
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
            
            //上传
            /*
             此方法参数
             1. 要上传的[二进制数据]
             2. 对应网站上[upload.php中]处理文件的[字段"file"]
             3. 要保存在服务器上的[文件名]
             4. 上传文件的[mimeType]
             */
            [formData appendPartWithFileData:optionValue name:@"header" fileName:fileName mimeType:@"image/png"];
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"修改用户信息：%@",dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

//添加宝贝
-(void)addBabyInfoWithModel:(babyInfoModel *)model header:(NSData *)headerData callback:(statusBlock _Nonnull)callback{
    NSDictionary *parma = @{ @"sex":model.sex == nil? @"小公主" : model.sex,
                             @"name":model.name == nil? @"小宝贝" : model.name,
                             @"birthday":model.birthday == nil? @"" : model.birthday };
    
    [self.manager POST:ADD_BABY parameters:parma constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if ([headerData isKindOfClass:[NSData class]]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
            [formData appendPartWithFileData:headerData name:@"header" fileName:fileName mimeType:@"image/png"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"添加宝贝：%@ 类型：%@\n",dict[@"msg"],dict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

//baby信息
-(void)requestBabyInfoWithId:(NSString *)Id callback:(ModelBlock _Nonnull)callback{
    NSDictionary *parma = @{ @"objectId":Id };
    [self.manager POST:BABY_INFO parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"baby信息：%@ 类型：%@\n",dict[@"msg"],dict);
        NSDictionary *data = dict[@"data"];
        babyInfoModel *model = [babyInfoModel mj_objectWithKeyValues:data];
        callback(model,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(nil,error);
    }];
}

//baby列表
-(void)requestBabyListcallback:(DataListBlock _Nonnull)callback{
    [self.manager POST:BABY_LIST parameters:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"baby列表：%@ 类型：%@\n",dict[@"msg"],dict);
        NSArray *array = [babyInfoModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
        callback(array,0,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(nil,0,error);
    }];
}

//  @{ @"objectId":@"572d9e6679df540060b2afa4",
//@"birthday":@"2018-9-11" }
//修改baby信息  name/sex/birthday/header
-(void)updateBabyInfoWithId:(NSString *)Id optionType:(BABY_INFO_TYPE)type optionValue:(id)optionValue callback:(statusBlock _Nonnull)callback{
    NSMutableDictionary *parma = [NSMutableDictionary dictionary];
    [parma setObject:Id forKey:@"objectId"];
    switch (type) {
        case UPLOAD_BABY_SEX:
            [parma setObject:optionValue forKey:@"sex"];
            break;
        case UPLOAD_BABY_NAME:
            [parma setObject:optionValue forKey:@"name"];
            break;
        case UPLOAD_BABY_BIRTHDAY:
            [parma setObject:optionValue forKey:@"birthday"];
        default:break;
    }
    
    [self.manager POST:UPDATE_BABY_INFO parameters:parma constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //如果是上传头像 则添加图片data
        if (type == UPLOAD_BABY_HEADER) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            // 设置时间格式
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
 
            [formData appendPartWithFileData:optionValue name:@"header" fileName:fileName mimeType:@"image/png"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"修改baby信息：%@ 类型：%@\n",dict[@"msg"],dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

//删除baby信息  572d9e6679df540060b2afa4
-(void)deleteBabyWithId:(NSString *)Id callback:(statusBlock _Nonnull)callback{
    NSDictionary *parma = @{ @"objectId":Id };
    [self.manager POST:DEL_BABY parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"删除baby信息：%@ 类型：%@\n",dict[@"msg"],dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

#pragma mark - 推车
//请求已绑定的推车列表
-(void)requestDeviceListCallback:(DataListBlock _Nonnull)callback{
    NSDictionary *parme = @{ @"type":@"Ios" };
    [self.manager POST:DEVICE_LIST parameters:parme progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"已绑定的推车列表：%@ 类型：%@\n",dict[@"msg"],dict);
        NSArray *array = [DeviceModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
        callback(array,0,nil);
        //保存数据
//        NSArray *dictarray = [DeviceModel mj_keyValuesArrayWithObjectArray:array];
//        [dictarray writeToFile:[CACHE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"deviceInfoArray%@.plist",KUserDefualt_Get(USER_ID_NEW)]] atomically:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSString *path = [CACHE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"deviceInfoArray%@.plist",KUserDefualt_Get(USER_ID_NEW)]];
//        NSArray *dictarray = [NSArray arrayWithContentsOfFile:path];
//        if (dictarray != nil) {
//            NSArray *array = [DeviceModel mj_objectArrayWithKeyValuesArray:dictarray];
//            callback(array,0,nil);
//        }else{
            callback(nil,0,error);
//        }
    }];
}

//修改设备名称
-(void)updateDeviceName:(NSString *)name Id:(NSString *)Id callback:(statusBlock _Nonnull)callback{
    NSDictionary *parma = @{ @"objectId":Id,
                             @"bluetoothName":name };
    [self.manager POST:UPDATE_DEVICE_NAME parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"修改设备名称：%@ 类型：%@\n",dict[@"msg"],dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

//绑定设备
-(void)bindDeviceWithDict:(NSDictionary *)dict callback:(statusBlock _Nonnull)callback{
    [self.manager POST:BIND_DEVICE parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"绑定设备：%@ 类型：%@\n",dict[@"msg"],dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

//解除绑定
-(void)deleteDeviceWithId:(NSString *)Id callback:(statusBlock _Nonnull)callback{
    NSDictionary *parma = @{ @"objectId":Id == nil? @"" : Id,
                             @"type":@"Ios" };
    [self.manager POST:DEL_DEVICE parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"解除绑定：%@ 类型：%@\n",dict[@"msg"],dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

#pragma mark - 推车数据
//获取用户推行信息，推车界面
-(void)requestUserTravelInfoCallback:(ModelBlock _Nonnull)callback{
    [self.manager POST:USER_TRAVEL_INFO parameters:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"获取用户推行信息，推车界面：%@ 类型：%@\n",dict[@"msg"],dict);
        userTravelInfoModel *model = [userTravelInfoModel mj_objectWithKeyValues:dict[@"data"]];
        callback(model,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(nil,error);
    }];
}

//上传平均速度 今日里程 总里程
-(void)uploadAverageSpeed:(CGFloat)speed todayMileage:(NSInteger)todayMileage totalMileage:(CGFloat)totalMileage callback:(statusBlock _Nonnull)callback{
    if (todayMileage <= 0) {
        callback(NO,nil);
        return;
    }
    NSDictionary *parma = @{  @"averageSpeed":@(speed),
                             @"mileage":@(todayMileage),
                             @"totalMileage":@(totalMileage) };
    [self.manager POST:UPDATE_AVERAGE_SPEED parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"上传平均速度 今日里程 总里程：%@ 类型：%@\n",dict[@"msg"],dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

//上传分段里程
-(void)uploadTravelOnce:(NSDictionary *)dict callback:(statusBlock _Nonnull)callback{
    NSLog(@"要上传的分段数据%@\n",dict);
    [self.manager POST:UPDATE_TRAVEL_ONCE parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"上传分段里程：%@ 类型：%@\n",dict[@"msg"],dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

//获取最新的一条分段里程数据
-(void)requestNewestMileageDataCallback:(stringDataBlock)callback{
    [self.manager GET:NEWEST_MILEAGE parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"获取最新的一条分段里程数据：%@ 类型：%@\n",dict[@"msg"],dict);
        NSDictionary *data = dict[@"data"];
        if ([data isKindOfClass:[NSDictionary class]]) {
            callback(data[@"endtime"],nil);
        }else{
            callback(nil,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(nil,error);
    }];
}

//上传推车睡眠次数
-(void)uploadDeviceSleepTimes:(NSDictionary *)dict callback:(statusBlock _Nonnull)callback{
    [self.manager POST:SLEEP_TIMES parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"上传推车睡眠次数：%@ 类型：%@\n",dict[@"msg"],dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

//上传刹车灵敏度
-(void)uploadDeviceSensitivity:(NSString *)sensitivity callback:(statusBlock _Nonnull)callback{
    NSDictionary *parma = @{ @"sensitivity":sensitivity };
    [self.manager POST:SENSITIVITY parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"上传刹车灵敏度：%@ 类型：%@\n",dict[@"msg"],dict);
        if ([dict[@"status"] integerValue] == 0) {
            callback(YES,nil);
        }else{
            callback(NO,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

//一键修复信息
-(void)uploadDeviceRepairData:(NSString *)deviceIdf deviceAddress:(NSString *)deviceAddress repair:(NSString *)repair bleUUID:(NSString *)bleUUID callback:(statusBlock _Nonnull)callback{
    NSDictionary *dict = @{   @"deviceIdentifier":deviceIdf==nil?@"":deviceIdf,
                             @"deviceAddress":deviceAddress==nil?@"":deviceAddress,
                             @"repairInfo":repair==nil?@"":repair,
                             @"bluetoothUUID":bleUUID==nil?@"":bleUUID  };
    [self.manager POST:REPAIR_ONCE parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"一键修复信息：%@ 类型：%@\n",dict[@"msg"],dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

#pragma mark - 其他
//用户反馈
-(void)userFeedBackWithMsg:(NSString *)msg callback:(statusBlock _Nonnull)callback{
    NSDictionary *parma = @{ @"feedBackContent":msg };
    [self.manager POST:FEED_BACK parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"用户反馈：%@ 类型：%@\n",dict[@"msg"],dict);
        callback(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO,error);
    }];
}

//使用说明
-(void)instructionsCallback:(stringDataBlock _Nonnull)callback{
    NSDictionary *parma = @{ @"function":@"problem" };
    [self.manager POST:INSTRUCTIONS parameters:parma progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSArray *dataArray = dict[@"data"];
        NSDictionary *data = [dataArray firstObject];
        NSLog(@"使用说明：%@ 类型：%@\n",dict[@"msg"],dict);
        if ([data isKindOfClass:[NSDictionary class]]) {
            callback(data[@"instruction_file"],nil);
        }
        //保存数据
//        KUserDefualt_Set(data[@"instruction_file"], @"instruction_file");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSString *str = KUserDefualt_Get(@"instruction_file");
//        if ([str isKindOfClass:[NSString class]]) {
//            callback(str,nil);
//        }else{
            callback(nil,error);
//        }
    }];
}

//用户协议
-(void)userProtocolCallback:(stringDataBlock _Nonnull)callback{
    [self.manager POST:USER_PROTOCOL parameters:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"用户协议：%@ 类型：%@\n",dict[@"msg"],dict);
        NSArray *dataArray = dict[@"data"];
        NSDictionary *data = [dataArray firstObject];
        if ([data isKindOfClass:[NSDictionary class]]) {
            callback(data[@"userprotocol"],nil);
        }
        //保存数据
//        KUserDefualt_Set(data[@"userprotocol"], @"userprotocol");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSString *str = KUserDefualt_Get(@"userprotocol");
//        if ([str isKindOfClass:[NSString class]]) {
//            callback(str,nil);
//        }else{
            callback(nil,error);
//        }
    }];
}

//获取app_control数据
-(void)requestAppControlCallback:(appControlBlock _Nonnull)callback{
    //appcontrol   cart_list_details
    NSDictionary *dict = @{ @"type":@"appcontrol" };
    
    [self.manager POST:APP_CONTROL parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"获取app_control数据：%@ 类型：%@\n",dict[@"msg"],dict);
        NSDictionary *data = dict[@"data"];
        if ([data isKindOfClass:[NSDictionary class]]) {
            callback(data[@"version"],[data[@"hideversioncell"] boolValue],nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(nil,YES,error);
    }];
}

//获取设备类型列表
-(void)requestDeviceTypeList:(DataListBlock _Nonnull)callback{
    //appcontrol   cart_list_details
    NSDictionary *dict = @{ @"type":@"cart_list_details" };
    [self.manager POST:APP_CONTROL parameters:dict progress:nil  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"获取设备类型列表：%@ 类型：%@\n",dict[@"msg"],dict);
        NSArray *array = [deviceTypeModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
        callback(array,0,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(nil,0,error);
    }];
}

//上传崩溃信息
-(void)uploadCrashLogData:(NSDictionary *)dict imageData:(NSData *)imageData{
    [self.manager POST:CRASH_LOG parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (imageData != nil && [imageData isKindOfClass:[NSData class]]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";   // 设置时间格式
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
            [formData appendPartWithFileData:imageData name:@"header" fileName:fileName mimeType:@"image/png"];
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"上传崩溃信息：%@ 类型：%@\n",dict[@"msg"],dict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


@end