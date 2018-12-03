    //
//  HealthTipModel.m
//  Buggy
//
//  Created by ningwu on 16/6/6.
//  Copyright © 2016年 ningwu. All rights reserved.
//

#import "HealthTipModel.h"

@implementation HealthTipModel

- (void)getTips:(NSString *)date block:(void(^)(NSDictionary *dic,NSError *error))complete
{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
//    NSDate *DateF = [dateFormatter dateFromString:date];
////    if (!DateF) {
////        return;xxxxxxxxxxxxxx
////    }
//    NSString *param = [self getAgeSince:DateF];
//    AVQuery *query = [AVQuery queryWithClassName:@"HealthTips"];
//    //query.maxCacheAge = 30 * 24 * 3600;
//     query.cachePolicy = kAVCachePolicyIgnoreCache;
//    [query whereKey:@"TipOrderMenu" equalTo:param];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        NSMutableDictionary *dictionary = [NSMutableDictionary new];
//        if (objects.count > 0) {
//            AVObject *obj = [objects firstObject];
//            [dictionary setValue:[self dataFromKey:@"DevelopmentSigns" object:obj] forKey:@"DevelopmentSigns"];
//            [dictionary setValue:[self dataFromKey:@"ParentalInteraction" object:obj] forKey:@"ParentalInteraction"];
//            [dictionary setValue:[self dataFromKey:@"GrownConcern" object:obj] forKey:@"GrownConcern"];
//            [dictionary setValue:[self dataFromKey:@"ChildcarePoints" object:obj] forKey:@"ChildcarePoints"];
//            [dictionary setValue:[self dataFromKey:@"ScienceTip" object:obj] forKey:@"ScienceTip"];
//            [dictionary setValue:[obj objectForKey:@"TipsPreview"] forKey:@"TipsPreview"];
//        }
//        complete(dictionary,error);
//    }];
}

- (void)getTipsSuccess:(void(^)(NSDictionary *dicWebData,NSArray *TipsPreviewArray,NSError *error))success
{
//    AVQuery *query = [AVQuery queryWithClassName:@"HealthTips"];
//    query.cachePolicy = kAVCachePolicyIgnoreCache;
//    // query.maxCacheAge = 12 * 30 * 24 * 3600;
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"TipOrder" ascending:YES];
//    [query orderBySortDescriptor:sortDescriptor];
//    __block NSMutableDictionary *dicWeb = [NSMutableDictionary dictionaryWithCapacity:5];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                success(dicWeb,objects,error);
//            });
//
//    }];
}

//- (void)getTipsSuccess:(void(^)(NSDictionary *dicWebData,NSArray *TipsPreviewArray,NSError *error))success
//{
//    AVQuery *query = [AVQuery queryWithClassName:@"HealthTips"];
//    query.cachePolicy = kAVCachePolicyIgnoreCache;
//   // query.maxCacheAge = 12 * 30 * 24 * 3600;
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"TipOrder" ascending:YES];
//    [query orderBySortDescriptor:sortDescriptor];
//    __block NSMutableDictionary *dicWeb = [NSMutableDictionary dictionaryWithCapacity:5];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        
//        if (objects.count > 0) {
//            __block NSMutableArray *DevelopmentSigns = [NSMutableArray arrayWithCapacity:objects.count];
//            __block NSMutableArray *ParentalInteraction = [NSMutableArray arrayWithCapacity:objects.count];
//            __block NSMutableArray *GrownConcern = [NSMutableArray arrayWithCapacity:objects.count];
//            __block NSMutableArray *ChildcarePoints = [NSMutableArray arrayWithCapacity:objects.count];
//            __block NSMutableArray *ScienceTip = [NSMutableArray arrayWithCapacity:objects.count];
//            NSMutableArray *TipsPreview = [NSMutableArray arrayWithCapacity:objects.count];
//            for (AVObject *obj in objects) {
////                [self dataFromKey:@"DevelopmentSigns" object:obj block:^(NSData *data) {
////                    [DevelopmentSigns addObject:@{@"tips":data,@"date":[obj objectForKey:@"TipOrderMenu"]}];
////                    [dicWeb setValue:DevelopmentSigns forKey:@"DevelopmentSigns"];
////                }];
//                [self dataFromKey:@"ParentalInteraction" object:obj block:^(NSData *data) {
//                    [ParentalInteraction addObject:@{@"tips":data,@"date":[obj objectForKey:@"TipOrderMenu"]}];
//                    [dicWeb setValue:ParentalInteraction forKey:@"ParentalInteraction"];
//                }];
//                [self dataFromKey:@"GrownConcern" object:obj block:^(NSData *data) {
//                    [GrownConcern addObject:@{@"tips":data,@"date":[obj objectForKey:@"TipOrderMenu"]}];
//                    [dicWeb setValue:GrownConcern forKey:@"GrownConcern"];
//                }];
//                [self dataFromKey:@"ChildcarePoints" object:obj block:^(NSData *data) {
//                    [ChildcarePoints addObject:@{@"tips":data,@"date":[obj objectForKey:@"TipOrderMenu"]}];
//                    [dicWeb setValue:ChildcarePoints forKey:@"ChildcarePoints"];
//                }];
//                [self dataFromKey:@"ScienceTip" object:obj block:^(NSData *data) {
//                    [ScienceTip addObject:@{@"tips":data,@"date":kStringConvertNull([obj objectForKey:@"TipOrderMenu"])}];
//                    [dicWeb setValue:ScienceTip forKey:@"ScienceTip"];
//                }];
//                [TipsPreview addObject:[obj objectForKey:@"TipsPreview"]];
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//               success(dicWeb,TipsPreview,error);
//            });
//        }
//    }];
//}

//- (NSData *)dataFromKey:(NSString *)key object:(AVObject *)obj
//{
//    AVFile *file = [obj objectForKey:key];
//    NSData *data = [file getData];
//    data = data?data:nil;
//    return data;
//}
//- (void)dataFromKey:(NSString *)key object:(AVObject *)obj block:(void(^)(NSData *data))block{
//    AVFile *file = [obj objectForKey:key];
//    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        if (data) {
//            block(data);
//        }else{
//            block(nil);
//        }
//    }];
//}


- (NSString *)setUnderlineAgeTypeWithDate:(NSString *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *DateF = [dateFormatter dateFromString:date];
//    if (!DateF) {
//        return @"";xxxxxxxxxxx
//    }
    NSString *param = [self getAgeSince:DateF];
    return param;
}

- (NSString *)getAgeSince:(NSDate *)date
{
    if (date == nil) {
        NSLog(@"HealthTipModel 138");
        return @"";
    }
    NSCalendar *gregorian = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:2];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    NSDate *fromDate = [dateFormatter dateFromString:@"2014-06-23 12:02:03"];
    NSDate *toDate = [NSDate date];
    NSDateComponents *dayComponents = [gregorian components:NSCalendarUnitDay fromDate:date toDate:toDate options:0];
    NSString *age = @"";
    NSInteger year = dayComponents.day/365;
    if (year > 0 && year < 4) {
        age = [NSString stringWithFormat:@"%ld年",(long)year];
    }else if(year >= 3){
        age = @"";
//        [MBProgressHUD showToast:@"年龄超出限制"];
    }else{
        age = @"";
    }
    NSInteger month;
    if (year > 0) {
        month = (dayComponents.day%365)/30 + 1;
    }else{
        month = (dayComponents.day%365)/30;
    }
    if (month > 0) {
        age = [NSString stringWithFormat:@"%@%ld月",age,(long)month];
    }else{
        age = [NSString stringWithFormat:@"%@%d月",age,0];
    }
    NSInteger day = (dayComponents.day%365)%30/7 + 1;
    if (day > 0) {
        if (year>0) {
            age = [NSString stringWithFormat:@"%@",age];
        }else{
            age = [NSString stringWithFormat:@"%@%ld周",age,day];
        }
    }else{
        // 同上，数据进行特殊处理
        age = [NSString stringWithFormat:@"%@",age];
    }
    return age;
}

@end
