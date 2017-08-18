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
    NSLog(@"看我的橡胶机关枪");
}

@end

@implementation Suolong

- (void)fight {
    NSLog(@"看我的三千大千世界");
}

@end

@implementation Chiquan

- (void)fight {
    NSLog(@"看我的犬啮红莲");
}

@end

@implementation Kuzan

- (void)fight {
    NSLog(@"看我的冰河时代");
}

@end

@implementation MaLinFuDuo

- (void)fight {
    NSLog(@"这里是马林福多");
}

@end

@implementation SiFaDao

- (void)fight {
    NSLog(@"这里是司法岛");
}

@end

@implementation BaiHuziDie

- (void)fight {
    NSLog(@"我是白胡子，我战死了");
}

@end

@implementation HeiHuziSmile

- (void)fight {
    NSLog(@"我是黑胡子，我笑了");
}

@end

//事件
@implementation Event

mdlioc_requires(@"haizei",@"haijun",@"zhanchang")

- (void)story {
    [self.zhanchang fight];
    [self.haizei fight];
    [self.haijun fight];
}

@end

@implementation BigEvent

mdlioc_requires(@"jieguo")

- (void)story {
    [super story];
    [self.jieguo fight];
}

@end

@implementation LufeiUp

- (void)fight {
    NSLog(@"路飞赏金变高");
}

@end

@implementation BigBigEvent

mdlioc_requires(@"yingxiang")

- (void)story {
    [super story];
    [self.yingxiang fight];
}

@end
