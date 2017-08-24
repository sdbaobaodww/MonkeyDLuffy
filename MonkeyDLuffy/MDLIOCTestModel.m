//
//  MDLIOCTestModel.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/18.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLIOCTestModel.h"

@implementation Lufei

- (void)fight {
    NSLog(@"我是路飞，看我的橡胶机关枪");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 我是热血海贼路飞！", self];
}

@end

@implementation Suolong

- (void)fight {
    NSLog(@"我是索隆，看我的三千大千世界");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 我是路痴海贼索隆！", self];
}

@end

@implementation Chiquan

- (void)fight {
    NSLog(@"我是赤犬，看我的犬啮红莲");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 我是绝对正义赤犬！", self];
}

@end

@implementation Kuzan

- (void)fight {
    NSLog(@"我是库赞，看我的冰河时代");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 我是懒散正义库赞！", self];
}

@end

@implementation MaLinFuDuo

- (void)fight {
    NSLog(@"这里是马林福多");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 海军本部马林福多！", self];
}

@end

@implementation SiFaDao

- (void)fight {
    NSLog(@"这里是司法岛");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 世界政府司法岛！", self];
}

@end

@implementation BaiHuziDie

- (void)fight {
    NSLog(@"白胡子战死了");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 白胡子死了！", self];
}

@end

@implementation HeiHuziSmile

- (void)fight {
    NSLog(@"黑胡子笑了");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 黑胡子笑了！", self];
}

@end

//事件
@implementation Event

mdlioc_requires(@"haizei",@"haijun",@"zhanchang")

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[MDLIOCInjector shareInstance] injector:self];
    }
    return self;
}

- (void)story {
    [self.zhanchang fight];
    [self.haizei fight];
    [self.haijun fight];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 事件", self];
}

@end

@implementation BigEvent

mdlioc_requires(@"jieguo")

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[MDLIOCInjector shareInstance] injector:self];
    }
    return self;
}

- (void)story {
    [super story];
    [self.jieguo fight];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 大事件", self];
}

@end

@implementation LufeiUp

#ifdef PreRegisterFlag
mdlioc_register_normal(@protocol(YingXiangProtocol))
#endif

- (void)fight {
    NSLog(@"路飞赏金变高");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 全是贝里", self];
}

@end

@implementation BigBigEvent

mdlioc_requires(@"yingxiang")

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[MDLIOCInjector shareInstance] injector:self];
    }
    return self;
}

- (void)story {
    [super story];
    [self.yingxiang fight];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 大大事件", self];
}

@end

@implementation WanLiYangGuangHao

- (void)fight {
    NSLog(@"万里阳光号");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 万里阳光号", self];
}

@end

@implementation MaliHao

#ifdef PreRegisterFlag
mdlioc_register_global(@protocol(Board))
#endif

- (void)fight {
    NSLog(@"梅里号");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> 梅里号", self];
}

@end
