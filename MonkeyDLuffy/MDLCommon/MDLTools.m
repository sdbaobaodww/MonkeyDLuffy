//
//  MDLTools.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/9/1.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLTools.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/mount.h>
#import <mach/mach.h>
#import <ifaddrs.h>
#import <UIKit/UIKit.h>
#import <SAMKeychain/SAMKeychain.h>

@implementation MDLTools

+ (NSString *)macAddress {
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

+ (NSString *)platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *machineModel = [NSString stringWithUTF8String:machine];
    free(machine);
    return machineModel;
}

+ (NSString *)deviceName {
    static NSString *deviceType = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *deviceTypes = @{@"iPhone1,1" : @"iPhone",
                                      @"iPhone1,2" : @"iPhone 3G",
                                      @"iPhone2,1" : @"iPhone 3GS",
                                      @"iPhone3,1" : @"iPhone 4 (GSM)",
                                      @"iPhone3,3" : @"iPhone 4 (CDMA)",
                                      @"iPhone4,1" : @"iPhone 4S",
                                      @"iPhone5,1" : @"iPhone 5 (A1428)",
                                      @"iPhone5,2" : @"iPhone 5 (A1429)",
                                      @"iPhone5,3" : @"iPhone 5c (A1456/A1532)",
                                      @"iPhone5,4" : @"iPhone 5c (A1507/A1516/A1529)",
                                      @"iPhone6,1" : @"iPhone 5s (A1433/A1453)",
                                      @"iPhone6,2" : @"iPhone 5s (A1457/A1518/A1530)",
                                      @"iPhone7,1" : @"iPhone 6 Plus",
                                      @"iPhone7,2" : @"iPhone 6",
                                      @"iPhone8,1" : @"iPhone 6s",
                                      @"iPhone8,2" : @"iPhone 6s Plus",
                                      @"iPhone8,4" : @"iPhone SE",
                                      @"iPhone9,1" : @"iPhone 7 (A1660/A1779/A1780)",
                                      @"iPhone9,2" : @"iPhone 7 Plus (A1661/A1785/A1786)",
                                      @"iPhone9,3" : @"iPhone 7 (A1778)",
                                      @"iPhone9,4" : @"iPhone 7 Plus (A1784)",
                                      @"iPad1,1" : @"iPad",
                                      @"iPad2,1" : @"iPad 2 (Wi-Fi)",
                                      @"iPad2,2" : @"iPad 2 (GSM)",
                                      @"iPad2,3" : @"iPad 2 (CDMA)",
                                      @"iPad2,4" : @"iPad 2 (Wi-Fi, revised)",
                                      @"iPad2,5" : @"iPad mini (Wi-Fi)",
                                      @"iPad2,6" : @"iPad mini (A1454)",
                                      @"iPad2,7" : @"iPad mini (A1455)",
                                      @"iPad3,1" : @"iPad (3rd gen, Wi-Fi)",
                                      @"iPad3,2" : @"iPad (3rd gen, Wi-Fi+LTE Verizon)",
                                      @"iPad3,3" : @"iPad (3rd gen, Wi-Fi+LTE AT&T)",
                                      @"iPad3,4" : @"iPad (4th gen, Wi-Fi)",
                                      @"iPad3,5" : @"iPad (4th gen, A1459)",
                                      @"iPad3,6" : @"iPad (4th gen, A1460)",
                                      @"iPad4,1" : @"iPad Air (Wi-Fi)",
                                      @"iPad4,2" : @"iPad Air (Wi-Fi+LTE)",
                                      @"iPad4,3" : @"iPad Air (Rev)",
                                      @"iPad4,4" : @"iPad mini 2 (Wi-Fi)",
                                      @"iPad4,5" : @"iPad mini 2 (Wi-Fi+LTE)",
                                      @"iPad4,6" : @"iPad mini 2 (Rev)",
                                      @"iPad4,7" : @"iPad mini 3 (Wi-Fi)",
                                      @"iPad4,8" : @"iPad mini 3 (A1600)",
                                      @"iPad4,9" : @"iPad mini 3 (A1601)",
                                      @"iPad5,1" : @"iPad mini 4 (Wi-Fi)",
                                      @"iPad5,2" : @"iPad mini 4 (Wi-Fi+LTE)",
                                      @"iPad5,3" : @"iPad Air 2 (Wi-Fi)",
                                      @"iPad5,4" : @"iPad Air 2 (Wi-Fi+LTE)",
                                      @"iPad6,3" : @"iPad Pro (9.7 inch) (Wi-Fi)",
                                      @"iPad6,4" : @"iPad Pro (9.7 inch) (Wi-Fi+LTE)",
                                      @"iPad6,7" : @"iPad Pro (12.9 inch, Wi-Fi)",
                                      @"iPad6,8" : @"iPad Pro (12.9 inch, Wi-Fi+LTE)",
                                      @"iPad6,11" : @"iPad 9.7-Inch 5th Gen (Wi-Fi Only)",
                                      @"iPad6,12" : @"iPad 9.7-Inch 5th Gen (Wi-Fi/Cellular)",
                                      @"iPod1,1" : @"iPod touch",
                                      @"iPod2,1" : @"iPod touch (2nd gen)",
                                      @"iPod3,1" : @"iPod touch (3rd gen)",
                                      @"iPod4,1" : @"iPod touch (4th gen)",
                                      @"iPod5,1" : @"iPod touch (5th gen)",
                                      @"iPod7,1" : @"iPod touch (6th gen)",
                                      @"i386" : @"iPhone Simulator",
                                      @"x86_64" : @"iPhone Simulator",
                                      };
        NSString *platform = [self platform];
        deviceType = [deviceTypes objectForKey:platform];
        
        if (!deviceType) {
            if ([platform hasPrefix:@"iPhone4"]) {
                deviceType = @"iPhone4s";
            } else if ([platform hasPrefix:@"iPhone3"]) {
                deviceType = @"iPhone4";
            } else if ([platform hasPrefix:@"iPhone2"]) {
                deviceType = @"iPhone3Gs";
            } else {
                deviceType = @"iPad/iPod";
            }
        }
    });
    
    return deviceType;
}

+ (long long)freeSpace {
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/private/var", &buf) >= 0){
        freespace = (long long)buf.f_bsize * buf.f_bfree;
    }
    return freespace;
}

+ (long long)totalSpace {
    struct statfs buf;
    long long totalspace = -1;
    if(statfs("/private/var", &buf) >= 0){
        totalspace = (long long)buf.f_bsize * buf.f_blocks;
    }
    return totalspace;
}

+ (unsigned long)freeMemory {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return vm_stat.free_count * pagesize;
}

+ (unsigned long)usedMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0;
}

+ (NSUInteger)systemMajorVersion {
    static NSUInteger _deviceSystemMajorVersion = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

+ (NSString *)networkTypeFromStatusBar {
    NSArray *children = [[[[UIApplication sharedApplication] valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSString *state = nil;
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            switch ([[child valueForKeyPath:@"dataNetworkType"] intValue]) {
                case 0:
                    state = @"无网络";
                    break;
                case 1:
                    state = @"2G";
                    break;
                case 2:
                    state = @"3G";
                    break;
                case 3:
                    state = @"4G";
                    break;
                case 5:
                    state = @"WIFI";
                    break;
                default:
                    state = @"未知";
                    break;
            }
        }
    }
    return state;
}

+(NSString*)cellPhoneProvider {
    CTTelephonyNetworkInfo* info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *mobileProvider= [NSString stringWithFormat:@"%@%@",info.subscriberCellularProvider.mobileCountryCode,info.subscriberCellularProvider.mobileNetworkCode];
    return mobileProvider;
}

+ (BOOL)isDeviceJailBreak {
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]){
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]){
        jailbroken = YES;
    }
    return jailbroken;
}

+ (NSString *)getDeviceID {
    NSString * const deviceIdUserDefaultKey = @"MonkeyDLuffy_DeviceId_Key";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *cachedDeviceId = [defaults objectForKey:deviceIdUserDefaultKey];
    if(cachedDeviceId && ![cachedDeviceId isEqualToString:@""]){
        return cachedDeviceId;
    }
    
    NSString *strUUID = [SAMKeychain passwordForService:@"com.duan.monkeydluffy" account:deviceIdUserDefaultKey];
    if ( !strUUID ) {
        strUUID = [self uuid];
        [SAMKeychain setPassword:strUUID forService:@"com.duan.monkeydluffy" account:deviceIdUserDefaultKey];
    }
    
    cachedDeviceId = strUUID;
    
    [defaults setObject:cachedDeviceId forKey:deviceIdUserDefaultKey];
    [defaults synchronize];
    
    return cachedDeviceId;
}

+ (NSString *)randomOf32Bits {
    char data[32];
    for (int x = 0; x < 32; data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
}

+ (NSString *)uuid {
    return CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault,CFUUIDCreate(kCFAllocatorDefault)));
}

@end
