//
//  MDLTraceManager.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/9/1.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLTraceManager.h"
#import "MDLTools.h"
#import <UIKit/UIKit.h>
#import "MDLTrace.h"

#define MAX_FILE_SIZE (1024 * 10)

@interface MDLTraceConfig : JSONModel

@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *os;
@property (nonatomic, copy) NSString *osVersion;
@property (nonatomic, copy) NSString *network;

@end

@implementation MDLTraceConfig

- (instancetype)init {
    if (self = [super init]) {
        _deviceName = [MDLTools deviceName];
        
        UIDevice *divice = [UIDevice currentDevice];
        _os = [divice systemName];
        _osVersion = [divice systemVersion];
    }
    return self;
}

@end

@implementation MDLTraceManager {
    NSHashTable<MDLTrace *> *_traceRecords;
    MDLTraceConfig *_config;
    int _fileSize;
    dispatch_queue_t _writeQueue;
}

+(instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _traceRecords = [NSHashTable<MDLTrace *> weakObjectsHashTable];
        _config = [[MDLTraceConfig alloc] init];
        _writeQueue = dispatch_queue_create("com.duan.mdltrace.queue", nil);
        [self _createFile];
    }
    return self;
}

- (void)_createFile {
    _fileSize = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dirPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0]
                         stringByAppendingPathComponent:@"mdltrace"];
    if (![fm fileExistsAtPath:dirPath]) {
        [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    _currentTraceFile = [dirPath stringByAppendingString:[NSString stringWithFormat:@"/%@_%@", [NSDate new], @"event.trace"]];
    [fm createFileAtPath:_currentTraceFile contents:nil attributes:nil];
}

- (void)_writeData:(NSData *)data {
    if ([data length] > 0) {
        dispatch_async(_writeQueue, ^{
            NSFileHandle *traceHandle = [NSFileHandle fileHandleForUpdatingAtPath:_currentTraceFile];
            [traceHandle seekToEndOfFile];
            [traceHandle writeData:data];
            [traceHandle closeFile];
            
            _fileSize += [data length];
            
            if (_fileSize > MAX_FILE_SIZE) {
                [self _createFile];
                [self _uploadDataAtPath:[_currentTraceFile copy]];
            };
        });
    }
}

- (void)_uploadDataAtPath:(NSString *)file {
    
}

#pragma mark - 记录管理

- (void)addTrace:(MDLTrace *)trace {
    [_traceRecords addObject:trace];
}

- (void)removeTrace:(MDLTrace *)trace {
    [_traceRecords removeObject:trace];
}

- (BOOL)hasTrace:(MDLTrace *)trace {
    return [_traceRecords containsObject:trace];
}

#pragma mark - 记录存储

- (void)saveTrace:(MDLTrace *)trace {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[trace toDictionary]];
    _config.network = [MDLTools networkTypeFromStatusBar];
    [dict addEntriesFromDictionary:[_config toDictionary]];
    
    NSMutableData *wrapData = [NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:NULL]];
    if ([wrapData length] == 0) {
        return;
    }
    
    char *buffer = malloc(1);
    *buffer = '\n';
    [wrapData appendBytes:buffer length:1];//添加换行符
    free(buffer);
    
    [self _writeData:wrapData];
}

- (void)saveAndRemoveTrace:(MDLTrace *)trace {
    if (trace) {
        [self saveTrace:trace];
        [self removeTrace:trace];
    }
}

@end
