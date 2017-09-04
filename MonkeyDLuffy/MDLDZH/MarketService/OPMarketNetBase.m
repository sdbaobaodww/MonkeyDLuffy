//
//  OPMarketNetBase.m
//  OnePiece
//
//  Created by Duanwwu on 2016/11/11.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPMarketNetBase.h"
#import "OPSocketManager.h"
#import "NSMutableData+SerializeOperation.h"
#import "NSData+SerializeOperation.h"

@interface OPPackageTagGenerator : NSObject

+ (instancetype)sharedInstance;

- (unsigned char)nextPackageTag;

@end

@implementation OPPackageTagGenerator
{
    unsigned char                       _seqId;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static OPPackageTagGenerator *instance = nil;
    dispatch_once(&onceToken, ^{
        instance                        = [[self alloc] init];
    });
    return instance;
}

- (unsigned char)nextPackageTag
{
    if (_seqId > 255)
        _seqId = 1;
    else
        _seqId ++;
    
    if (_seqId == 123 || _seqId == 125)
        _seqId ++;
    
    return _seqId;
}

@end

@implementation OPPackageSubHeader

- (instancetype)initWithTag:(OPResultTagRequest)resultTag type:(unsigned short)subType attrs:(unsigned short)subAttrs
{
    if (self = [super init])
    {
        self.resultTag                  = resultTag;
        self.subType                    = subType;
        self.subAttrs                   = subAttrs;
    }
    return self;
}

- (instancetype)initWithTag:(OPResultTagRequest)resultTag type:(unsigned short)subType
{
    return [self initWithTag:resultTag type:subType attrs:0];
}

- (NSMutableData *)serializeWithBodySize:(unsigned int)bodysize
{
    NSMutableData *data                 = [[NSMutableData alloc] init];
    [data so_writeChar:self.resultTag];
    [data so_writeUnsignedShort:self.subType];
    [data so_writeUnsignedShort:self.subAttrs];
    [data so_writeUnsignedShort:bodysize];
    return data;
}

- (int)deserialize:(NSData *)data pos:(int *)pos
{
    self.resultTag                      = [data so_readChar:pos];
    self.subType                        = [data so_readUnsignedShort:pos];
    self.subAttrs                       = [data so_readUnsignedShort:pos];
    self.subLength                      = [data so_readUnsignedShort:pos];
    return self.subLength;
}

@end

@implementation OPPackageSubHeaderExtend

- (instancetype)initWithTag:(OPResultTagRequest)resultTag type:(unsigned short)subType attrs:(unsigned short)subAttrs extend:(unsigned int)subExtend
{
    if (self = [super init])
    {
        self.resultTag                  = resultTag;
        self.subType                    = subType;
        self.subAttrs                   = subAttrs;
        self.subExtend                  = subExtend;
    }
    return self;
}

- (instancetype)initWithTag:(OPResultTagRequest)resultTag type:(unsigned short)subType attrs:(unsigned short)subAttrs
{
    return [self initWithTag:resultTag type:subType attrs:subAttrs extend:0];
}

- (instancetype)initWithTag:(OPResultTagRequest)resultTag type:(unsigned short)subType
{
    return [self initWithTag:resultTag type:subType attrs:0 extend:0];
}

- (NSMutableData *)serializeWithBodySize:(unsigned int)bodysize
{
    NSMutableData *data                 = [[NSMutableData alloc] init];
    [data so_writeChar:self.resultTag];
    [data so_writeUnsignedShort:self.subType];
    [data so_writeUnsignedShort:self.subAttrs];
    [data so_writeUnsignedShort:bodysize];
    [data so_writeUnsignedInt:self.subExtend];
    return data;
}

- (int)deserialize:(NSData *)data pos:(int *)pos
{
    self.resultTag                      = [data so_readChar:pos];
    self.subType                        = [data so_readUnsignedShort:pos];
    self.subAttrs                       = [data so_readUnsignedShort:pos];
    self.subLength                      = [data so_readUnsignedShort:pos];
    self.subExtend                      = [data so_readUnsignedInt:pos];
    return self.subLength;
}

@end

@implementation OPPackageHeader

- (instancetype)initWithTag:(unsigned char)tag type:(unsigned short)type attrs:(unsigned short)attrs
{
    if (self = [super init])
    {
        self.tag                        = tag;
        self.type                       = type;
        self.attrs                      = attrs;
    }
    return self;
}

- (instancetype)initWithType:(unsigned short)type attrs:(unsigned short)attrs
{
    return [self initWithTag:[[OPPackageTagGenerator sharedInstance] nextPackageTag] type:type attrs:attrs];
}

- (instancetype)initWithType:(unsigned short)type
{
    return [self initWithTag:[[OPPackageTagGenerator sharedInstance] nextPackageTag] type:type attrs:0];
}

- (long)packageId
{
    return self.type * 1000 + self.tag;
}

- (unsigned int)bodySize
{
    return self.length;
}

+ (int)validHeaderMinSize
{
    return 7;
}

- (BOOL)_isHasSubHeader:(unsigned short)type
{
    return (type >= 3000 && type <= 3199) || type == 2972;
}

- (NSMutableData *)serializeWithBodySize:(unsigned int)bodysize
{
    if ([self _isHasSubHeader:self.type] && !self.subHeader)
    {
        [NSException raise:@"IllegalArgumentException" format:@"非法参数，该类型必须具有子包头"];
    }
    
    NSMutableData *data                 = [[NSMutableData alloc] init];
    [data so_writeChar:self.tag];
    [data so_writeUnsignedShort:self.type];
    [data so_writeUnsignedShort:self.attrs];
    if (self.subHeader)
    {
        //数据结构 包头+子包头+内容
        NSData *subData                 = [self.subHeader serializeWithBodySize:bodysize];
        self.length                     = (unsigned int)[subData length] + bodysize;
        [data so_writeUnsignedShort:self.length];
        [data appendData:subData];
    }
    else
    {
        self.length                     = bodysize;
        [data so_writeUnsignedShort:bodysize];
    }
    return data;
}

- (int)deserialize:(NSData *)data pos:(int *)pos
{
    self.tag                            = [data so_readChar:pos];
    self.type                           = [data so_readUnsignedShort:pos];
    self.attrs                          = [data so_readUnsignedShort:pos];
    int attr                            = (_attrs & 0x8) >> 3; //取长度扩充位，当置位时，用int表示数据长度；否则用short表示长度；
    self.length                         = attr == 1 ? [data so_readUnsignedInt:pos] : [data so_readUnsignedShort:pos];
    
    if ([self _isHasSubHeader:self.type])
    {
        OPPackageSubHeader *subHeader   = self.type == 3001 || self.type == 3010 ? [[OPPackageSubHeaderExtend alloc] init] : [[OPPackageSubHeader alloc] init];
        return [subHeader deserialize:data pos:pos];
    }
    else
    {
        return self.length;
    }
}

@end

@implementation OPMarketRequestPackage

- (instancetype)initWithHeader:(id<OPPackageHeaderProtocol>)header
                      response:(id<OPResponsePackageProtocol>)response
{
    return [super initWithHeader:header response:response sender:[OPReuqestPackageSenderMarket instance]];
}

@end

@implementation OPPushableMarketRequestPackage

//一种类型推送只能存在一个
- (BOOL)responseMatch:(id<OPPackageHeaderProtocol>)responseHeader
{
    return self.header.type == responseHeader.type;
}

- (void)registerPush:(OPResponseBlock)pushBlock
{
    [self sendRequest:pushBlock success:nil failure:nil];
}

- (void)unRegisterPush:(OPResponseBlock)pushBlock
{
    self.isUnRegisterPushPackage        = YES;
    [self sendRequest:pushBlock success:nil failure:nil];
}

@end

@implementation OPMarketRequestPackageGroup
{
    NSMutableArray                      *_group;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _group                          = [[NSMutableArray alloc] init];
        self.header                     = [[OPPackageHeader alloc] initWithType:0];
        self.sender                     = [OPReuqestPackageSenderMarket instance];
    }
    return self;
}

- (void)addPackage:(OPRequestPackage *)package
{
    if (package)
        [_group addObject:package];
}

- (OPRequestPackage *)findSinglePackageWithType:(short)type
{
    Class clazz                         = [self class];
    for (OPRequestPackage *package in _group)
    {
        if ([package isKindOfClass:clazz])
        {
            OPRequestPackage *p         = [(OPMarketRequestPackageGroup *)package findSinglePackageWithType:type];
            if (p)
                return p;
        }
        else if (package.header.type == type)
            return package;
    }
    return nil;
}

- (NSArray *)findPackagesWithType:(short)type
{
    Class clazz                         = [self class];
    NSMutableArray *arr                 = [NSMutableArray array];
    for (OPRequestPackage *package in _group)
    {
        if ([package isKindOfClass:clazz])
        {
            NSArray *sub                = [(OPMarketRequestPackageGroup *)package findPackagesWithType:type];
            if (sub)
                [arr addObjectsFromArray:sub];
        }
        else if (package.header.type == type)
        {
            [arr addObject:package];
        }
    }
    return [arr count] > 0 ? arr : nil;
}

#pragma mark - 重载父类方法

- (BOOL)responseMatch:(id<OPPackageHeaderProtocol>)responseHeader
{
    for (OPRequestPackage *package in _group)
    {
        if ([package responseMatch:responseHeader])
            return YES;
    }
    return NO;
}

- (NSData *)serialize
{
    NSMutableData *groupData            = [[NSMutableData alloc] init];
    for (OPRequestPackage *package in _group)
    {
        [groupData appendData:[package serialize]];
    }
    self.status                         = OPRequestStatusSerialized;
    return groupData;
}

- (void)receiveBodyData:(NSData *)body responseHeader:(id<OPPackageHeaderProtocol>)responseHeader
{
    self.status                         = OPRequestStatusReceived;
    for (OPRequestPackage *package in _group)
    {
        if ([package responseMatch:responseHeader])
        {
            [package receiveBodyData:body responseHeader:responseHeader];
            [package setResponseStatus:OPResponseStatusSucess];//响应状态置为success
            break;
        }
    }
}

- (BOOL)isFinished
{
    for (OPRequestPackage *package in _group)
    {
        if (![package isFinished])//只要有未反序列化的包就代表还未结束
            return NO;
    }
    return YES;
}

@end

@implementation OPSocketManagerMarket

- (BOOL)isPushHeader:(OPPackageHeader *)header
{
    return (header.attrs >> 5 & 0x0001) == 1 || header.type == 2907;
}

- (Class<OPPackageHeaderProtocol>)headerClass
{
    return [OPPackageHeader class];
}

@end

@implementation OPReuqestPackageSenderMarket

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    static OPReuqestPackageSenderMarket *instance = nil;
    dispatch_once(&onceToken, ^{
        instance                        = [[self alloc] init];
    });
    return instance;
}

@end

@implementation OPHttpManager

+ (void)httpSendPackage:(id<OPRequestPackageProtocol>)requestPackage toURL:(NSString *)urlStr timeout:(NSTimeInterval)timeout
{
    if ([urlStr length] == 0)
        return;
    
    NSMutableURLRequest *request        = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];
    request.HTTPMethod                  = @"POST";
    request.HTTPBody                    = [requestPackage serialize];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data && !error)
        {
            int pos                                         = 0;
            while ([data length] > pos + [OPPackageHeader validHeaderMinSize])
            {
                int itemPos             = pos;
                id<OPPackageHeaderProtocol> header  = [[OPPackageHeader alloc] init];
                int length              = [header deserialize:data pos:&itemPos];//反序列化包头数据
                if (itemPos + length > data.length)//缺少数据，直接返回error
                {
                    [requestPackage setResponseStatus:OPResponseStatusError];//响应状态置为error
                    break;
                }
                else//数据正常
                {
                    [requestPackage receiveBodyData:length > 0 ? [data subdataWithRange:NSMakeRange(itemPos, length)] : nil responseHeader:header];
                    if ([requestPackage isFinished])//接收结束
                    {
                        [requestPackage setResponseStatus:OPResponseStatusSucess];//响应状态置为Success
                    }
                    pos                 = itemPos + length;
                }
            }
        }
        else
        {
            [requestPackage setResponseStatus:OPResponseStatusError];//响应状态置为error
        }
    }] resume];
}

+ (void)httpSendRequest:(NSURLRequest *)request completion:(OPHttpBlock)completion
{
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (completion)
        {
            data && !error ? completion(data, nil) : completion(nil, error);
        }
        
    }] resume];
}

+ (void)httpSendJsonRequest:(NSURLRequest *)request completion:(OPHttpBlock)completion
{
    [self httpSendRequest:request completion:^(id data, NSError *error) {
        
        if (!completion)
            return;
        
        if (error != nil)
        {
            completion(nil, error);
        }
        else
        {
            if (!data)
            {
                completion(nil, nil);
            }
            else
            {
                NSError *err            = nil;
                id jsonObj              = [NSJSONSerialization JSONObjectWithData:(NSData *)data options:kNilOptions error:&err];
                completion(jsonObj, err);
            }
        }
    }];
}

@end
