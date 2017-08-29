//
//  ViewController.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/10.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"RAC" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor blueColor];
    btn.frame = CGRectMake(100, 100, 100, 60);
    [self.view addSubview: btn];
    
    RACSignal *tapRAC = [btn rac_signalForControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [tapRAC subscribeNext:^(id  _Nullable x) {
        [self tapBtn];
    }];
    
    [[self rac_signalForSelector:@selector(tapBtn)] subscribeNext:^(id _Nullable x) {
        NSLog(@"生成点击信息");
    }];
}

- (void)tapBtn {
    NSLog(@"点击。。。。。");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
