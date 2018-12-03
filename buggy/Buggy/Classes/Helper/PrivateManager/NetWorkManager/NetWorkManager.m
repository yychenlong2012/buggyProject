//
//  NetWorkManager.m
//  Buggy
//
//  Created by goat on 2018/11/5.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import "NetWorkManager.h"
#import <AFNetworking.h>

@implementation NetWorkManager

//发送GET请求
-(void)get{
    // 创建会话管理者
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSDictionary *dict = @{@"username":@"wujian",
        @"pwd":@"wujian",
        @"type":@"JSON"
    };
    //发送GET请求
    [manager GET:@"http://XXXXXX/login" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        //JSON数据（NSData） -> OC对象（Foundation Object）
        //option参数
//        NSJSONReadingMutableContainers = (1UL << 0)
//        创建出来的数组和字典就是可变
//        NSJSONReadingMutableLeaves = (1UL << 1)
//        数组或者字典里面的字符串是可变的
//        NSJSONReadingAllowFragments
//        允许解析出来的对象不是字典或者数组，比如直接是字符串或者NSNumber
//        KNilOptions
//        如果不在乎服务器返回的是可变的还是不可变的，直接传入KNilOptions，效率最高！返回的就是不可变的

        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments|NSJSONReadingMutableLeaves error:nil];
    
        NSLog(@"获取到的数据为：%@ 类型：%@",dict,[dict class]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

//发送POST请求
-(void)post{
    //创建会话管理者
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSDictionary *dict = @{ @"username":@"520it",
                           @"pwd":@"520it",
                           @"type":@"JSON"
                         };
    //发送POST请求
    [manager POST:@"http://XXXX/login" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

//下载任务
-(void)download{
    //创建会话管理者
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //确定请求路径
    NSURL *url=[NSURL URLWithString:@"http://XXXXg/150326/140-150326141213-50.jpg"];
    //创建请求对象
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    //封装下载任务
    NSURLSessionDownloadTask *downloadTask=[manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //打印下载进度
        NSLog(@"%f",1.0*downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        //这里的targetPath是文件存储的临时路径(不安全的)
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接安全的文件路径
        NSString *path=[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:response.suggestedFilename];
        //返回路径的url
        return [NSURL fileURLWithPath:path];
        //下载完成后调用 这里的filePath是文件最终的存储路径
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"完成-----");
    }];
    //提交请求
    [downloadTask resume];
}

//上传
-(void)upload{
    //创建会话管理者
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //非文件参数
    NSDictionary *dict = @{
        @"username":@"xiaomage"
    };
    //02 发送POST请求上传文件
    /*
     第一个参数:请求路径
     第二个参数:非文件参数 (字典)
     第三个参数:constructingBodyWithBlock 处理上传的文件
     第四个参数:progress 进度回调
     第五个参数:success 成功之后的回调
     responseObject:响应体
     第六个参数:failure 失败之后的回调
     */
    [manager POST:@"http://XXXX12/upload"
       parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
           [formData appendPartWithFileURL:[NSURL URLWithString:@"/Users/wujian/Desktop/Snip20160716_135.png"] name:@"file" error:nil];
       } progress:^(NSProgress * _Nonnull uploadProgress) {
           NSLog(@"%f",1.0*uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
       } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
           NSLog(@"成功------");
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSLog(@"失败------");
    }];
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //设置成功block调用线程
    manager.completionQueue = dispatch_get_global_queue(0,0);
    //    NSDictionary *parma = @{@"name":@"xiaoxinxin",@"age":@18};
    NSDictionary *parma = @{@"username":@15618208678};
    [manager GET:@"http://192.168.10.106/leancloud-php-sdk-dad1175/test.php" parameters:parma progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        NSLog(@"%@",[NSStrin]);
        //默认在主线程运行
        NSLog(@"--------%@  类型：%@",responseObject,[responseObject class]);
        
        id dict=[NSJSONSerialization  JSONObjectWithData:responseObject options:0 error:nil];
        
        NSLog(@"获取到的数据为：%@ 类型：%@",dict,[dict class]);
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"服务器json数据1：%@",dic);
        
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"服务器json数据2：%@",arr);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

@end
