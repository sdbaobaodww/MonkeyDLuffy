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

@optional

/**
 子环隐藏的回调方法
 
 @param infinityRingView 无限环视图
 @param subring 子环视图
 @param subringIndex 子环索引
 @param dataIndex 数据索引
 */
- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView
             hideSubring:(UIView *)subring
        withSubringIndex:(NSInteger)subringIndex
               dataIndex:(NSInteger)dataIndex;

/**
 子环显示的回调方法
 
 @param infinityRingView 无限环视图
 @param subring 子环视图
 @param subringIndex 子环索引
 @param dataIndex 数据索引
 */
- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView
          displaySubring:(UIView *)subring
        withSubringIndex:(NSInteger)subringIndex
               dataIndex:(NSInteger)dataIndex;

/**
 无限环视图滑动的回调
 
 @param infinityRingView 无限环视图
 @param ratio 滑动比例
 @param edgeStatus 边界状态
 */
- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView
         scrollWithRatio:(CGFloat)ratio
              edgeStatus:(InfinityRingEdgeStatus)edgeStatus;

/**
 更新子环视图
 @param infinityRingView 无限环视图
 @param subring 子环视图
 @param subringIndex 子环索引
 @param dataIndex 数据索引
 */
- (void)infinityRingView:(MDLInfinityRingView *)infinityRingView
           updateSubring:(UIView *)subring
        withSubringIndex:(NSInteger)subringIndex
               dataIndex:(NSInteger)dataIndex;

@end

@protocol MDLInfinityRingViewDataSource <NSObject>

/**
 创建子环视图，创建时不用设置frame，frame组件内会自动设置
 @param infinityRingView 无限环视图
 @param index 子环索引
 @return 子环视图
 */
- (UIView *)infinityRingView:(MDLInfinityRingView *)infinityRingView
         buildSubringAtIndex:(NSInteger)index;

@optional

/**
 使用多少个子环进行展示，如果不实现则使用默认值，默认为3个子环，子环个数必须为奇数，否则会报错
 @param infinityRingView 无限环视图
 @return 子环个数
 */
- (NSInteger)numberOfSubringInInfinityRingView:(MDLInfinityRingView *)infinityRingView;

@end

/**
 无限环视图，用于控制处理以有限几个（最少3个）视图滑动展示无限多数据的情况
 */
@interface MDLInfinityRingView : UIView

/**滚动视图*/
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
/**委托*/
@property (nonatomic, weak) id<MDLInfinityRingViewDelegate> delegate;
/**数据源*/
@property (nonatomic, weak) id<MDLInfinityRingViewDataSource> dataSource;

/**
 无限环视图初始化方法
 @param frame 视图显示区域
 @param initDataIndex 进入时的数据的位置
 @param dataCount 数据总个数
 @return 无限环视图
 */
- (instancetype)initWithFrame:(CGRect)frame initDataIndex:(NSInteger)initDataIndex dataCount:(NSInteger)dataCount;

/**
 滑动到指定数据索引处
 @param dataIndex 数据索引
 @param animated 是否动画
 */
- (void)scrollToDataIndex:(NSInteger)dataIndex animated:(BOOL)animated;

@end
