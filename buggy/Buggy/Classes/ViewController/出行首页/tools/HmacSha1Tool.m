#import "HmacSha1Tool.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CoreLocation/CoreLocation.h>

@interface HmacSha1Tool()<CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager *locationManager;//定位服务
@property (nonatomic,copy) callBackBlock callBack;
@property (nonatomic,copy) uploadSuccess success;

@property (nonatomic,assign) CGFloat currentLongitude;  //经度
@property (nonatomic,assign) CGFloat currentLatitude;   //纬度

@property (nonatomic,strong) NSString *preWeatherCode;   //上一个天气的天气代码
@end
@implementation HmacSha1Tool

+ (instancetype)manager{
    static HmacSha1Tool *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)getLocationWeatherWith:(callBackBlock)block success:(uploadSuccess)success{
    self.callBack = block;
    self.success = success;
    //判断系统的定位服务是否可用
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
//        [_locationManager requestAlwaysAuthorization];
//        [_locationManager requestWhenInUseAuthorization];
        if ([[[UIDevice currentDevice]systemVersion]doubleValue] >8.0){
            [self.locationManager requestWhenInUseAuthorization];
        }
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;  //精度一般即可
        [self.locationManager startUpdatingLocation];  //开始定位
    }else{
        //开通权限
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示",nil) message:@"请在设置中打开系统定位功能" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"我知道了",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //跳转到定位设置界面
//            NSString *version = [UIDevice currentDevice].systemVersion;
//            if (version.doubleValue >= 10.0) {
//                NSData *encryptString = [[NSData alloc] initWithBytes:(unsigned char []){0x41,0x70,0x70,0x2d,0x50,0x72,0x65,0x66,0x73,0x3a,0x72,0x6f,0x6f,0x74,0x3d,0x4c,0x4f,0x43,0x41,0x54,0x49,0x4f,0x4e,0x5f,0x53,0x45,0x52,0x56,0x49,0x43,0x45,0x53} length:32];
//                NSString *string = [[NSString alloc] initWithData:encryptString encoding:NSUTF8StringEncoding];
//                NSURL *url = [NSURL URLWithString:string];
//                if (url != nil) {
//                    if ([[UIApplication sharedApplication]canOpenURL:url]) {
//                        [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:nil];
//                    }
//                }
//
//            }else{
//                NSData *encryptString = [[NSData alloc] initWithBytes:(unsigned char []){0x70,0x72,0x65,0x66,0x73,0x3a,0x72,0x6f,0x6f,0x74,0x3d,0x4c,0x4f,0x43,0x41,0x54,0x49,0x4f,0x4e,0x5f,0x53,0x45,0x52,0x56,0x49,0x43,0x45,0x53} length:28];
//                NSString *string = [[NSString alloc] initWithData:encryptString encoding:NSUTF8StringEncoding];
//                NSURL *url = [NSURL URLWithString:string];
//                if (url != nil) {
//                    if ([[UIApplication sharedApplication]canOpenURL:url]) {
//                        [[UIApplication sharedApplication]openURL:url];
//                    }
//                }
//            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:nil]];
//        NSLog(@"%@",[UIViewController presentingVC]);
        [[UIViewController presentingVC] presentViewController:alert animated:YES completion:nil];
        
        //使用上一次定位保存下来的经纬度信息
        self.currentLatitude = [KUserDefualt_Get(@"user_latitude") floatValue];
        self.currentLongitude = [KUserDefualt_Get(@"user_longitude") floatValue];
        [self uploadWeatherAndAirQuality];
    }
}

#pragma mark - 定位失败
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    //开通权限
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"定位失败" message:@"请在设置中打开应用的定位权限" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"打开定位" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication]openURL:settingURL];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [[UIViewController presentingVC] presentViewController:alert animated:YES completion:nil];
    
    //使用上一次定位保存下来的经纬度信息
    self.currentLatitude = [KUserDefualt_Get(@"user_latitude") floatValue];
    self.currentLongitude = [KUserDefualt_Get(@"user_longitude") floatValue];
    [self uploadWeatherAndAirQuality];
}

#pragma mark - 定位成功
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [_locationManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];
    self.currentLongitude = currentLocation.coordinate.longitude;
    self.currentLatitude = currentLocation.coordinate.latitude;
    [self uploadWeatherAndAirQuality];   //请求天气
    //将经纬度保存起来  定位不到的时候再用
    KUserDefualt_Set(@(self.currentLongitude), @"user_longitude");
    KUserDefualt_Set(@(self.currentLatitude) , @"user_latitude");
    
//    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    //当前的经纬度
//    NSLog(@"当前的经纬度 %f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    //这里的代码是为了判断didUpdateLocations调用了几次 有可能会出现多次调用 为了避免不必要的麻烦 在这里加个if判断 如果大于1.0就return
//    NSTimeInterval locationAge = -[currentLocation.timestamp timeIntervalSinceNow];
//    if (locationAge > 1.0){//如果调用已经一次，不再执行
//        return;
//    }
    //地理反编码 可以根据坐标(经纬度)确定位置信息(街道 门牌等)
//    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        if (placemarks.count >0) {
//            CLPlacemark *placeMark = placemarks[0];
//            NSString *city = placeMark.locality;
//            if (!city) {
//                city = @"无法定位当前城市";
//            }
//            //看需求定义一个全局变量来接收赋值
//            NSLog(@"当前国家 - %@",placeMark.country);//当前国家
//            NSLog(@"当前城市 - %@",city);//当前城市
//            NSLog(@"当前位置 - %@",placeMark.subLocality);//当前位置
//            NSLog(@"当前街道 - %@",placeMark.thoroughfare);//当前街道
//            NSLog(@"具体地址 - %@",placeMark.name);//具体地址
//            NSString *message = [NSString stringWithFormat:@"%@,%@,%@,%@,%@",placeMark.country,city,placeMark.subLocality,placeMark.thoroughfare,placeMark.name];
//
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"好", nil];
//            [alert show];
//        }else if (error == nil && placemarks.count){
//
//            NSLog(@"NO location and error return");
//        }else if (error){
//
//            NSLog(@"loction error:%@",error);
//        }
//    }];
}

#pragma mark - 请求天气
//获得天气信息
- (void)uploadWeatherAndAirQuality{
//    self.temperature = @"33";
//    self.airQuality = @"良";
//    self.weatherCode = @"9";
//    self.callBack(self.temperature,self.airQuality,self.weatherCode);  //更新温度空气
//    [self uploadData];
//    return;
    NSString *location = [NSString stringWithFormat:@"%f:%f",self.currentLatitude,self.currentLongitude];

    self.airQuality = nil;
    self.weatherCode = nil;
    
    //请求天气
    NSURL *weatherUrl = [NSURL URLWithString:[self getNowWeatherURLStringWithLocation:location ttl:30 unit:@"c" start:@"1" days:@"1"]];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:weatherUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error==nil && data!=nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSDictionary *dataDic = [dict[@"results"] lastObject];
            NSDictionary *now = dataDic[@"now"];
            self.weatherCode = now[@"code"];
            self.temperature = now[@"temperature"];
            if (self.airQuality != nil) {
                if (self.callBack) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        self.callBack(self.temperature,self.airQuality,self.weatherCode);  //更新温度空气
                    });
                }
                [self uploadData];
            }
        }
    }] resume];
    
    //请求空气质量
    NSURL *airUrl = [NSURL URLWithString:[self getNowAirQualityURLStringWithLocation:location]];
    [[session dataTaskWithURL:airUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error==nil && data!=nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSDictionary *dataDic = [dict[@"results"] lastObject];
            NSDictionary *air = dataDic[@"air"];
            NSDictionary *city = air[@"city"];
            self.airQuality = city[@"quality"];
            if (self.weatherCode != nil) {
                if (self.callBack) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        self.callBack(self.temperature,self.airQuality,self.weatherCode);  //更新温度空气
                    });
                }
                [self uploadData];
            }
        }
    }] resume];
}

-(void)uploadData{
    [NETWorkAPI uploadWeahter:self.weatherCode airQuality:self.airQuality callback:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            DLog(@"上传天气失败：%@",error);
        }
        if (self.success) {
            self.success();
        }
    }];
}


//字典转json格式字符串：xcode9  以后大部分转码插件扑街了，所以手动转码。
//- (NSString*)dictionaryToJson:(NSDictionary *)dic{
//    NSError *parseError = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
//    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//}


#pragma mark - 天气
/**
 *  获取实况天气url
 */
- (NSString *)getNowWeatherURLStringWithLocation:(NSString *)location ttl:(NSInteger)ttl unit:(NSString *)unit start:(NSString *)start
   days:(NSString *)days{
    NSString *dataUTF8 = [location stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlStr = [self fetchWeatherWithURL:@"https://api.seniverse.com/v3/weather/now.json" //实况天气
                                             ttl:@(ttl)
                                        Location:dataUTF8      //查询位置需要对汉字进行转码，不然会有地名重复
                                        language:@"zh-Hans"     //zh-Hans 简体中文
                                            unit:unit == nil? @"c" : unit//单位 当参数为c时，温度c、风速km/h、能见度km、气压mb;当参数为f时，温度f、风速mph、能见度mile、气压inch
                                           start:start == nil? @"1" : start
                                            days:days == nil? @"1" : days];
    return urlStr;
}


/** location  经纬度
 *  格点天气   根据经纬度坐标生成天气   https://api.seniverse.com/v3/weather/grid/now.json?key=1limijcgcsj4vjqd&location=39.865927:116.359805
 */


/**
 *  分钟级降水预报 经纬度   https://api.seniverse.com/v3/weather/grid/minutely.json?key=1limijcgcsj4vjqd&location=39.865927:116.359805
 */


/**
 *  24小时逐小时天气预报   https://api.seniverse.com/v3/weather/hourly.json?key=1limijcgcsj4vjqd&location=beijing&language=zh-Hans&unit=c&start=0&hours=24
 */


/**
 *  过去24小时历史天气   https://api.seniverse.com/v3/weather/hourly_history.json?key=1limijcgcsj4vjqd&location=seattle&language=zh-Hans&unit=c
 */


/**
 *  15天精细化天气预报  https://api.seniverse.com/v3/weather/hourly3h.json?key=1limijcgcsj4vjqd&location=beijing
 */


/**
 *  气象灾害预报  https://api.seniverse.com/v3/weather/alarm.json?key=1limijcgcsj4vjqd&location=beijing
 */


/**
 *  自然语言天气查询  https://api.seniverse.com/v3/robot/talk.json?key=1limijcgcsj4vjqd&q=北京明天天气怎么样？
 */


#pragma mark - 空气质量
/**
 *  空气质量实况  https://api.seniverse.com/v3/air/now.json?key=1limijcgcsj4vjqd&location=beijing&language=zh-Hans&scope=city
 *  scope = city 表示返回城市平均值，  scope = all 返回城市平均值和各个监察站的值
 */
- (NSString *)getNowAirQualityURLStringWithLocation:(NSString *)location{
    NSString *dataUTF8 = [location stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"https://api.seniverse.com/v3/air/now.json?key=1limijcgcsj4vjqd&location=%@&language=zh-Hans&scope=all",dataUTF8];
}

/**
 *  空气质量实况城市排行  https://api.seniverse.com/v3/air/ranking.json?key=1limijcgcsj4vjqd&language=zh-Hans
 */


/**
 *  逐日空气质量预报  https://api.seniverse.com/v3/air/daily.json?key=1limijcgcsj4vjqd&language=zh-Hans&location=Beijing
 */


/**
 *  逐小时空气质量预报  https://api.seniverse.com/v3/air/hourly.json?key=1limijcgcsj4vjqd&language=zh-Hans&location=Beijing
 */


/**
 *  过去24小时历史空气质量  https://api.seniverse.com/v3/air/hourly_history.json?key=1limijcgcsj4vjqd&location=beijing&language=zh-Hans&scope=city
 */


#pragma mark - 生活
//生活指数
- (NSString *)getLiftURLStringWithLocation:(NSString *)location ttl:(NSInteger)ttl unit:(NSString *)unit start:(NSString *)start
                                      days:(NSString *)days{
    
    NSString *dataUTF8 = [location stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlStr = [self fetchWeatherWithURL:@"https://api.seniverse.com/v3/life/suggestion.json" ttl:@(ttl) Location:dataUTF8
                                        language:@"zh-Hans" unit:(unit == nil? @"c" : unit) start:(start == nil? @"1" : start) days:(days == nil? @"1" : days)];
    return urlStr;
}


//农历节气生肖



//机动车尾号限行


#pragma mark - 地理
//潮汐预报



//日出日落


//月出月落和月相


#pragma mark - 位置
//城市搜索





/**
 配置带请求参数的 url 地址。
 @param url 需要请求的 url 地址。 例如：获取指定城市的天气实况 url 为 TIANQI_NOW_WEATHER_URL
 @param ttl 签名失效时间(可选)，默认有效期为 1800 秒（30分钟）
 @param location 所查询的位置
 @param language 语言(可选)。 默认值：zh-Hans
 @param unit 单位 (可选)。默认值：c
 @param start 起始时间 (可选)。默认值：0
 @param days 天数 (可选)。 默认为你的权限允许的最多天数
 @return return 带请求参数的 url 地址
 */
- (NSString *)fetchWeatherWithURL:(NSString *)url ttl:(NSNumber *)ttl Location:(NSString *)location
                         language:(NSString *)language unit:(NSString *)unit
                            start:(NSString *)start days:(NSString *)days{
    NSString *timestamp = [NSString stringWithFormat:@"%.0ld",time(NULL)];
    NSString *params = [NSString stringWithFormat:@"ts=%@&ttl=%@&uid=%@", timestamp, ttl, XinZhiUserID];
    NSString *signature = [self getSigntureWithParams:params];  //获取签名字符串
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?%@&sig=%@&location=%@&language=%@&unit=%@&start=%@&days=%@",
                        url, params, signature, location, language, unit, start, days];
    return urlStr;
}

/**
 获得签名字符串，关于如何使用签名验证方式，详情见 https://www.seniverse.com/doc#sign
 @param params 验证参数字符串
 @return signature HMAC-SHA1 加密后得到的签名字符串
 */
- (NSString *)getSigntureWithParams:(NSString *)params{
    NSString *signature = [self HmacSha1Key:XinZhiAPIKey data:params];
    return signature;
}

/**
 通过 HMAC-SHA1，对请求参数字符串进行加密，得到一个签名字符串。
 @param key 你的 API 密钥
 @param data 请求参数字符串
 @return 签名字符串 sig
 */
- (NSString *)HmacSha1Key:(NSString *)key data:(NSString *)data {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    // HmacSHA1 加密
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    //将加密结果进行一次 BASE64 编码。
    NSString *hash = [HMAC base64EncodedStringWithOptions:0];
    
    //将 BASE64 编码结果做一个 urlencode
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodedUrl = [hash stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    
    //得到签名 sig
    return encodedUrl;
}
@end
