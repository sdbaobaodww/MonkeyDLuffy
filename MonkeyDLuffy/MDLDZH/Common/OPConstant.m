//
//  OPConstant.m
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPConstant.h"
#import "OPLog.h"
#import "SSKeychain.h"

@implementation OPConstant

+ (NSArray *)SchedulingServerAddress
{
    return @[@"222.73.34.8:12346",@"222.73.103.42:12346",@"61.151.252.4:12346",@"61.151.252.14:12346"];
}

+ (NSString *)uuidString
{
    CFUUIDRef uuid              = CFUUIDCreate(NULL);
    NSString *uuidString        = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    NSString *str               = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(uuid);
    str                         = [str length] >= 12 ? [str substringFromIndex:[str length]-12] : str;
    return str;
}

+ (NSString *)generateChannelNumber
{
    NSString *suffix            = [self uuidString];
    NSString * retVal           = [NSString stringWithFormat:@"%@%@", ChannelNo, suffix];
    int nLen                    = 19 - (int)[retVal length];
    int nRand                   = 0;
    // 随机生成填补位数
    for (int i = 0; i < nLen; i++)
    {
        nRand = arc4random() % 10;
        retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"%d",nRand]];
    }
    return retVal;
}

+ (NSString *)deviceId
{
    NSString *svc               = [NSString stringWithFormat:@"%@.%@",KeyChainAccessGroup,DeviceIDKey];
    NSString *act               = @"com.gw";
    NSString *deviceId          = [SSKeychain passwordForService:svc account:act];
    if (deviceId.length == 0)
    {
        deviceId                = [[self userPreferenceConfigDic] objectForKey:DeviceIDKey];
        if (deviceId.length > 0)
        {
            [SSKeychain setPassword:deviceId forService:svc account:act];
        }
    }
    
    if (deviceId.length == 0)
    {
        deviceId                = [self generateChannelNumber];
        NSError *err            = nil;
        [SSKeychain setPassword:deviceId forService:svc account:act error:&err];
        if (err) {
            [self saveAttributeWithKey:DeviceIDKey value:deviceId];
            OPLOG_ERROR(OPLogModuleCommon, @"设置ChannelNo错误Code:%@:%@", @([err code]), [err localizedDescription]);
        }
    }
    return deviceId;
}

+ (NSString *)versionNumber
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (void)saveAttributeWithKey:(NSString *)key value:(id)value
{
    @synchronized(self)
    {
        [[self userPreferenceConfigDic] setObject:value forKey:key];
        NSString *dataPath      = [self _getDocumentFilePath:@"user.plist"];
        if (![[self userPreferenceConfigDic] writeToFile:dataPath atomically:YES])
        {
            OPLOG_ERROR(OPLogModuleCommon, @"sysnchronized user preference failed");
        }
    }
}

+ (NSMutableDictionary*)userPreferenceConfigDic
{
    static NSMutableDictionary *_userPrefer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *dataPath      = [self _getDocumentFilePath:@"user.plist"];
        _userPrefer             = [[NSMutableDictionary alloc] initWithContentsOfFile:dataPath];
        
        if (!_userPrefer)
            _userPrefer         = [[NSMutableDictionary alloc] init];
    });
    return _userPrefer;
}

+ (NSString *)_getDocumentFilePath:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
    return filepath;
}

@end
