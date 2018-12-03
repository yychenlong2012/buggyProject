#import <Foundation/Foundation.h>

#define WeatherManager [HmacSha1Tool manager]

typedef void(^callBackBlock)(NSString *temperature,NSString *air,NSString *weather);
typedef void(^uploadSuccess) (void);
@interface HmacSha1Tool : NSObject
@property (nonatomic,strong) NSString *airQuality;    //空气质量
@property (nonatomic,strong) NSString *weatherCode;       //天气
@property (nonatomic,strong) NSString *temperature;

+ (instancetype)manager;

//上传天气和空气质量等数据
- (void)getLocationWeatherWith:(callBackBlock)block success:(uploadSuccess)success;
//- (void)uploadWeatherAndAirQualityWithBlock:(void(^)(NSString *temperature,NSString *air))block;

/**  天气实况
 @param location 所查询的位置
 @param ttl 签名失效时间(可选)，默认有效期为 1800 秒（30分钟）
 @param language 语言(可选)。 默认值：zh-Hans
 @param unit 单位 (可选)。默认值：c
 @param start 起始时间 (可选)。默认值：0
 @param days 天数 (可选)。 默认为你的权限允许的最多天数
 @return return 带请求参数的 url 地址
 */
- (NSString *)getNowWeatherURLStringWithLocation:(NSString *)location
                                            ttl:(NSInteger)ttl
                                           unit:(NSString *)unit
                                          start:(NSString *)start
                                           days:(NSString *)days;

//生活指数
- (NSString *)getLiftURLStringWithLocation:(NSString *)location
                                             ttl:(NSInteger)ttl
                                            unit:(NSString *)unit
                                           start:(NSString *)start
                                            days:(NSString *)days;

//空气质量
- (NSString *)getNowAirQualityURLStringWithLocation:(NSString *)location;
@end
