//
//  AVAResourceLoaderManager.m
//  Test3Pomelos
//
//  Created by 孟德林 on 2017/3/23.
//  Copyright © 2017年 ichezheng.com. All rights reserved.
//

#import "AVAResourceLoaderManager.h"
#import <AVFoundation/AVFoundation.h>
/* 移动核心服务框架 */
#import <MobileCoreServices/MobileCoreServices.h>

@interface AVAResourceLoaderManager()

@property (nonatomic ,strong) NSMutableArray *requestList;
@property (nonatomic ,strong) AVRequestTask *requestTask;
@end

@implementation AVAResourceLoaderManager

- (instancetype)init
{
    self = [super init];
    if (self){
        self.requestList = [NSMutableArray array];
    }
    return self;
}

- (void)stopLoading{
    /* 取消下载 */
    self.requestTask.cancle = YES;
}

#pragma mark - AVRequestTaskDelegate

- (void)requestTaskDidUpdateCache {
    [self processRequestList];
    if (self.delegate && [self.delegate respondsToSelector:@selector(loader:cacheProgress:)]) {
        CGFloat cacheProgress = (CGFloat)self.requestTask.cacheLength / (self.requestTask.fileLength - self.requestTask.requestOffset);
        [self.delegate loader:self cacheProgress:cacheProgress];
    }
}

- (void)requestTaskDidFinishLoadingWithCache:(BOOL)cache{
    self.cacheFinished = cache;
}
- (void)requestTaskDidFailWithError:(NSError *)error{
    // 加载数据错误的处理
    
    DLog(@"数据加载出现错误----%@",error);
}

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"WaitingLoadingRequest < requestedOffset = %lld, currentOffset = %lld, requestedLength = %ld >", loadingRequest.dataRequest.requestedOffset, loadingRequest.dataRequest.currentOffset, loadingRequest.dataRequest.requestedLength);
    [self addLoadingRequest:loadingRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    
    NSLog(@"CancelLoadingRequest  < requestedOffset = %lld, currentOffset = %lld, requestedLength = %ld >", loadingRequest.dataRequest.requestedOffset, loadingRequest.dataRequest.currentOffset, loadingRequest.dataRequest.requestedLength);
    [self removeLoadingRequest:loadingRequest];
}

#pragma mark - 处理LoadingRequest
- (void)addLoadingRequest:(AVAssetResourceLoadingRequest *)loadRequest{
    [self.requestList addObject:loadRequest];
    @synchronized (self) {
        if (self.requestTask) {
            if (loadRequest.dataRequest.requestedOffset >= self.requestTask.requestOffset && loadRequest.dataRequest.requestedOffset <= self.requestTask.requestOffset + self.requestTask.cacheLength) {
                /* 数据已经缓存，则直接完成 */
                NSLog(@"数据已经缓存，则直接完成");
                [self processRequestList];
            }else{
                // 数据还没有缓存，则等待数据下载; 如果是Seek操作，则重新请求
                if (self.seekRequired) {
                    NSLog(@"Seek操作，则完成请求");
                    [self newTaskWithLoadingRequest:loadRequest cache:NO];
                }
            }
        }else{
            [self newTaskWithLoadingRequest:loadRequest cache:YES];
        }
    }
}

- (void)processRequestList{
    NSMutableArray *finishRequestList = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.requestList) {
        if ([self finishLoadingWithLoadingRequest:loadingRequest]) {
            [finishRequestList addObject:loadingRequest];
        }
    }
    [self.requestList removeObjectsInArray:finishRequestList];
}

- (BOOL)finishLoadingWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadRequest{
    
    // 填充信息
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(MimeType), NULL);
    loadRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadRequest.contentInformationRequest.contentLength = self.requestTask.fileLength;
    
    //读文件，填充数据
    NSUInteger cacheLength = self.requestTask.cacheLength;
    NSUInteger requestedOffset = loadRequest.dataRequest.requestedOffset;
    if (loadRequest.dataRequest.currentOffset != 0) {
        requestedOffset = loadRequest.dataRequest.currentOffset;
    }
    NSUInteger canReadLength = cacheLength - (requestedOffset - self.requestTask.requestOffset);
    NSUInteger respondLength = MIN(canReadLength, loadRequest.dataRequest.requestedLength);
    [loadRequest.dataRequest respondWithData:[AVFileHandle readTempFileDataWithOffset:requestedOffset - self.requestTask.requestOffset length:respondLength]];
    
    // 如果完全响应了所需要的数据，则完成
    NSUInteger nowendOffset = requestedOffset + canReadLength;
    NSUInteger reqEndOffset = loadRequest.dataRequest.requestedOffset + loadRequest.dataRequest.requestedLength;
    if (nowendOffset >= reqEndOffset) {
        [loadRequest finishLoading];
        return YES;
    }
    return NO;
}

- (void)newTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadRequest cache:(BOOL)cache{
    
    NSUInteger fileLength = 0;
    if (self.requestTask) {
        fileLength = self.requestTask.fileLength;
        self.requestTask.cancle = YES;
    }
    self.requestTask = [[AVRequestTask alloc] init];
    self.requestTask.requestURL = loadRequest.request.URL;
    self.requestTask.requestOffset = loadRequest.dataRequest.requestedOffset;
    self.requestTask.cache = cache;
    if (fileLength > 0) {
        self.requestTask.fileLength = fileLength;
    }
    self.requestTask.delegate = self;
    [self.requestTask start];
    self.seekRequired = NO;
}

- (void)removeLoadingRequest:(AVAssetResourceLoadingRequest *)loadRequest{
    [self.requestList removeObject:loadRequest];
}

@end
