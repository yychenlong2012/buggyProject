//
//  GSNetworkSpeed.h
//  流量监控
//
//  Created by goat on 2018/10/30.
//  Copyright © 2018 3Pomelos. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkSpeedDelegate <NSObject>

-(void)downloadSpeed:(NSString *)downloadSpeed;
-(void)uploadSpeed:(NSString *)uploadSpeed;

@end

// 88kB/s
extern NSString *const GSDownloadNetworkSpeedNotificationKey;
// 2MB/s
extern NSString *const GSUploadNetworkSpeedNotificationKey;
@interface GSNetworkSpeed : NSObject
@property (nonatomic, copy, readonly) NSString *downloadNetworkSpeed;
@property (nonatomic, copy, readonly) NSString *uploadNetworkSpeed;

@property (nonatomic,weak) id delegate;

+ (instancetype)shareNetworkSpeed;
- (void)start;
- (void)stop;
@end


