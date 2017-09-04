//
//  MDLTools.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/9/1.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDLTools : NSObject

/**
 获取MAC地址
 */
+ (NSString *)macAddress;

/**
 获取机器型号 如iPhone1,2是iphone 3g； iPhone9,2是 iphone 7p
 */
+ (NSString *)platform;

/**
 设备名称 如iphone7、iphone 7 plus
 */
+ (NSString *)deviceName;

/**
 设备可用空间 单位：字节
 */
+(long long)freeSpace;

/**
 设备总空间 单位：字节
 */
+(long long)totalSpace;

/**
 当前设备可用内存
 */
+ (unsigned long)freeMemory;

/**
 当前任务所占用的内存
 */
+ (unsigned long)usedMemory;

/**
 获取IOS操作系统的大版本号，如10.3返回10
 */
+ (NSUInteger)systemMajorVersion;

/**
 通过导航栏获取当前的网络类型，注意事项：1，导航栏被隐藏会获取不到值；2，如果使用了Reachability，收到网络类型变化通知的时候调用此方法，拿不到最新的网络状态；3,连接的WIFI没有联网会识别不到
 */
+ (NSString *)networkTypeFromStatusBar;

/**
 获取运营商
 */
+(NSString *)cellPhoneProvider;

/**
 判断设备是否越狱
 */
+ (BOOL)isDeviceJailBreak;

/**
 获取设备唯一标识，先判断plist是否存在，再判断keychain是否存在，如果都不存在则创建uuid，再依次保存进keychain和plist中
 */
+ (NSString *)getDeviceID;

/**
 32位随机数
 */
+ (NSString *)randomOf32Bits;

/**
 生成UUID
 */
+ (NSString *)uuid;

@end
