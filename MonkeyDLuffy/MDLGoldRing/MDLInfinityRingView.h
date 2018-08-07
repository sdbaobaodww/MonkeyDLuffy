//
//  MDLInfinityRingView.h
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/11/13.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import <UIKit/UIKit.h>

//无限环边界状态
typedef NS_ENUM(NSInteger, InfinityRingEdgeStatus) {
    InfinityRingEdgeStart,     //触碰到左边界
    InfinityRingEdgeEnd,       //触碰到右边界
    InfinityRingEdgeNone,      //中间滑动变换视图位置，没触碰到任何边界
};


@class MDLInfinityRingView;

@protocol MDLInfinityRingViewDelegate <NSObject>

- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView didDisplaySubring:(UIView *)subring withSubringIndex:(NSInteger)subringIndex dataIndex:(NSInteger)dataIndex;

- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView scrollWithRatio:(CGFloat)ratio edgeStatus:(InfinityRingEdgeStatus)edgeStatus;

@end

@protocol MDLInfinityRingViewDataSource <NSObject>

/**
 创建子环视图
 @param infinityRingView 无限环视图
 @param index 子环索引
 @param frame 显示区域
 @return 子环视图
 */
- (UIView *)infinityRingView:(MDLInfinityRingView *)infinityRingView buildSubringAtIndex:(NSInteger)index withFrame:(CGRect)frame;

/**
 更新子环视图
 @param infinityRingView 无限环视图
 @param subring 子环视图
 @param dataIndex 数据索引
 */
- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView updateSubring:(UIView *)subring dataIndex:(NSInteger)dataIndex;

@optional

/**
 使用多少个子环进行展示，如果不实现则使用默认值，默认为3个子环，子环个数必须为奇数，否则会报错
 @param infinityRingView 无限环视图
 @return 子环个数
 */
- (NSInteger)numberOfSubringInInfinityRingView:(MDLInfinityRingView *)infinityRingView;

/**
 将要更新子环视图时调用
 @param infinityRingView 无限环视图
 @param subring 子环视图
 @param dataIndex 数据索引
 */
- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView willUpdateSubring:(UIView *)subring dataIndex:(NSInteger)dataIndex;

/**
 更新完子环视图后调用
 @param infinityRingView 无限环视图
 @param subring 子环视图
 @param dataIndex 数据索引
 */
- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView didUpdateSubring:(UIView *)subring dataIndex:(NSInteger)dataIndex;

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
