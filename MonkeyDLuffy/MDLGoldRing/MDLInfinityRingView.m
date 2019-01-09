//
//  MDLInfinityRingView.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/11/13.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLInfinityRingView.h"
#import <objc/runtime.h>

#define DefaultSubringCount 3 //默认子环个数
#define kRatioLimit .999 //触发事件时滑动的比例

//无限环当前的位置信息
typedef struct {
    NSInteger dataIndex;        //最左边页面对应的数据索引
    NSInteger pageIndex;        //当前页面的索引
    InfinityRingEdgeStatus edgeStatus;//边界状态
}InfinityRingLocation;

//根据位置信息获取当前的数据索引
static inline NSInteger RingLocationGetCurrentDateIndex(InfinityRingLocation location) {
    return location.dataIndex + location.pageIndex;
}

//子环滑动后的位置信息
typedef struct {
    NSInteger currentIndex;     //子环当前所处的索引
    NSInteger movement;         //子环滑动页数，右滑大于0，左滑小于0
    NSInteger finalPageIndex;   //滑动后最终的索引
    BOOL isCompensate;          //是否涉及到补偿，向右滑动时页面索引值都减少，左边的子环可能被补偿到右边；向左滑动时页面索引值都增大，右边的子环可能被补偿到左边。
}InfinitySubringLocation;

//数据源实现方法标记
typedef struct {
    BOOL hasUpdateImpl;         //是否实现infinityRingView:updateSubring:withSubringIndex:dataIndex:
    BOOL hasScrollWithRatioImpl;//是否实现infinityRingView:scrollWithRatio:edgeStatus:
    BOOL hasDisplaySubringImpl; //是否实现infinityRingView:displaySubring:withSubringIndex:dataIndex:
    BOOL hasHideSubringImpl;    //是否实现infinityRingView:hideSubring:withSubringIndex:dataIndex:
}_DelegateResponderFlag;

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
 无限环视图内容创建
 */
- (void)_setupInfinityRingView;

/**
 无限环视图大小调整
 @param size 调整后的大小
 */
- (void)_resize:(CGSize)size;

/**
 移动后将要重新进行布局视图
 */
- (void)_willLayoutWithLocation;

/**
 移动后重新布局视图
 @param location 当前的位置信息
 @param pageOffset 页面偏移量，往右滑动是正值，往左滑动是负值
 */
- (void)_layoutWithLocation:(InfinityRingLocation)location
                 pageOffset:(NSInteger)pageOffset;

/**
 移动完成重新布局完成
 */
- (void)_didLayoutWithLocation;

/**
 更新子环视图
 @param subringView 子环视图
 @param subringIndex 子环索引
 @param dataIndex 数据索引
 @param flag 数据源实现方法标记
 */
- (void)_updateSubringView:(UIView *)subringView
          withSubringIndex:(NSInteger)subringIndex
                 dateIndex:(NSInteger)dataIndex
                      flag:(_DelegateResponderFlag)flag;

/**
 显示当前子环视图
 @param subringView 子环视图
 */
- (void)_displaySubringView:(UIView *)subringView;

/**
 计算视图初始化时的位置信息
 @param subringCount 子环个数
 @param initIndex 初始化时显示的数据索引
 @param dataCount 数据总个数
 @return 位置信息
 */
- (InfinityRingLocation)_initLocationWithSubringCount:(NSInteger)subringCount
                                            initIndex:(NSInteger)initIndex
                                            dataCount:(NSInteger)dataCount;

/**
 计算滑动后视图最终的位置信息
 @param pageOffset 页面偏移量
 @param lastLocation 上一次的位置信息
 @param subringCount 子环个数
 @param dataCount 数据总个数
 @return 位置信息
 */
- (InfinityRingLocation)_finalLocationWithPageOffset:(NSInteger)pageOffset
                                        lastLocation:(InfinityRingLocation)lastLocation
                                        subringCount:(NSInteger)subringCount
                                           dataCount:(NSInteger)dataCount;

/**
 计算子环的位置信息，滑动时索引值变动规则：向右滑动时页面索引值都减少，左边的子环可能被补偿到右边；向左滑动时页面索引值都增大，右边的子环可能被补偿到左边。
 @param currentIndex 子环当前的索引
 @param pageOffset 子环的页面偏移量
 @param subringCount 子环个数
 @return 子环的位置信息
 */
- (InfinitySubringLocation)_subringLocationWithIndex:(NSInteger)currentIndex
                                          pageOffset:(NSInteger)pageOffset
                                        subringCount:(NSInteger)subringCount;

/**
 通过最终显示的数据索引计算页面偏移量
 @param dataIndex 数据索引
 @param lastLocation 上一次的位置信息
 @param subringCount 子环个数
 @param dataCount 数据总个数
 @return 页面偏移量
 */
- (NSInteger)_pageOffsetWithFinalDisplayDataIndex:(NSInteger)dataIndex
                                     lastLocation:(InfinityRingLocation)lastLocation
                                     subringCount:(NSInteger)subringCount
                                        dataCount:(NSInteger)dataCount;

@end

@interface MDLInfinityRingView () <UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat offsetRatio;//页面滑动的比例
@property (nonatomic, assign) BOOL viewInvalidate;//页面内容是否失效，滑动停止后如果失效状态为YES，则需要重新刷新界面

@end

@implementation MDLInfinityRingView {
    InfinityRingLocation            _ringLocation;//无限环当前的位置信息
    NSInteger                       _subringCount;//子环个数
    NSInteger                       _dataCount;//数据个数
    NSInteger                       _initDataIndex;//初始化时显示的数据索引
    NSMutableArray                  *_subrings;//子环页面数组
    _DelegateResponderFlag          _responderFlag;//数据源方法实现标记
    UIView                          *_currentSubring;//当前的子环，不一定最终显示，在不停滑动状态_currentSubring始终为最接近显示的子环
    UIView                          *_displaySubring;//当前显示的子环
}

- (instancetype)initWithFrame:(CGRect)frame
                initDataIndex:(NSInteger)initDataIndex
                    dataCount:(NSInteger)dataCount {
    if (self = [super initWithFrame:frame]) {
        _initDataIndex              = initDataIndex;
        _dataCount                  = dataCount;
        
        UIScrollView *scrollView    = [[UIScrollView alloc] initWithFrame:self.bounds];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setPagingEnabled:YES];
        [scrollView setDelegate:self];
        [self addSubview:scrollView];
        _scrollView                 = scrollView;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    BOOL sizeChanged                = !CGRectIsEmpty(self.frame) && !CGSizeEqualToSize(frame.size, self.frame.size);
    [super setFrame:frame];
    if (sizeChanged) {
        [self _resize:frame.size];
    }
}

- (void)setDataSource:(id<MDLInfinityRingViewDataSource>)dataSource {
    if (![dataSource respondsToSelector:@selector(infinityRingView:buildSubringAtIndex:)]) {
        [NSException raise:@"Invalid Parameter" format:@"创建子环视图方法必须实现"];
    }
    _dataSource                     = dataSource;
    if (self.superview) {//切换数据源
        [_subrings makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _displaySubring             = nil;
        _currentSubring             = nil;
        _ringLocation               = (InfinityRingLocation){0, 0, 0};
        [self _setupInfinityRingView];
    }
}

- (void)setDelegate:(id<MDLInfinityRingViewDelegate>)delegate {
    _delegate                       = delegate;
    _DelegateResponderFlag flag     = (_DelegateResponderFlag){NO, NO, NO, NO};
    if ([delegate respondsToSelector:@selector(infinityRingView:updateSubring:withSubringIndex:dataIndex:)]) {
        flag.hasUpdateImpl          = YES;
    }
    if ([delegate respondsToSelector:@selector(infinityRingView:scrollWithRatio:edgeStatus:)]) {
        flag.hasScrollWithRatioImpl = YES;
    }
    if ([delegate respondsToSelector:@selector(infinityRingView:displaySubring:withSubringIndex:dataIndex:)]) {
        flag.hasDisplaySubringImpl  = YES;
    }
    if ([delegate respondsToSelector:@selector(infinityRingView:hideSubring:withSubringIndex:dataIndex:)]) {
        flag.hasHideSubringImpl     = YES;
    }
    _responderFlag = flag;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self _setupInfinityRingView];
    }
}

- (void)scrollToDataIndex:(NSInteger)dataIndex animated:(BOOL)animated {
    if (dataIndex < 0 || dataIndex >= _dataCount) {
        return;
    }
    NSInteger currentDataIndex      = RingLocationGetCurrentDateIndex(_ringLocation);
    if (currentDataIndex == dataIndex) {
        return;
    }
    NSInteger pageOffset            = [self _pageOffsetWithFinalDisplayDataIndex:dataIndex
                                                                    lastLocation:_ringLocation
                                                                    subringCount:_subringCount
                                                                       dataCount:_dataCount];
    if (pageOffset == 0) {
        return;
    }
    
    if (animated) {
        UIScrollView *scrollView    = _scrollView;
        CGPoint contentOffset       = scrollView.contentOffset;
        CGFloat width               = scrollView.frame.size.width;
        [UIView animateWithDuration:0.25
                         animations:^{
                             id<UIScrollViewDelegate> delegate = scrollView.delegate;
                             scrollView.delegate = nil;
                             if (dataIndex > currentDataIndex) {
                                 [scrollView setContentOffset:CGPointMake(contentOffset.x + width, contentOffset.y)];
                             } else if (dataIndex < currentDataIndex) {
                                 [scrollView setContentOffset:CGPointMake(contentOffset.x - width, contentOffset.y)];
                             }
                             scrollView.delegate = delegate;
                         }
                         completion:^(BOOL finished) {
                             [self _willLayoutWithLocation];
                             [self _layoutWithLocation:_ringLocation pageOffset:pageOffset];
                             [self _didLayoutWithLocation];
                         }];
    }
    else {
        [self _willLayoutWithLocation];
        [self _layoutWithLocation:_ringLocation pageOffset:pageOffset];
        [self _didLayoutWithLocation];
    }
}

#pragma mark - 子环视图管理

- (void)_setupInfinityRingView {
    id<MDLInfinityRingViewDataSource> dataSource = self.dataSource;
    NSAssert(dataSource, @"数据源必须存在");
    
    _DelegateResponderFlag flag     = _responderFlag;
    NSInteger subringCount          = [dataSource respondsToSelector:@selector(numberOfSubringInInfinityRingView:)] ? [dataSource numberOfSubringInInfinityRingView:self] : DefaultSubringCount;
    if (subringCount % 2 == 0) {
        [NSException raise:@"Invalid Parameter" format:@"子环个数必须为奇数"];
    }
    
    subringCount                    = MIN(subringCount, _dataCount);
    _subringCount                   = subringCount;
    
    InfinityRingLocation startLocation = [self _initLocationWithSubringCount:subringCount initIndex:_initDataIndex dataCount:_dataCount];
    _ringLocation                   = startLocation;
    
    NSMutableArray *subrings        = [NSMutableArray array];
    CGRect frame                    = _scrollView.bounds;
    UIScrollView *scrollView        = _scrollView;
    scrollView.delegate             = nil;
    scrollView.contentSize          = CGSizeMake(frame.size.width * subringCount, frame.size.height);
    scrollView.contentOffset        = CGPointMake(frame.size.width * startLocation.pageIndex, .0);
    scrollView.delegate             = self;
    
    NSInteger dataIndex = 0;
    for (int i = 0; i < subringCount; i ++) {
        UIView *subringView         = [dataSource infinityRingView:self buildSubringAtIndex:i];
        subringView.frame           = CGRectMake(frame.size.width * i, .0, frame.size.width, frame.size.height);
        
        dataIndex                   = startLocation.dataIndex + i;
        subringView.md_subringIndex = i;
        subringView.md_dataIndex    = dataIndex;
        
        if (startLocation.pageIndex == i) {//判断是或否是当前需要显示的子环
            _displaySubring         = subringView;
            _currentSubring         = subringView;
        }
        
        [self _updateSubringView:subringView withSubringIndex:i dateIndex:dataIndex flag:flag];
        
        [scrollView addSubview:subringView];
        [subrings addObject:subringView];
    }
    _subrings                       = subrings;
    
    [self _displaySubringView:_displaySubring];
}

- (void)_resize:(CGSize)size {
    NSArray *subrings               = _subrings;
    if ([subrings count] == 0) {
        return;
    }
    _scrollView.frame               = self.bounds;
    _scrollView.contentSize         = CGSizeMake(size.width * _subringCount, size.height);
    UIView *subringView = nil;
    
    for (int i = 0; i < _subringCount; i ++) {
        subringView = subrings[i];
        subringView.frame           = CGRectMake(size.width * i, .0, size.width, size.height);
    }
}

- (void)_willLayoutWithLocation {
    if (_responderFlag.hasHideSubringImpl) {//滑动时，开始重新布局时隐藏子环视图方法
        UIView *displaySubring = _displaySubring;
        [self.delegate infinityRingView:self
                            hideSubring:displaySubring
                       withSubringIndex:displaySubring.md_subringIndex
                              dataIndex:displaySubring.md_dataIndex];
    }
    _displaySubring = nil;
}

- (void)_layoutWithLocation:(InfinityRingLocation)location
                 pageOffset:(NSInteger)pageOffset {
    self.viewInvalidate             = YES;//界面失效，需要重新设置当前显示的子环
    NSInteger subringCount          = _subringCount;
    _DelegateResponderFlag flag     = _responderFlag;
    CGRect frame                    = _scrollView.bounds;
    InfinityRingLocation finalLocation = [self _finalLocationWithPageOffset:pageOffset
                                                               lastLocation:location
                                                               subringCount:subringCount
                                                                  dataCount:_dataCount];
    _ringLocation                   = finalLocation;
    NSInteger validDataOffset       = finalLocation.dataIndex - location.dataIndex;//数据位移
    
    if (validDataOffset == 0) {//数据位移为0，边界情况，滑到最左边或者滑到最右边
        _currentSubring = _subrings[finalLocation.pageIndex];
        return;
    }
    
    NSInteger startDataIndex        = finalLocation.dataIndex;
    NSArray *subrings               = _subrings;
    NSMutableArray *adjustedSubrings = [NSMutableArray arrayWithArray:subrings];
    NSMutableArray *compensateSubrings = [NSMutableArray array];//需要补偿更新的子环界面
    
    //调整滑动后各视图的位置
    for (int i = 0; i < subringCount; i ++) {
        UIView *subringView         = [subrings objectAtIndex:i];
        
        InfinitySubringLocation subringLocation = [self _subringLocationWithIndex:i pageOffset:validDataOffset subringCount:subringCount];//移动后子环的位置
        subringView.frame           = CGRectMake(frame.size.width * subringLocation.finalPageIndex, .0, frame.size.width, frame.size.height);
        [adjustedSubrings replaceObjectAtIndex:subringLocation.finalPageIndex withObject:subringView];
        if (subringLocation.finalPageIndex == finalLocation.pageIndex) {//判断是或否是当前的子环
            _currentSubring         = subringView;
        }
        
        if (subringLocation.isCompensate) {//补偿后需要更新子环界面
            subringView.md_dataIndex = startDataIndex + subringLocation.finalPageIndex;//数据索引
            [compensateSubrings addObject:subringView];
        }
    }
    _subrings                       = adjustedSubrings;
    
    _scrollView.delegate            = nil;
    CGFloat compensateOffset = finalLocation.pageIndex == location.pageIndex ? frame.size.width * _offsetRatio : 0;//视图位置调整时补偿的偏移
    _scrollView.contentOffset       = CGPointMake(frame.size.width * finalLocation.pageIndex + compensateOffset, .0);
    _scrollView.delegate            = self;
    
    for (UIView *subringView in compensateSubrings) {//需要更新的子环界面
        [self _updateSubringView:subringView withSubringIndex:subringView.md_subringIndex dateIndex:subringView.md_dataIndex flag:flag];
    }
}

- (void)_didLayoutWithLocation {
    _displaySubring                 = _currentSubring;
    if (_subringCount > 1 && self.viewInvalidate) {
        [self _displaySubringView:_displaySubring];
    }
    self.viewInvalidate             = NO;
}

- (void)_updateSubringView:(UIView *)subringView
          withSubringIndex:(NSInteger)subringIndex
                 dateIndex:(NSInteger)dataIndex
                      flag:(_DelegateResponderFlag)flag {
    if (flag.hasUpdateImpl) {
        [self.delegate infinityRingView:self updateSubring:subringView withSubringIndex:subringIndex dataIndex:dataIndex];
    }
}

- (void)_displaySubringView:(UIView *)subringView {
    if (_responderFlag.hasDisplaySubringImpl) {
        [self.delegate infinityRingView:self
                         displaySubring:subringView
                       withSubringIndex:subringView.md_subringIndex
                              dataIndex:subringView.md_dataIndex];
    }
}

#pragma mark - 无限环整体位置与单个环的位置计算

- (InfinityRingLocation)_initLocationWithSubringCount:(NSInteger)subringCount initIndex:(NSInteger)initIndex dataCount:(NSInteger)dataCount {
    NSInteger dataStartIndex        = initIndex;
    NSInteger pageIndex             = 0;
    InfinityRingEdgeStatus edgeStatus = InfinityRingEdgeNone;
    if (initIndex == 0) { //第一个元素
        edgeStatus                  = InfinityRingEdgeStart;
        dataStartIndex              = 0;
        pageIndex = 0;
    } else if (initIndex == dataCount - 1) { //最后一个元素
        edgeStatus                  = InfinityRingEdgeEnd;
        dataStartIndex              = dataCount - subringCount;
        pageIndex = subringCount - 1;
    } else { //中间的元素，区分3种情况：1，视图右边界显示最后一个数据，2，视图左边界显示第一个数据，3，在中间页面显示，左右没有触碰到数据边界
        NSInteger halfCount          = subringCount / 2;
        if (initIndex + halfCount >= dataCount) {//视图右边界显示最后一个数据
            edgeStatus              = InfinityRingEdgeEnd;
            dataStartIndex          = dataCount - subringCount;
            pageIndex               = initIndex - dataStartIndex;
        } else if (initIndex <= halfCount){//视图左边界显示第一个数据
            edgeStatus              = InfinityRingEdgeStart;
            dataStartIndex          = 0;
            pageIndex               = initIndex;
        } else {//中间页面显示
            dataStartIndex          = initIndex - halfCount;
            pageIndex               = halfCount;
        }
    }
    return (InfinityRingLocation){dataStartIndex, pageIndex, edgeStatus};
}

- (InfinityRingLocation)_finalLocationWithPageOffset:(NSInteger)pageOffset
                                        lastLocation:(InfinityRingLocation)lastLocation
                                        subringCount:(NSInteger)subringCount
                                           dataCount:(NSInteger)dataCount {
    NSInteger half                  = subringCount / 2;
    NSInteger pageIndex             = lastLocation.pageIndex;
    NSInteger dataIndex             = lastLocation.dataIndex;
    InfinityRingEdgeStatus edgeStatus = InfinityRingEdgeNone;
    
    if (pageOffset > 0) { //往右滑动
        for (NSInteger i = 1; i <= pageOffset; i ++) {
            if (dataIndex + subringCount >= dataCount) { //右边已到边界，此时相当于简单的scroll滑动，直接增加页数，不涉及数据更新
                edgeStatus          = InfinityRingEdgeEnd;
                if (pageIndex + 1 > subringCount) {//已经滑动到最右边
                    break;
                }
                pageIndex ++;
            } else if (pageIndex < half) { //从左边界滑到中间视图，直接增加页数，不涉及数据更新
                edgeStatus          = InfinityRingEdgeStart;
                pageIndex ++;
            } else { //需要更新数据索引，但需判断临近右边界的情况
                dataIndex ++;
                edgeStatus          = dataIndex + subringCount == dataCount ? InfinityRingEdgeEnd : InfinityRingEdgeNone;
            }
        }
    } else if (pageOffset < 0) { //往左滑动
        pageOffset                  = -pageOffset;
        for (NSInteger i = 1; i <= pageOffset; i ++) {
            if (dataIndex <= 0) { //左边已到边界，此时相当于简单的scroll滑动，直接减少页数
                edgeStatus          = InfinityRingEdgeStart;
                if (pageIndex - 1 < 0) {//已经滑动到最左边
                    break;
                }
                pageIndex --;
            } else if (pageIndex > half) {//从右边界滑到中间视图，直接减少页数，不涉及数据更新
                edgeStatus          = InfinityRingEdgeEnd;
                pageIndex --;
            } else { //需要更新数据索引，但需判断临近左边界的情况
                dataIndex --;
                edgeStatus          = dataIndex == 0 ? InfinityRingEdgeStart : InfinityRingEdgeNone;
            }
        }
    }
    return (InfinityRingLocation){dataIndex, pageIndex, edgeStatus};
}

- (InfinitySubringLocation)_subringLocationWithIndex:(NSInteger)currentIndex
                                          pageOffset:(NSInteger)pageOffset
                                        subringCount:(NSInteger)subringCount {
    BOOL isCompensate               = NO;
    NSInteger movedPageIndex        = currentIndex - pageOffset;//移动后的索引
    if (movedPageIndex < 0) {//向右滑动，如果移动后的索引值小于0，则进行补偿，将该子环被补偿到无限环的右边，以便能继续向右滑动
        do {
            movedPageIndex          = movedPageIndex + subringCount;
        } while (movedPageIndex < 0);
        isCompensate                = YES;
    } else if (movedPageIndex >= subringCount) {//向左滑动，如果移动后的索引值大于等于子环个数，则进行补偿，将该子环被补偿到无限环的左边，以便能继续向左滑动
        movedPageIndex              = movedPageIndex % subringCount;
        isCompensate                = YES;
    } else {//不涉及到补偿
        movedPageIndex              = movedPageIndex % subringCount;
    }
    return (InfinitySubringLocation) {currentIndex, pageOffset, movedPageIndex, isCompensate};
}

#pragma mark - 页面偏移量计算

- (NSInteger)_pageOffsetWithFinalDisplayDataIndex:(NSInteger)dataIndex
                                     lastLocation:(InfinityRingLocation)lastLocation
                                     subringCount:(NSInteger)subringCount
                                        dataCount:(NSInteger)dataCount{
    if (dataIndex < 0 || dataIndex >= dataCount) {
        return 0;
    }
    NSInteger half                  = subringCount / 2;
    
    //需要刷新数据时的页面偏移量计算方法，为数据移动位移 + 界面滚动位移
    NSInteger(^calculator)(NSInteger, NSInteger, InfinityRingLocation) = ^(NSInteger _dataIndex, NSInteger _half, InfinityRingLocation _location) {
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
        [self didEndScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self didEndScroll];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetX          = scrollView.contentOffset.x;//滚动偏移
    CGFloat width                   = CGRectGetWidth(scrollView.frame);
    CGFloat pageOffset              = contentOffsetX / width;
    InfinityRingLocation location   = _ringLocation;
    CGFloat offsetRatio             = pageOffset - location.pageIndex;
    
    if (offsetRatio >= kRatioLimit) {//往右滑动
        CGFloat temp                = offsetRatio - 1;
        NSInteger movedPage         = 1;
        while (temp >= kRatioLimit) {
            movedPage ++;
            temp                    = offsetRatio - 1;;
        }
        if (movedPage > 0) {//判断是否有移动页面
            _offsetRatio            = temp;
            if (_displaySubring) {
                [self _willLayoutWithLocation];
            }
            [self _layoutWithLocation:location pageOffset:movedPage];//往右滑动是正值
        }
    } else if (offsetRatio <= -kRatioLimit) {//往左滑动
        NSInteger movedPage         = 0;
        NSInteger pageIndex         = location.pageIndex - 1;
        while (contentOffsetX <= pageIndex * width) {
            movedPage ++;
            pageIndex --;
        }
        if (movedPage > 0) {//判断是否有移动页面
            _offsetRatio            = offsetRatio + movedPage;
            if (_displaySubring) {
                [self _willLayoutWithLocation];
            }
            [self _layoutWithLocation:location pageOffset:-movedPage];//往左滑动是负值
        }
    } else if (_responderFlag.hasScrollWithRatioImpl) {
        [self.delegate infinityRingView:self scrollWithRatio:offsetRatio edgeStatus:location.edgeStatus];
    }
}

- (void)didEndScroll {
    [self _didLayoutWithLocation];
}

@end
