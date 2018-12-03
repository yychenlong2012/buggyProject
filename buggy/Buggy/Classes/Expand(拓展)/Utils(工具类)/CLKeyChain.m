//
//  CLKeyChain.m
//  Buggy
//
//  Created by goat on 2018/9/4.
//  Copyright © 2018年 ningwu. All rights reserved.
//

#import "CLKeyChain.h"
NSString * const KEY_UUID_INSTEAD = @"com.myapp.udid.test";

@implementation CLKeyChain

+ (NSString *)getDeviceIDInKeychain{
    
    NSString *getUDIDInKeychain = (NSString *)[CLKeyChain load:KEY_UUID_INSTEAD];
    NSLog(@"从keychain中获取到的 UDID_INSTEAD %@",getUDIDInKeychain);
    if (!getUDIDInKeychain || [getUDIDInKeychain isEqualToString:@""] || [getUDIDInKeychain isKindOfClass:[NSNull class]]) {
        
        CFUUIDRef puuid = CFUUIDCreate(nil);
        CFStringRef uuidString  = CFUUIDCreateString(nil, puuid);
        NSString *result        = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        NSLog(@"\n \n \n ______重新存储uuid __________\n \n \n %@",result);
        [CLKeyChain save:KEY_UUID_INSTEAD data:result];
        getUDIDInKeychain = (NSString *)[CLKeyChain load:KEY_UUID_INSTEAD];
    }
//    NSLog(@"最终——————UDID_INSTEAD %@",getUDIDInKeychain);
    
    return getUDIDInKeychain;
}

+ (void)deleteKeyChain{
    [self delete:KEY_UUID_INSTEAD];
}

+ (NSMutableDictionary *)getKeyChainQuery:(NSString *)service{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassGenericPassword,(id)kSecClass,service,(id)kSecAttrService,service,(id)kSecAttrAccount,(id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible, nil];
}

+ (id) load:(NSString *)service {
    
    id ret  = nil;
    NSMutableDictionary *keychainQuery = [self getKeyChainQuery:service];
    
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *) &keyData) == noErr) {
        
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *exception) {
            NSLog(@"Unarchive of %@ failed: %@",service,exception);
        } @finally {
            
        }
    }
    
    if (keyData) {
        CFRelease(keyData);
    }
    return ret;
}

+ (void)delete:(NSString *)service{
    NSMutableDictionary *keychainQuery  = [self getKeyChainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

+ (void)save:(NSString *)service data:(id)data{
    // Get search dictionary
    NSMutableDictionary *keychainQuery  = [self getKeyChainQuery:service];
    // Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    // Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    // Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

@end
