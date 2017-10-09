//
//  MDLIOCTestModel.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/18.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDLIOC.h"

#define PreRegisterFlag

//海贼协议
@protocol HaizeiProtocol <NSObject>

//战斗吧少年
- (void)fight;

@end

//艾斯
@interface Ais : NSObject<HaizeiProtocol>

@end

//路飞君
@interface Lufei : NSObject<HaizeiProtocol>

@end

//索隆君
@interface Suolong : NSObject<HaizeiProtocol>

@end

//海军协议
@protocol HaiJunProtocol <NSObject>

//战斗吧大叔
- (void)fight;

@end

//赤犬
@interface Chiquan : NSObject<HaiJunProtocol>

@end

//库赞
@interface Kuzan : NSObject<HaiJunProtocol>

@end

//战场协议
@protocol ZhanChangProtocol <NSObject>

//我们在此战斗
- (void)fight;

@end

//马林福多
@interface MaLinFuDuo : NSObject <ZhanChangProtocol>

@end

//司法岛
@interface SiFaDao : NSObject <ZhanChangProtocol>

@end

//事件
@interface Event : NSObject<MDLInjectable>

@property (nonatomic, strong) id<HaizeiProtocol> haizei;//海贼
@property (nonatomic, strong) id<HaiJunProtocol> haijun;//海军
@property (nonatomic, strong) id<ZhanChangProtocol> zhanchang;//战场

- (void)story;

@end

//结果
@protocol JieGuoProtocol <NSObject>

- (void)fight;

@end

//白胡子死了
@interface BaiHuziDie : NSObject<JieGuoProtocol>

@end

//黑胡子笑了
@interface HeiHuziSmile : NSObject<JieGuoProtocol>

@end

//大事件
@interface BigEvent : Event

@property (nonatomic, strong) id<JieGuoProtocol> jieguo;//结果

@end

//影响协议
@protocol YingXiangProtocol <NSObject>

- (void)fight;

@end

//路飞赏金变高
@interface LufeiUp : NSObject <YingXiangProtocol>

@end

//大大事件
@interface BigBigEvent : BigEvent

@property (nonatomic, strong) id<YingXiangProtocol> yingxiang;//影响

@end

//船
@protocol Board

- (void)fight;

- (void)say:(NSString *)str;

+ (void)victor:(NSString *)eat song:(NSString *)song;

@end

//万里阳光号
@interface WanLiYangGuangHao : NSObject<Board>

@end

//梅里号
@interface MaliHao : NSObject<Board>

@end

//黄金梅里号
@interface HuangjinMaliHao : MaliHao

@end

//动画工厂
@interface TestFactory : MDLIOCBeanFactoryAbstract

@end

//恶魔果实
@protocol DevilNut <MDLIOCBundle>

- (void)eat;

@end

//烧烧果实
@interface FireDevilNut : NSObject<DevilNut>

@end

//橡胶果实
@interface RubberDevilNut : NSObject<DevilNut>

@end

//暗暗果实
@interface DarkDevilNut : NSObject<DevilNut>

@end
