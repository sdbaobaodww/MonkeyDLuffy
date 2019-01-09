//
//  ViewController.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/10.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "MDLInfinityRingView.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<MDLInfinityRingViewDataSource, MDLInfinityRingViewDelegate>

@end

@implementation ViewController {
    MDLInfinityRingView *_ringView;
    UITextField *_textField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = self.view.frame;
    MDLInfinityRingView *ringView = [[MDLInfinityRingView alloc] initWithFrame:CGRectMake(.0, 150., frame.size.width, frame.size.height - 200.) initDataIndex:5 dataCount:20];
    ringView.dataSource = self;
    ringView.delegate = self;
    [self.view addSubview:ringView];
    _ringView = ringView;
    
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(20., 100., 100., 40)];
    field.placeholder = @"19";
    field.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:field];
    _textField = field;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"移动" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(moveToData) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor blueColor];
    btn.frame = CGRectMake(140., 100., 100., 40);
    [self.view addSubview:btn];
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setTitle:@"RAC" forState:UIControlStateNormal];
//    btn.backgroundColor = [UIColor blueColor];
//    btn.frame = CGRectMake(100, 100, 100, 60);
//    [self.view addSubview: btn];
//
//    RACSignal *tapRAC = [btn rac_signalForControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
//    [tapRAC subscribeNext:^(id  _Nullable x) {
//        [self tapBtn];
//    }];
//
//    [[self rac_signalForSelector:@selector(tapBtn)] subscribeNext:^(id _Nullable x) {
//        NSLog(@"生成点击信息");
//    }];
}

- (void)moveToData {
    NSInteger page = [[_textField.text length] > 0 ? _textField.text : _textField.placeholder integerValue];
    [_ringView scrollToDataIndex:page animated:YES];
}

- (void)tapBtn {
    NSLog(@"点击。。。。。");
}

#pragma mark - MDLInfinityRingViewDataSource

- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView willDestroyItemView:(UIView *)view atItemIndex:(NSInteger)itemIndex dataIndex:(NSInteger)dataIndex {
    
}

- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView didDestroyItemView:(UIView *)view atItemIndex:(NSInteger)itemIndex dataIndex:(NSInteger)dataIndex {
    
}

- (NSInteger)numberOfItemsInInfinityRingView:(MDLInfinityRingView *)infinityRingView {
    return 3;
}

- (UIView *)infinityRingView:(MDLInfinityRingView *)infinityRingView buildSubringAtIndex:(NSInteger)index {
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.layer.borderColor = [UIColor redColor].CGColor;
    v.layer.borderWidth = 1.;
    v.backgroundColor = [UIColor grayColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:v.bounds];
    label.font = [UIFont boldSystemFontOfSize:32];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 11111;
    [v addSubview:label];
    return v;
}

- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView
           updateSubring:(UIView *)subring
        withSubringIndex:(NSInteger)subringIndex
               dataIndex:(NSInteger)dataIndex {
//    [(WKWebView *)view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    UILabel *label = [subring viewWithTag:11111];
    label.text = [NSString stringWithFormat:@"%ld__%ld", subringIndex, dataIndex];
    NSLog(@"更新子环数据:%ld  %ld", subringIndex, dataIndex);
}

- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView
             hideSubring:(UIView *)subring
        withSubringIndex:(NSInteger)subringIndex
               dataIndex:(NSInteger)dataIndex {
    NSLog(@"隐藏子环:%ld  %ld", subringIndex, dataIndex);
}

- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView
          displaySubring:(UIView *)subring
        withSubringIndex:(NSInteger)subringIndex
               dataIndex:(NSInteger)dataIndex {
    NSLog(@"显示子环:%ld  %ld", subringIndex, dataIndex);
}

@end
