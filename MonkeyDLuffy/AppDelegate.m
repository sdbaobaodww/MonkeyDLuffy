//
//  AppDelegate.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/10.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "AppDelegate.h"
#import "MDLIOCInjector.h"
#import "MDLIOCTestModel.h"
#import "MDLProtocolProxy.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    id<YingXiangProtocol> yingxiang = [MDLIOCGetter instanceForProtocol:@protocol(YingXiangProtocol)];
    id<Board> board = [MDLIOCGetter instanceForProtocol:@protocol(Board)];
    
    id<Board,NSObject> board1 = [[WanLiYangGuangHao alloc] init];
    id<Board,NSObject> board2 = [[MaliHao alloc] init];
    id<Board,NSObject> board3 = [[HuangjinMaliHao alloc] init];
    MDLProtocolProxy *proxy = [[MDLProtocolProxy alloc] initWithProtocol:@protocol(Board)];
    
    [proxy addProtocolImplWithClass:[board1 class]];
    [proxy addProtocolImplWithClass:[board2 class]];
    [proxy addProtocolImplWithClass:[board3 class]];
    
    [(id<Board>)proxy fight];
    [(id<Board>)proxy say:@"向前冲"];
    [(id<Board>)proxy victor:@"1111" song:@"222"];
    
    [TestFactory enterFactory];
    NSLog(@"enterCount:%d",[TestFactory enterCount]);
    [TestFactory enterFactory];
    NSLog(@"enterCount:%d",[TestFactory enterCount]);
    [TestFactory enterFactory];
    NSLog(@"enterCount:%d",[TestFactory enterCount]);
    [TestFactory exitFactory];
    NSLog(@"enterCount:%d",[TestFactory enterCount]);
    [TestFactory exitFactory];
    NSLog(@"enterCount:%d",[TestFactory enterCount]);
    [TestFactory exitFactory];
    NSLog(@"enterCount:%d",[TestFactory enterCount]);
    
    return YES;
}

- (void)function1 {


}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
