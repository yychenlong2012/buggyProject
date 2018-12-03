//
//  AVFileHandle.m
//  Buggy
//
//  Created by 孟德林 on 2017/5/15.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "AVFileHandle.h"

@interface AVFileHandle()

@property (nonatomic ,strong) NSFileHandle *writeFileHandle;
@property (nonatomic ,strong) NSFileHandle *readFileHandle;

@end

@implementation AVFileHandle

+ (BOOL)createTempFile{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString tempFilePath];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return [manager createFileAtPath:path contents:nil attributes:nil];
}

+ (void)writeTempFileData:(NSData *)data{
    
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[NSString tempFilePath]];
    [handle seekToEndOfFile];
    [handle writeData:data];
}

+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length{
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:[NSString tempFilePath]];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}

+ (void)cacheTempFileWithFileName:(NSString *)name{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString * cacheFolderPath = [NSString cacheFolderPath];
    if ([manager fileExistsAtPath:cacheFolderPath]) {
        [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@",cacheFolderPath,name];
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:[NSString tempFilePath] toPath:cacheFilePath error:nil];
    NSLog(@"cache file : %@", success ? @"success" : @"fail");
}

+ (NSString *)cacheFileExistsWithURL:(NSURL *)url {
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], [NSString fileNameWithURL:url]];
    NSLog(@"%@",[NSString cacheFolderPath]);
    NSLog(@"%@",[NSString fileNameWithURL:url]);   //获取文件名
    NSLog(@"拼接后的路径 = %@",cacheFilePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        return cacheFilePath;
    }
    return nil;
}



//我添加 替换上面  查找磁盘当中是否有音乐文件   音乐下载文件
+ (NSString *)downloadFileExistsWithName:(NSString *)name {
    //name里面是这样的文件名 兔小贝儿歌052丢手绢.mp3  要将前面的兔小贝儿歌052去掉
    NSString *fileName1 = name;
    NSString *fileName2 = name;   //新歌名
    if ([name containsString:@"兔小贝"])
        fileName1 = [name substringFromIndex:8];
    if (![fileName1 containsString:@"mp3"]) {
        fileName2 = [NSString stringWithFormat:@"%@（新）%@",fileName1,@".mp3"];
        fileName1 = [NSString stringWithFormat:@"%@%@",fileName1,@".mp3"];
    }
    NSString * cacheFilePath1 = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], fileName1];
    NSString * cacheFilePath2 = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], fileName2];
    NSLog(@"拼接后的路径 = %@",cacheFilePath1);
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath1]) {
        return cacheFilePath1;
    }else if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath2]){
        return cacheFilePath2;
    }else{
        return nil;
    }
}


//音乐缓存文件
+ (NSString *)cacheFileExistsWithName:(NSString *)name {
    //name里面是这样的文件名 兔小贝儿歌052丢手绢.mp3  要将前面的兔小贝儿歌052去掉
    NSString *fileName1 = name;
    NSString *fileName2 = name;   //新歌名
    if ([name containsString:@"兔小贝"])
        fileName1 = [name substringFromIndex:8];
    if (![fileName1 containsString:@"mp3"]) {
        fileName2 = [NSString stringWithFormat:@"%@（新）%@",fileName1,@".mp3"];
        fileName1 = [NSString stringWithFormat:@"%@%@",fileName1,@".mp3"];
    }
    NSString * cacheFilePath1 = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath2], fileName1];
    NSString * cacheFilePath2 = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath2], fileName2];
    NSLog(@"拼接后的路径 = %@ \n%@",cacheFilePath1,cacheFilePath2);
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath1]) {
        return cacheFilePath1;
    }else if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath2]){
        return cacheFilePath2;
    }else{
        return nil;
    }
}

+ (BOOL)clearCache {
    NSFileManager * manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:[NSString cacheFolderPath] error:nil];
}

#pragma mark --- 根据LeanCloud业务扩展
+ (void)loadCacheFileWithFileName:(NSString *)name fromCachePath:(NSString *)path success:(void(^)(NSString *cacheAbsolutelyPath,BOOL finish))complete{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString * cacheFolderPath = [NSString cacheFolderPath];
        if (![manager fileExistsAtPath:cacheFolderPath]) {
            [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@",cacheFolderPath,name];
        BOOL success = [[NSFileManager defaultManager] copyItemAtPath:path toPath:cacheFilePath error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(cacheFilePath,success);
            }
        });
        NSLog(@"cache file : %@", success ? @"success" : @"fail");
    });
}

+ (void)loadCacheFile2WithFileName:(NSString *)name fromCachePath:(NSString *)path success:(void(^)(NSString *cacheAbsolutelyPath,BOOL finish))complete{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        //缓存文件夹路径
        NSString * cacheFolderPath = [NSString cacheFolderPath2];
        if (![manager fileExistsAtPath:cacheFolderPath]) {
            [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        //缓存文件路径
        NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@",cacheFolderPath,name];
        NSLog(@"%@ \n%@",path,cacheFilePath);
        BOOL success = [[NSFileManager defaultManager] copyItemAtPath:path toPath:cacheFilePath error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(cacheFilePath,success);
            }
        });
        NSLog(@"cache file : %@", success ? @"success" : @"fail");
    });
}


+ (NSString *)loadFileExistsWithFileName:(NSString *)filename{

    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], filename];
    NSLog(@"检查该路径是否存在文件 = %@",cacheFilePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        return cacheFilePath;
    }
    return nil;
}


+ (NSString *)hardLinkFromUrl:(NSString *)fileUrl withExpand:(NSString *)expand{
    
    NSString *url = [NSString stringWithFormat:@"%@.%@",fileUrl,expand];
    NSLog(@"%@",url);
    if (fileUrl) {
        NSError *error;
        if ([[NSFileManager defaultManager] fileExistsAtPath:url]) {
            return url;
        }else{
            BOOL success = [[NSFileManager defaultManager] linkItemAtPath:fileUrl toPath:url error:&error];
            if (success) {
                DLog(@"%@",url);
                return url;
            }
        }
    }
    return nil;
}

@end
