//
//  AVRequestTask.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/15.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "AVRequestTask.h"
#import <AVFoundation/AVFoundation.h>
#import "AVFileHandle.h"

@interface AVRequestTask ()<NSURLSessionDataDelegate>

@property (nonatomic ,strong) NSURLSession *session;      // 会话对象
@property (nonatomic ,strong) NSURLSessionDataTask *task; // 任务

@end

@implementation AVRequestTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        [AVFileHandle createTempFile];
    }
    return self;
}

- (void)start{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.requestURL originalSchemeURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:RequestTimeout];
    if (self.requestOffset > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",self.requestOffset,self.fileLength - 1] forHTTPHeaderField:@"Range"];
    }
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.task = [self.session dataTaskWithRequest:request];
//    request.networkServiceType = NSURLNetworkServiceTypeDefault;
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.task resume];
}

- (void)setCancle:(BOOL)cancle{
    _cancle = cancle;
    [self.task cancel];
    [self.session invalidateAndCancel];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark --- NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler;{
    if (self.cancle) {
        return;
    }
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *contentRange = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
    NSString *fileLength = [[contentRange componentsSeparatedByString:@"/"] lastObject];
    self.fileLength = fileLength.integerValue > 0?fileLength.integerValue : response.expectedContentLength;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidReceiveResponse)]) {
        [self.delegate requestTaskDidReceiveResponse];
    }
}

//服务器返回数据 可能会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (self.cancle) return;
    [AVFileHandle writeTempFileData:data];
    self.cacheLength += data.length;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidUpdateCache)]) {
        [self.delegate requestTaskDidUpdateCache];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

//请求完成会调用该方法，请求失败则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.cancle) {
        NSLog(@"下载取消");
    }else {
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFailWithError:)]) {
                [self.delegate requestTaskDidFailWithError:error];
            }
        }else {
            //可以缓存则保存文件
            if (self.cache) {
                [AVFileHandle cacheTempFileWithFileName:[NSString fileNameWithURL:self.requestURL]];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFinishLoadingWithCache:)]) {
                [self.delegate requestTaskDidFinishLoadingWithCache:self.cache];
            }
        }
    }
}

@end
