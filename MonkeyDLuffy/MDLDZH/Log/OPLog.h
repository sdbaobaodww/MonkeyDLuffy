//
//  OPLog.h
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

//日志级别
typedef NS_ENUM(NSUInteger, OPLogLevel) {
    OPLogLevelDebug,
    OPLogLevelInfo,
    OPLogLevelWarn,
    OPLogLevelError
};

static inline const char * LogLevelToString(OPLogLevel level) {
    switch (level) {
        case OPLogLevelDebug:
            return "DEBUG";
        case OPLogLevelInfo:
            return "INFO";
        case OPLogLevelWarn:
            return "WARN";
        case OPLogLevelError:
            return "ERROR";
        default:
            return "";
    }
}

//日志所在的模块
typedef NS_ENUM(NSUInteger, OPLogModule) {
    OPLogModuleView,//视图模块
    OPLogModuleController,//视图控制器模块
    OPLogModuleModel,//数据模型模块
    OPLogModuleService,//业务模块
    OPLogModuleCommon,//通用模块
    OPLogModuleNetService,//网络业务模块
    OPLogModuleSocket,//socket模块
    OPLogModuleHTTP,//http模块
};

//日志输出开关，用于控制级别和模块
typedef NS_ENUM(NSUInteger, OPLogSwitch) {
    OPLogSwitchAll,         //所有类型
    OPLogSwitchLimit,       //限定类型
    OPLogSwitchOff          //关闭
};

static inline const char * LogModuleToString(OPLogModule module) {
    switch (module) {
        case OPLogModuleView:
            return "VIEW";
        case OPLogModuleController:
            return "CONTROLLER";
        case OPLogModuleModel:
            return "MODEL";
        case OPLogModuleService:
            return "SERVICE";
        case OPLogModuleNetService:
            return "NETSERVICE";
        case OPLogModuleCommon:
            return "COMMON";
        case OPLogModuleSocket:
            return "SOCKET";
        case OPLogModuleHTTP:
            return "HTTP";
        default:
            return "";
    }
}

//日志级别开关，如果为OPLogSwitchAll，则所有大于等于OP_LOG_LEVEL级别的日志信息都将显示；如果为OPLogSwitchLimit则只有OP_LOG_LEVEL对应的级别能显示，如果为OPLogSwitchOff则关闭日志显示
static OPLogSwitch OP_LOG_LEVEL_SWITCH          = OPLogSwitchAll;

//日志模块开关，如果为OPLogSwitchAll，则所有模块的日志信息都将显示；如果为OPLogSwitchLimit则只有OP_LOG_MODULE对应的模块能显示，如果为OPLogSwitchOff则关闭日志显示
static OPLogSwitch OP_LOG_MODULE_SWITCH         = OPLogSwitchAll;//所有模块

static OPLogLevel OP_LOG_LEVEL                  = OPLogLevelDebug;
static OPLogModule OP_LOG_MODULE                = OPLogModuleSocket;

static inline void _OPWriteLog(OPLogModule module, OPLogLevel level, const char *file, const char *function, int lineNumber, NSString *format, ...)
{
    if (OP_LOG_LEVEL_SWITCH == OPLogSwitchOff || OP_LOG_MODULE_SWITCH == OPLogSwitchOff)//关闭日志
        return;
    
    if (
        ((OP_LOG_MODULE_SWITCH == OPLogSwitchAll && level >= OP_LOG_LEVEL) || (OP_LOG_MODULE_SWITCH == OPLogSwitchLimit && level == OP_LOG_LEVEL))
        || (OP_LOG_MODULE_SWITCH == OPLogSwitchAll || (OP_LOG_MODULE_SWITCH == OPLogSwitchLimit && OP_LOG_MODULE == module))
        )
    {
        va_list args;
        va_start(args, format);
        NSString *message                       = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
//        const char *fileName                    = [[[NSString stringWithUTF8String:file] lastPathComponent] UTF8String];
//        fprintf(stderr,"\n[%s-%s]%s:%d %s %s",LogModuleToString(module), LogLevelToString(level), fileName, lineNumber, function, [message UTF8String]);
        fprintf(stdout,"\n[%s-%s]%s#Line:%d %s",LogModuleToString(module), LogLevelToString(level), function, lineNumber, [message UTF8String]);
    }
}

#define OPLOG_DEBUG(module,format, ...)         _OPWriteLog(module, OPLogLevelDebug, __FILE__, __FUNCTION__, __LINE__, format, ##__VA_ARGS__)
#define OPLOG_INFO(module,format, ...)          _OPWriteLog(module, OPLogLevelInfo, __FILE__, __FUNCTION__, __LINE__, format, ##__VA_ARGS__)
#define OPLOG_WARN(module,format, ...)          _OPWriteLog(module, OPLogLevelWarn, __FILE__, __FUNCTION__, __LINE__, format, ##__VA_ARGS__)
#define OPLOG_ERROR(module,format, ...)         _OPWriteLog(module, OPLogLevelError, __FILE__, __FUNCTION__, __LINE__, format, ##__VA_ARGS__)


