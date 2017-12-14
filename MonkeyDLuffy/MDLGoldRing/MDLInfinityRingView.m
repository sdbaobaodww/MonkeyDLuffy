//
//  MDLInfinityRingView.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/11/13.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLInfinityRingView.h"
#import <objc/runtime.h>

//无限环当前的位置信息
typedef struct {
    NSInteger dataIndex;        //最左边页面对应的数据索引
    NSInteger pageIndex;        //当前页面的索引
    InfinityRingEdgeStatus edgeStatus;//边界状态
}InfinityRingLocationInfo;

static inline NSInteger RingLocationGetCurrentDateIndex(InfinityRingLocationInfo location) {
    return location.dataIndex + location.pageIndex;
}

//数据源实现方法标记
typedef struct {
    BOOL hasWillUpdateImpl;     //是否实现infinityRingView:willUpdateSubring:dataIndex:
    BOOL hasDidUpdateImpl;      //是否实现infinityRingView:didUpdateSubring:dataIndex:
    BOOL hasNumberOfSubringImpl;//是否实现numberOfSubringInInfinityRingView:
}InfinityRingDataSourceFlag;

//子环滑动后的位置信息
typedef struct {
    NSInteger currentIndex;     //子环当前所处的索引
    NSInteger movement;         //子环滑动页数，右滑大于0，左滑小于0
    NSInteger finalPageIndex;   //滑动后最终的索引
    BOOL isCompensate;          //是否涉及到补偿，向右滑动时页面索引值都减少，左边的子环可能被补偿到右边；向左滑动时页面索引值都增大，右边的子环可能被补偿到左边。
}InfinitySubringLocation;

#define kRatioLimit .999

@interface UIView (InfinityRing)

@property (nonatomic, assign) NSInteger md_dataIndex;//记录数据索引
@property (nonatomic, assign) NSInteger md_subringIndex;//记录子环索引

@end

@implementation UIView (InfinityRing)

- (NSInteger)md_dataIndex {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setMd_dataIndex:(NSInteger)md_dataIndex {
    objc_setAssociatedObject(self, @selector(md_dataIndex), [NSNumber numberWithInteger:md_dataIndex], OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)md_subringIndex {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setMd_subringIndex:(NSInteger)md_subringIndex {
    objc_setAssociatedObject(self, @selector(md_subringIndex), [NSNumber numberWithInteger:md_subringIndex], OBJC_ASSOCIATION_RETAIN);
}

@end

@interface MDLInfinityRingView (Private)

/**
 计算子环的位置信息，滑动时索引值变动规则：向右滑动时页面索引值都减少，左边的子环可能被补偿到右边；向左滑动时页面索引值都增大，右边的子环可能被补偿到左边。
 @param currentIndex 子环当前的索引
 @param pageOffset 子环的页面偏移量
 @param subringCount 子环个数
 @return 子环的位置信息
 */
- (InfinitySubringLocation)_subringLocationWithIndex:(NSInteger)currentIndex pageOffset:(NSInteger)pageOffset subringCount:(NSInteger)subringCount;

/**
 移动后重新布局视图
 @param currentPage 当前页面位置
 @param pageOffset 页面偏移量
 */
- (void)_layoutViewWithCurrentPage:(NSInteger)currentPage pageOffset:(NSInteger)pageOffset;

/**
 更新子环视图
 @param subringView 子环视图
 @param dataIndex 数据索引
 @param flag 数据源实现方法标记
 */
- (void)_updateSubringView:(UIView *)subringView withDateIndex:(NSInteger)dataIndex flag:(InfinityRingDataSourceFlag)flag;

/**
 计算视图初始化时的位置信息
 @param subringCount 子环个数
 @param initIndex 初始化时显示的数据索引
 @param dataCount 数据总个数
 @return 位置信息
 */
- (InfinityRingLocationInfo)_initLocationWithSubringCount:(NSInteger)subringCount initIndex:(NSInteger)initIndex dataCount:(NSInteger)dataCount;

/**
 计算滑动后视图最终的位置信息
 @param pageOffset 页面偏移量
 @param lastLocation 上一次的位置信息
 @param subringCount 子环个数
 @param dataCount 数据总个数
 @return 位置信息
 */
- (InfinityRingLocationInfo)_finalLocationWithPageOffset:(NSInteger)pageOffset lastLocation:(InfinityRingLocationInfo)lastLocation subringCount:(NSInteger)subringCount dataCount:(NSInteger)dataCount;

/**
 无限环视图内容创建
 */
- (void)_setupInfinityRingView;

/**
 通过最终显示的数据索引计算页面偏移量
 @param dataIndex 数据索引
 @param lastLocation 上一次的位置信息
 @param subringCount 子环个数
 @param dataCount 数据总个数
 @return 页面偏移量
 */
- (NSInteger)_pageOffsetWithFinalDisplayDataIndex:(NSInteger)dataIndex lastLocation:(InfinityRingLocationInfo)lastLocation subringCount:(NSInteger)subringCount dataCount:(NSInteger)dataCount;

@end

@interface MDLInfinityRingView () <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentOffsetPage;//当前显示页
@property (nonatomic, assign) CGFloat offsetRatio;//页面滑动的比例
@property (nonatomic, assign) BOOL viewInvalidate;//页面内容是否失效，滑动停止后如果失效状态为YES，则需要重新刷新界面

@end

@implementation MDLInfinityRingView {
    InfinityRingLocationInfo    _ringLocation;//无限环当前的位置信息
    NSInteger                   _subringCount;//子环个数
    NSInteger                   _dataCount;//数据个数
    NSInteger                   _initDataIndex;//初始化时显示的数据索引
    NSMutableArray              *_subrings;//子环页面数组
    InfinityRingDataSourceFlag  _dataSourceFlag;//数据源方法实现标记
    UIView                      *_displaySubring;//当前显示的子环
}

- (instancetype)initWithFrame:(CGRect)frame initIndex:(NSInteger)initIndex dataCount:(NSInteger)dataCount {
    if (self = [super initWithFrame:frame]) {
        _initDataIndex = initIndex;
        _dataCount = dataCount;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setPagingEnabled:YES];
        [scrollView setDelegate:self];
        [self addSubview:scrollView];
        _scrollView = scrollView;
    }
    return self;
}

- (void)setDataSource:(id<MDLInfinityRingViewDataSource>)dataSource {
    _dataSource = dataSource;
    if ([dataSource respondsToSelector:@selector(infinityRingView:willUpdateSubring:dataIndex:)]) {
        _dataSourceFlag.hasWillUpdateImpl = YES;
    }
    if ([dataSource respondsToSelector:@selector(infinityRingView:didUpdateSubring:dataIndex:)]) {
        _dataSourceFlag.hasDidUpdateImpl = YES;
    }
    if ([dataSource respondsToSelector:@selector(numberOfSubringInInfinityRingView:)]) {
        _dataSourceFlag.hasNumberOfSubringImpl = YES;
    }
    [self _setupInfinityRingView];
}

- (void)setCurrentOffsetPage:(NSInteger)currentOffsetPage {
    if (_currentOffsetPage != currentOffsetPage) {
        self.viewInvalidate             = YES;
        [self _layoutViewWithCurrentPage:_currentOffsetPage pageOffset:currentOffsetPage - _currentOffsetPage];//往右滑动是正值，往左滑动是负值
    }
}

- (void)scrollToDataIndex:(NSInteger)dataIndex {
    if (dataIndex < 0 || dataIndex >= _dataCount) {
        return;
    }
    NSInteger currentDataIndex = RingLocationGetCurrentDateIndex(_ringLocation);
    if (currentDataIndex == dataIndex) {
        return;
    }
    NSInteger pageOffset = [self _pageOffsetWithFinalDisplayDataIndex:dataIndex lastLocation:_ringLocation subringCount:_subringCount dataCount:_dataCount];
    if (pageOffset == 0) {
        return;
    }
    CGPoint contentOffset = _scrollView.contentOffset;
    CGFloat width = _scrollView.frame.size.width;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         if (dataIndex > currentDataIndex) {
                             [_scrollView setContentOffset:CGPointMake(contentOffset.x + width, contentOffset.y)];
                         } else if (dataIndex < currentDataIndex) {
                             [_scrollView setContentOffset:CGPointMake(contentOffset.x - width, contentOffset.y)];
                         }
                     }
                     completion:^(BOOL finished) {
                         NSInteger pageOffset = [self _pageOffsetWithFinalDisplayDataIndex:dataIndex lastLocation:_ringLocation subringCount:_subringCount dataCount:_dataCount];
                         if (pageOffset == 0) {
                             return;
                         }
                         [self _layoutViewWithCurrentPage:_currentOffsetPage pageOffset:pageOffset];
                     }];
    
//    self.viewInvalidate = YES;
//    [self _layoutViewWithCurrentPage:_currentOffsetPage pageOffset:pageOffset];
}

#pragma mark - Private

- (InfinitySubringLocation)_subringLocationWithIndex:(NSInteger)currentIndex pageOffset:(NSInteger)pageOffset subringCount:(NSInteger)subringCount {
    BOOL isCompensate = NO;
    NSInteger movedPageIndex = currentIndex - pageOffset;//移动后的索引
    if (movedPageIndex < 0) {//向右滑动，如果移动后的索引值小于0，则进行补偿，将该子环被补偿到无限环的右边，以便能继续向右滑动
        do {
            movedPageIndex = movedPageIndex + subringCount;
        } while (movedPageIndex < 0);
        isCompensate = YES;
    } else if (movedPageIndex >= subringCount) {//向左滑动，如果移动后的索引值大于等于子环个数，则进行补偿，将该子环被补偿到无限环的左边，以便能继续向左滑动
        movedPageIndex = movedPageIndex % subringCount;
        isCompensate = YES;
    } else {//不涉及到补偿
        movedPageIndex = movedPageIndex % subringCount;
    }
    return (InfinitySubringLocation) {currentIndex, pageOffset, movedPageIndex, isCompensate};
}

- (void)_layoutViewWithCurrentPage:(NSInteger)currentPage pageOffset:(NSInteger)pageOffset {
    NSInteger subringCount = _subringCount;
    InfinityRingLocationInfo lastLocation = _ringLocation;
    InfinityRingLocationInfo finalLocation = [self _finalLocationWithPageOffset:pageOffset
                                                                   lastLocation:lastLocation
                                                                   subringCount:subringCount
                                                                      dataCount:_dataCount];
    _ringLocation = finalLocation;
    
    CGRect frame = _scrollView.bounds;
    _currentOffsetPage = finalLocation.pageIndex;
    
    _scrollView.delegate = nil;
    if (finalLocation.edgeStatus == InfinityRingEdgeNone) {
        CGFloat compensateOffset = finalLocation.pageIndex == lastLocation.pageIndex ? frame.size.width * _offsetRatio : 0;//视图位置调整时补偿的偏移
        _scrollView.contentOffset = CGPointMake(frame.size.width * finalLocation.pageIndex + compensateOffset, .0);
    } else {
        _scrollView.contentOffset = CGPointMake(frame.size.width * finalLocation.pageIndex, .0);
    }
    _scrollView.delegate = self;
    
    //数据位移
    NSInteger validDataOffset = finalLocation.dataIndex - lastLocation.dataIndex;
    if (validDataOffset == 0) {
        return;
    }
    
    NSInteger startDataIndex = finalLocation.dataIndex;
    NSArray *subrings = _subrings;
    NSMutableArray *adjustedSubrings = [NSMutableArray arrayWithArray:subrings];
    InfinityRingDataSourceFlag flag = _dataSourceFlag;
    UIView *displaySubring = nil;//当前显示的子环视图
    NSMutableArray *compensateSubrings = [NSMutableArray array];//需要补偿更新的子环界面
    
    //调整滑动后各视图的位置
    for (int i = 0; i < subringCount; i ++) {
        UIView *subringView = [subrings objectAtIndex:i];
        
        InfinitySubringLocation subringLocation = [self _subringLocationWithIndex:i pageOffset:validDataOffset subringCount:subringCount];//移动后子环的位置
        subringView.frame = CGRectMake(frame.size.width * subringLocation.finalPageIndex, .0, frame.size.width, frame.size.height);
        [adjustedSubrings replaceObjectAtIndex:subringLocation.finalPageIndex withObject:subringView];
        if (subringLocation.finalPageIndex == finalLocation.pageIndex) {
            displaySubring = subringView;
        }
        
        if (subringLocation.isCompensate) {//补偿后需要更新子环界面
            subringView.md_dataIndex = startDataIndex + subringLocation.finalPageIndex;//数据索引
            [compensateSubrings addObject:subringView];
        }
    }
    _subrings = adjustedSubrings;
    _displaySubring = displaySubring;
    
    if ([compensateSubrings count] <= 0) {
        return;
    }
    printf("---------------------------------\n");
    //优先更新正在显示的子环
    if (displaySubring) {
        [self _updateSubringView:displaySubring withDateIndex:displaySubring.md_dataIndex flag:flag];
    }
    for (UIView *subringView in compensateSubrings) {//需要更新的子环界面
        if (subringView != displaySubring) {
            [self _updateSubringView:subringView withDateIndex:subringView.md_dataIndex flag:flag];
        }
    }
}

- (void)_updateSubringView:(UIView *)subringView withDateIndex:(NSInteger)dataIndex flag:(InfinityRingDataSourceFlag)flag {
    if (flag.hasWillUpdateImpl) {
        [self.dataSource infinityRingView:self willUpdateSubring:subringView dataIndex:dataIndex];
    }
    [self.dataSource infinityRingView:self updateSubring:subringView dataIndex:dataIndex];
    if (flag.hasDidUpdateImpl) {
        [self.dataSource infinityRingView:self didUpdateSubring:subringView dataIndex:dataIndex];
    }
    printf("更新子环数据:%ld \n", dataIndex);
}

- (InfinityRingLocationInfo)_initLocationWithSubringCount:(NSInteger)subringCount initIndex:(NSInteger)initIndex dataCount:(NSInteger)dataCount {
    NSInteger dataStartIndex = initIndex;
    NSInteger pageIndex = 0;
    InfinityRingEdgeStatus edgeStatus = InfinityRingEdgeNone;
    if (initIndex == 0) { //第一个元素
        edgeStatus = InfinityRingEdgeStart;
        dataStartIndex = 0;
        pageIndex = 0;
    } else if (initIndex == dataCount - 1) { //最后一个元素
        edgeStatus = InfinityRingEdgeEnd;
        dataStartIndex = dataCount - subringCount;
        pageIndex = subringCount - 1;
    } else { //中间的元素，区分3种情况：1，视图右边界显示最后一个数据，2，视图左边界显示第一个数据，3，在中间页面显示，左右没有触碰到数据边界
        NSInteger halfCount = subringCount / 2;
        if (initIndex + halfCount >= dataCount) {//视图右边界显示最后一个数据
            edgeStatus = InfinityRingEdgeEnd;
            dataStartIndex = dataCount - subringCount;
            pageIndex = initIndex - dataStartIndex;
        } else if (initIndex <= halfCount){//视图左边界显示第一个数据
            edgeStatus = InfinityRingEdgeStart;
            dataStartIndex = 0;
            pageIndex = initIndex;
        } else {//中间页面显示
            dataStartIndex = initIndex - halfCount;
            pageIndex = halfCount;
        }
    }
    return (InfinityRingLocationInfo){dataStartIndex, pageIndex, edgeStatus};
}

- (InfinityRingLocationInfo)_finalLocationWithPageOffset:(NSInteger)pageOffset lastLocation:(InfinityRingLocationInfo)lastLocation subringCount:(NSInteger)subringCount dataCount:(NSInteger)dataCount {
    NSInteger half = subringCount / 2;
    NSInteger pageIndex = lastLocation.pageIndex;
    NSInteger dataIndex = lastLocation.dataIndex;
    InfinityRingEdgeStatus edgeStatus = InfinityRingEdgeNone;
    
    if (pageOffset > 0) { //往右滑动
        for (NSInteger i = 1; i <= pageOffset; i ++) {
            if (dataIndex + subringCount >= dataCount) { //右边已到边界，此时相当于简单的scroll滑动，直接增加页数，不涉及数据更新
                edgeStatus = InfinityRingEdgeEnd;
                if (pageIndex + 1 > subringCount) {//已经滑动到最右边
                    break;
                }
                pageIndex ++;
            } else if (pageIndex < half) { //从左边界滑到中间视图，直接增加页数，不涉及数据更新
                edgeStatus = InfinityRingEdgeStart;
                pageIndex ++;
            } else { //一直显示中间视图，需要更新数据
                edgeStatus = InfinityRingEdgeNone;
                dataIndex ++;
            }
        }
    } else if (pageOffset < 0) { //往左滑动
        pageOffset = -pageOffset;
        for (NSInteger i = 1; i <= pageOffset; i ++) {
            if (dataIndex <= 0) { //左边已到边界，此时相当于简单的scroll滑动，直接减少页数
                edgeStatus = InfinityRingEdgeStart;
                if (pageIndex - 1 < 0) {//已经滑动到最左边
                    break;
                }
                pageIndex --;
            } else if (pageIndex > half) {//从右边界滑到中间视图，直接增加页数，不涉及数据更新
                edgeStatus = InfinityRingEdgeEnd;
                pageIndex --;
            } else { //一直显示中间视图，需要更新数据
                edgeStatus = InfinityRingEdgeNone;
                dataIndex --;
            }
        }
    }
    return (InfinityRingLocationInfo){dataIndex, pageIndex, edgeStatus};
}

- (void)_setupInfinityRingView {
    id<MDLInfinityRingViewDataSource> dataSource = self.dataSource;
    if (![dataSource respondsToSelector:@selector(infinityRingView:buildSubringAtIndex:withFrame:)]) {
        return;
    }
    InfinityRingDataSourceFlag flag = _dataSourceFlag;
    NSInteger subringCount = flag.hasNumberOfSubringImpl ? [dataSource numberOfSubringInInfinityRingView:self] : 3;
    if (subringCount % 2 == 0) {
        [NSException raise:@"InvalidParameter" format:@"子环个数必须为奇数"];
    }
    
    subringCount = MIN(subringCount, _dataCount);
    _subringCount = subringCount;
    
    InfinityRingLocationInfo startLocation = [self _initLocationWithSubringCount:subringCount initIndex:_initDataIndex dataCount:_dataCount];
    _currentOffsetPage = startLocation.pageIndex;
    _ringLocation = startLocation;
    
    NSMutableArray *subrings = [NSMutableArray array];
    CGRect frame = _scrollView.bounds;
    UIScrollView *scrollView = _scrollView;
    scrollView.delegate = nil;
    scrollView.contentSize = CGSizeMake(frame.size.width * subringCount, frame.size.height);
    scrollView.contentOffset = CGPointMake(frame.size.width * startLocation.pageIndex, .0);
    scrollView.delegate = self;
    
    NSInteger dataIndex = 0;
    for (int i = 0; i < subringCount; i ++) {
        UIView *subringView = [dataSource infinityRingView:self buildSubringAtIndex:i withFrame:CGRectMake(frame.size.width * i, .0, frame.size.width, frame.size.height)];
        subringView.md_subringIndex = i;
        dataIndex = startLocation.dataIndex + i;
        
        [self _updateSubringView:subringView withDateIndex:dataIndex flag:flag];
        
        [scrollView addSubview:subringView];
        [subrings addObject:subringView];
    }
    _subrings = subrings;
}

- (NSInteger)_pageOffsetWithFinalDisplayDataIndex:(NSInteger)dataIndex lastLocation:(InfinityRingLocationInfo)lastLocation subringCount:(NSInteger)subringCount dataCount:(NSInteger)dataCount{
    if (dataIndex < 0 || dataIndex >= dataCount) {
        return 0;
    }
    
    NSInteger half = subringCount / 2;
    
    //需要刷新数据时的页面偏移量计算方法，为数据移动位移 + 界面滚动位移
    NSInteger(^calculator)(NSInteger, NSInteger, InfinityRingLocationInfo) = ^(NSInteger _dataIndex, NSInteger _half, InfinityRingLocationInfo _location) {
        return (_dataIndex - _half - _location.dataIndex) + (_half - _location.pageIndex);
    };
    
    if (lastLocation.edgeStatus == InfinityRingEdgeStart) {//处于左边界
        if (dataIndex <= half) {//不需要刷新数据，，仅进行滚动
            return dataIndex - lastLocation.pageIndex;
        } else {//需要刷新数据的情况
            return calculator(dataIndex, half, lastLocation);
        }
    } else if (lastLocation.edgeStatus == InfinityRingEdgeEnd) {//处于右边界
        if (dataIndex >= lastLocation.dataIndex) {//不需要刷新数据，仅进行滚动
            return dataIndex - lastLocation.dataIndex - lastLocation.pageIndex;
        } else {//需要刷新数据的情况
            return calculator(dataIndex, half, lastLocation);
        }
    } else {//需要刷新数据的情况
        return calculator(dataIndex, half, lastLocation);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self endScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self endScroll:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetX          = scrollView.contentOffset.x;//滚动偏移
    CGFloat width                   = CGRectGetWidth(scrollView.frame);
    CGFloat pageOffset              = contentOffsetX / width;
    CGFloat offsetRatio             = pageOffset - _ringLocation.pageIndex;
    if (offsetRatio >= kRatioLimit) {
        CGFloat temp                = offsetRatio - 1;
        NSInteger movedPage = 1;
        while (temp >= kRatioLimit) {
            movedPage ++;
            temp                    = offsetRatio - 1;;
        }
        if (movedPage > 0) {//判断是否有移动页面
            _offsetRatio            = temp;
            self.currentOffsetPage  += movedPage;
        }
    } else if (offsetRatio <= - kRatioLimit) {
        NSInteger movedPage = 0;
        NSInteger pageIndex = _currentOffsetPage - 1;
        while (contentOffsetX <= pageIndex * width) {
            movedPage ++;
            pageIndex --;
        }
        if (movedPage > 0) {//判断是否有移动页面
            _offsetRatio            = offsetRatio + movedPage;
            self.currentOffsetPage  -= movedPage;
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(infinityRingView:scrollWithRatio:edgeStatus:)]) {
            [self.delegate infinityRingView:self scrollWithRatio:offsetRatio edgeStatus:_ringLocation.edgeStatus];
        }
    }
}

- (void)endScroll:(UIScrollView *)scrollView {
    if (_subringCount > 1 && self.viewInvalidate) {
        if ([self.delegate respondsToSelector:@selector(infinityRingView:displaySubring:withSubringIndex:dataIndex:)]) {
            [self.delegate infinityRingView:self displaySubring:_displaySubring withSubringIndex:_displaySubring.md_subringIndex dataIndex:_displaySubring.md_dataIndex];
        }
    }
    self.viewInvalidate             = NO;
}

@end
