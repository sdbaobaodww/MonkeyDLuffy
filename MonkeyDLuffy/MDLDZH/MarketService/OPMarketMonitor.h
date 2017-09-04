//
//  OPSocketMonitor.h
//  OnePiece
//
//  Created by Duanwwu on 16/10/27.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPSocketManager.h"

@interface OPSocketMonitorTimeout : NSObject<OPSocketManagerMonitorProtocol>

@end

@interface OPSocketMonitorNetLog : NSObject<OPSocketManagerMonitorProtocol>

@end

@interface OPSocketMonitorHeartBeat : NSObject<OPSocketManagerMonitorProtocol>

@end
