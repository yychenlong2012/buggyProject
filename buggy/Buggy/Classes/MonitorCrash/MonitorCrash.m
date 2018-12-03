//
//  MonitorCrash.m
//  MonitorCrash
//
//  Created by 孟德林 on 2017/4/13.
//  Copyright © 2017年 DeLin.Meng. All rights reserved.
//

#import "MonitorCrash.h"

static NSString const *MonitorCrashSeparaterLine = @"================ MonitorCrash Log ===================";
static NSString const *MonitorCrashSeparaterFlag = @"================ MonitorCrash End ===================";

@implementation MonitorCrash

+(void)monitorCrash{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject monitorCrashExchangeMethod];
        
        [NSArray monitorCrashExchangeMethod];
        [NSMutableArray monitorCrashExchangeMethod];
        
        [NSDictionary monitorCrashExchangeMethod];
        [NSMutableDictionary monitorCrashExchangeMethod];
        
        [NSString monitorCrashExchangeMethod];
        [NSMutableString monitorCrashExchangeMethod];
        
        [NSAttributedString monitorCrashExchangeMethod];
        [NSMutableAttributedString monitorCrashExchangeMethod];
    });
}
    
//
+ (void)exchangeClassMethod:(Class)currentClass oldMethod:(SEL)oldMethod newMethod:(SEL)newMethod{
    Method oldM = class_getClassMethod(currentClass, oldMethod);
    Method newM = class_getClassMethod(currentClass, newMethod);
    method_exchangeImplementations(oldM, newM);
}
    
+(void)exchangeInstanceMethod:(Class)currentClass oldMethod:(SEL)oldMethod newMethod:(SEL)newMethod{
    Method oldM = class_getInstanceMethod(currentClass, oldMethod);
    Method newM = class_getInstanceMethod(currentClass, newMethod);
    
    BOOL didAddMethod = class_addMethod(currentClass, oldMethod, method_getImplementation(newM), method_getTypeEncoding(newM));
    if (didAddMethod) {
        class_replaceMethod(currentClass, newMethod, method_getImplementation(oldM), method_getTypeEncoding(oldM));
    }else{
        method_exchangeImplementations(oldM, newM);
    }
}
    
+ (NSString *)getMainStackSymbolMessageCalls:(NSArray <NSString *> *)stackSymbolsCalls{
    
    //mainSymbolMsgCall 的格式 +[类名 方法名]  或   -[类名 方法名]
    __block NSString *mainSymbolMsgCall = nil;
    //正则匹配的格式 +[类名 方法名] 或 -[类名 方法]
    NSString *regularExpStr = @"[-\\+]\\[.+\\]";
    
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr options:NSRegularExpressionCaseInsensitive error:nil];
    for (int index = 2; index < stackSymbolsCalls.count; index ++) {
        NSString *stackSymbol = stackSymbolsCalls[index];
        [regularExp enumerateMatchesInString:stackSymbol options:NSMatchingReportProgress range:NSMakeRange(0, stackSymbol.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            
            if (result) {
                NSString* tempCallStackSymbolMsg = [stackSymbol substringWithRange:result.range];
                
                //get className
                NSString *className = [tempCallStackSymbolMsg componentsSeparatedByString:@" "].firstObject;
                className = [className componentsSeparatedByString:@"["].lastObject;
                NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
                //filter category and system class
                if (![className hasSuffix:@")"] && bundle == [NSBundle mainBundle]) {
                    tempCallStackSymbolMsg = tempCallStackSymbolMsg;
                }
                *stop = YES;
            }
            
        }];
        
        if (mainSymbolMsgCall.length) {
            break;
        }
    }
    return mainSymbolMsgCall;
}
    
    
+ (void)showErrorWithException:(NSException *)exception shouldDo:(NSString *)shouldDo{
    // 获取堆栈数据
    NSArray *stackSoymbolsArr = [NSThread callStackSymbols];
    // 获取在某个类的方法中的实例化的数组  字符串格式 -[类名 方法名]  或者 +[类名 方法名]
    NSString *mainStackSymbolMsg = [MonitorCrash getMainStackSymbolMessageCalls:stackSoymbolsArr];
    if (mainStackSymbolMsg == nil) {
        mainStackSymbolMsg = @"崩溃方法定位失败,请查看函数调用栈来排查错误";
    }
    NSString *errorName = exception.name;
    NSString *errorReason = exception.reason;
    //errorReason 可能为 -[__NSCFConstantString monitorCrashCharacterAtIndex:]: Range or index out of bounds
    //将avoidCrash去掉
    errorReason = [errorReason stringByReplacingOccurrencesOfString:@"monitorCrash" withString:@""];
    NSString *errorPlace = [NSString stringWithFormat:@"Error Place:%@",mainStackSymbolMsg];
    NSString *logErrorMessage = [NSString stringWithFormat:@"\n\n%@\n\n%@\n%@\n%@\n%@\n\n%@\n\n",MonitorCrashSeparaterFlag, errorName, errorReason, errorPlace, shouldDo, MonitorCrashSeparaterLine];
    MonitorCrashLog(@"%@",logErrorMessage);
    
    
    // 将错误信息打包成字典，用通知的形式发送出去
    NSDictionary *errorInfo = @{
                                @"key_errorName"        : errorName,
                                @"key_errorReason"      : errorReason,
                                @"key_errorPlace"       : errorPlace,
                                @"key_defaultToDo"      : shouldDo,
                                @"key_exception"        : exception,
                                @"key_callStackSymbols" : stackSoymbolsArr
                                };
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"" object:nil userInfo:errorInfo];
    });
    
}
@end
