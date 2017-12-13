//
//  MDLInfinityRingView.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/11/13.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDLInfinityRingView;

@protocol MDLGoldRingItemBuilder

- (void)willBuildItem:(MDLInfinityRingView *)infinityRingView;

- (UIView *)buildItemAtIndex:(NSInteger)index infinityRingView:(MDLInfinityRingView *)infinityRingView;

@end

@protocol MDLInfinityRingViewDelegate <NSObject>

@end

@protocol MDLInfinityRingViewDataSource <NSObject>

- (UIView *)infinityRingView:(MDLInfinityRingView *)infinityRingView buildSubringAtIndex:(NSInteger)index withFrame:(CGRect)frame;

- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView updateSubring:(UIView *)view dataIndex:(NSInteger)dataIndex;

@optional

/**
 使用多少个子环进行展示，如果不实现则使用默认值，默认为3个子环，子环个数必须为奇数，否则会报错
 @param infinityRingView 无限环视图
 @return 子环个数
 */
- (NSInteger)numberOfSubringInInfinityRingView:(MDLInfinityRingView *)infinityRingView;

//
- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView willUpdateSubring:(UIView *)view dataIndex:(NSInteger)dataIndex;

- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView didUpdateSubring:(UIView *)view dataIndex:(NSInteger)dataIndex;

@end

/**
 无限环视图，用于控制处理以有限几个（最少3个）视图滑动展示无限多数据的情况
 */
@interface MDLInfinityRingView : UIView

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, weak) id<MDLInfinityRingViewDelegate> delegate;

@property (nonatomic, weak) id<MDLInfinityRingViewDataSource> dataSource;

/**
 无限环视图初始化方法
 @param frame 视图显示区域
 @param initIndex 进入时的数据的位置
 @param dataCount 数据总个数
 @return 无限环视图
 */
- (instancetype)initWithFrame:(CGRect)frame initIndex:(NSInteger)initIndex dataCount:(NSInteger)dataCount;

/**
 滑动到指定数据索引处
 @param dataIndex 数据索引
 */
- (void)scrollToDataIndex:(NSInteger)dataIndex;

@end
