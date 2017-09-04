//
//  OPPackageBase.m
//  OnePiece
//
//  Created by Duanwwu on 16/10/25.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPPackageBase.h"

@implementation OPRequestPackage

- (instancetype)initWithHeader:(id<OPPackageHeaderProtocol>)header
                      response:(id<OPResponsePackageProtocol>)response
                        sender:(id<OPReuqestPackageSenderProtocol>)sender
{
    if (self = [super init])
    {
        self.header             = header;
        self.response           = response;
        self.sender             = sender;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithHeader:nil response:nil sender:nil];
}

- (BOOL)responseMatch:(id<OPPackageHeaderProtocol>)responseHeader
{
    return self.header.packageId == responseHeader.packageId;
}

- (void)setStatus:(OPRequestStatus)status
{
    if (_status != status)
    {
        _status                 = status;
        
        if (self.stautsNotify)
            self.stautsNotify(status, self);
    }
}

- (void)setResponseStatus:(OPResponseStatus)responseStatus
{
    if (_responseStatus != responseStatus)
    {
        _responseStatus         = responseStatus;
        
        if (self.responseCompletion)
            self.responseCompletion(responseStatus, self);
        
        if (responseStatus == OPResponseStatusSucess)
        {
            if (self.responseSuccess)
                self.responseSuccess(responseStatus, self);
        }
        else
        {
            if (self.responseFailure)
                self.responseFailure(responseStatus, self);
        }
    }
}

- (void)generateResponsePackage:(id<OPPackageHeaderProtocol>)responseHeader
{
    
}

- (NSMutableData *)wrapBody:(NSData *)bodyData
{
    if (bodyData == nil)//空包头
    {
        NSMutableData *data     = [self.header serializeWithBodySize:0];
        _status                 = OPRequestStatusSerialized;
        return data;
    }
    else
    {
        NSMutableData *data     = [self.header serializeWithBodySize:(unsigned int)bodyData.length];
        [data appendData:bodyData];
        _status                 = OPRequestStatusSerialized;
        return data;
    }
}

- (NSData *)serializeBody
{
    return nil;
}

- (NSData *)serialize
{
    return [self wrapBody:[self serializeBody]];
}

- (void)sendRequest:(OPResponseBlock)completion success:(OPResponseBlock)success failure:(OPResponseBlock)failure
{
    self.responseCompletion     = completion;
    self.responseSuccess        = success;
    self.responseFailure        = failure;
    [self.sender sendPackage:self];
}

- (void)sendRequest
{
    [self.sender sendPackage:self];
}

- (void)receiveBodyData:(NSData *)body responseHeader:(id<OPPackageHeaderProtocol>)responseHeader
{
    self.status                 = OPRequestStatusReceived;
    if (self.response == nil)
        [self generateResponsePackage:responseHeader];
    self.response.header        = responseHeader;
    if (body)//如果包内容存在，则进行解析
    {
        [self.response deSerialize:body];
    }
    self.status                 = OPRequestStatusDeSerialized;
}

- (BOOL)isFinished
{
    return (_ignorResponse && _status == OPRequestStatusSended) || _status == OPRequestStatusDeSerialized;
}

@end

@implementation OPResponsePackage

- (void)deSerialize:(NSData *)body
{
    
}

- (BOOL)isEmptyResponse
{
    return [self.header bodySize] == 0;
}

@end
