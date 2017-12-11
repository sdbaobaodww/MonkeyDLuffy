//
//  MDLInfinityRingView.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/11/13.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLInfinityRingView.h"
#import <objc/runtime.h>

//无限环边界状态
typedef NS_ENUM(NSInteger, InfinityRingEdgeStatus) {
    InfinityRingEdgeStart,     //触碰到左边界
    InfinityRingEdgeEnd,       //触碰到右边界
    InfinityRingEdgeNone,      //中间滑动变换视图位置，没触碰到任何边界
};

//无限环当前的位置信息
typedef struct {
    NSInteger dataIndex;//最左边页面对应的数据索引
    NSInteger pageIndex;//当前页面的索引
    InfinityRingEdgeStatus edgeStatus;//边界状态
}InfinityRingLocationInfo;

//数据源实现方法标记
typedef struct {
    BOOL hasWillUpdateImpl;
    BOOL hasDidUpdateImpl;
    BOOL hasNumberOfSubringImpl;
}InfinityRingDataSourceFlag;

#define kRatioLimit .999

@interface UIView (MarkDataIndex)

@property (nonatomic, assign) NSInteger md_dataIndex;

@property (nonatomic, assign) BOOL md_needUpdate;

@end

@implementation UIView (MarkDataIndex)

- (NSInteger)md_dataIndex {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setMd_dataIndex:(NSInteger)md_dataIndex {
    objc_setAssociatedObject(self, @selector(md_dataIndex), [NSNumber numberWithInteger:md_dataIndex], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)md_needUpdate {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setMd_needUpdate:(BOOL)md_needUpdate {
    objc_setAssociatedObject(self, @selector(md_needUpdate), [NSNumber numberWithBool:md_needUpdate], OBJC_ASSOCIATION_RETAIN);
}

@end

@interface MDLInfinityRingView (Private)

/**
 计算最终的子环索引
 @param pageIndex 子环偏移后的页面索引值
 @param subringCount 子环个数
 @return 最终的子环索引
 */
- (NSInteger)_realIndex:(NSInteger)pageIndex subringCount:(NSInteger)subringCount;

/**
 移动后重新布局视图
 @param currentPage 当前页面位置
 @param pageOffset 移动的页数
 */
- (void)_layoutViewWithCurrentPage:(NSInteger)currentPage pageOffset:(NSInteger)pageOffset;

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
 @param pageOffset 滑动页数
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

@end

@interface MDLInfinityRingView () <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentOffsetPage;//当前显示页
@property (nonatomic, assign) CGFloat offsetRatio;//页面滑动的比例
@property (nonatomic, assign) BOOL viewInvalidate;//页面内容是否失效，滑动停止后如果失效状态为YES，则需要重新刷新界面

@end

@implementation MDLInfinityRingView {
    InfinityRingLocationInfo    _ringLocation;
    NSInteger                   _subringCount;
    NSInteger                   _dataCount;
    NSInteger                   _initDataIndex;
    NSInteger                   _startIndex;
    NSMutableArray              *_subrings;
    InfinityRingDataSourceFlag  _dataSourceFlag;
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
        
        [self _setupInfinityRingView];
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

#pragma mark - Private

- (NSInteger)_realIndex:(NSInteger)pageIndex subringCount:(NSInteger)subringCount {
    if (pageIndex < 0) {
        pageIndex = pageIndex + subringCount;
        while (pageIndex < 0) {
            pageIndex = pageIndex + subringCount;
        }
        return pageIndex;
    } else {
        return pageIndex % subringCount;
    }
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
    
    if (finalLocation.edgeStatus == InfinityRingEdgeNone) {
        _scrollView.delegate = nil;
        CGFloat compensateOffset = finalLocation.pageIndex == lastLocation.pageIndex ? frame.size.width * _offsetRatio : 0;//视图位置调整时补偿的偏移
        _scrollView.contentOffset = CGPointMake(frame.size.width * finalLocation.pageIndex + compensateOffset, .0);
        _scrollView.delegate = self;
    }
    
    //数据位移
    NSInteger validDataOffset = finalLocation.dataIndex - lastLocation.dataIndex;
    if (validDataOffset == 0) {
        return;
    }
    NSLog(@"数据位移:%ld", validDataOffset);
    
    id<MDLInfinityRingViewDataSource> dataSource = self.dataSource;
    NSInteger startDataIndex = finalLocation.dataIndex;
    NSArray *subrings = _subrings;
    NSMutableArray *adjustedSubrings = [NSMutableArray arrayWithArray:subrings];
    //调整滑动后各视图的位置
    for (int i = 0; i < subringCount; i ++) {
        UIView *itemView = [subrings objectAtIndex:i];
        NSInteger finalIndex = [self _realIndex:i - validDataOffset subringCount:subringCount];//滑动后该视图最终落在的索引
        itemView.frame = CGRectMake(frame.size.width * finalIndex, .0, frame.size.width, frame.size.height);//调整后的视图位置
        [adjustedSubrings replaceObjectAtIndex:finalIndex withObject:itemView];
        
        //判断页面是否需要重新刷新数据，如往右滑动时，左边的视图项滑出到右边进行补偿；往左滑动时，右边的视图项滑出到左边进行补偿。这两种情况需要对视图项进行更新
        itemView.md_needUpdate = (pageOffset > 0 && i - validDataOffset < 0) || (pageOffset < 0 && i - validDataOffset >= subringCount);
    }
    _subrings = adjustedSubrings;
    
    InfinityRingDataSourceFlag flag = _dataSourceFlag;
    //对需要变更的子环调用数据源进行更新
    [adjustedSubrings enumerateObjectsUsingBlock:^(UIView *itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (itemView.md_needUpdate) {
            NSInteger dataIndex = startDataIndex + idx;
            
            if (flag.hasWillUpdateImpl) {
                [dataSource infinityRingView:self willUpdateSubring:itemView dataIndex:dataIndex];
            }
            [dataSource infinityRingView:self updateSubring:itemView dataIndex:dataIndex];
            if (flag.hasDidUpdateImpl) {
                [dataSource infinityRingView:self didUpdateSubring:itemView dataIndex:dataIndex];
            }
        }
    }];
}

- (InfinityRingLocationInfo)_initLocationWithSubringCount:(NSInteger)subringCount initIndex:(NSInteger)initIndex dataCount:(NSInteger)dataCount {
    NSInteger dataStartIndex = initIndex;
    NSInteger pageIndex = 0;
    InfinityRingEdgeStatus edgeStatus = InfinityRingEdgeNone;
    if (initIndex == 0) { //第一个元素
        edgeStatus = InfinityRingEdgeStart;
        dataStartIndex = initIndex;
        pageIndex = 0;
    } else if (initIndex == dataCount - 1) { //最后一个元素
        edgeStatus = InfinityRingEdgeEnd;
        dataStartIndex = initIndex + 1 - subringCount;
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
            if (lastLocation.dataIndex + i + subringCount > dataCount) { //右边已到边界，此时相当于简单的scroll滑动，直接增加页数，不涉及数据更新
                edgeStatus = InfinityRingEdgeEnd;
                if (pageIndex + 1 > subringCount) {//已经滑动到最右边
                    break;
                }
                pageIndex ++;
            } else if (pageIndex < half) { //从左边界滑到中间视图，直接增加页数，不涉及数据更新
                edgeStatus = InfinityRingEdgeStart;
                pageIndex ++;
            } else { //一直显示中间视图，需要更新数据
                dataIndex ++;
            }
        }
    } else if (pageOffset < 0) { //往左滑动
        pageOffset = -pageOffset;
        for (NSInteger i = 1; i <= pageOffset; i ++) {
            if (lastLocation.dataIndex - i < 0) { //左边已到边界，此时相当于简单的scroll滑动，直接减少页数
                edgeStatus = InfinityRingEdgeStart;
                if (pageIndex - 1 < 0) {//已经滑动到最左边
                    break;
                }
                pageIndex --;
            } else if (pageIndex > half) {//从右边界滑到中间视图，直接增加页数，不涉及数据更新
                edgeStatus = InfinityRingEdgeEnd;
                pageIndex --;
            } else { //一直显示中间视图，需要更新数据
                dataIndex --;
            }
        }
    }
    return (InfinityRingLocationInfo){dataIndex, pageIndex, edgeStatus};
}

- (void)_setupInfinityRingView {
    id<MDLInfinityRingViewDataSource> dataSource = self.dataSource;
    if (![dataSource respondsToSelector:@selector(infinityRingView:initSubringAtIndex:withFrame:)]) {
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
        UIView *itemView = [dataSource infinityRingView:self initSubringAtIndex:i withFrame:CGRectMake(frame.size.width * i, .0, frame.size.width, frame.size.height)];
        itemView.tag = i;
        dataIndex = startLocation.dataIndex + i;
        itemView.md_dataIndex = dataIndex;
        
        if (flag.hasWillUpdateImpl) {
            [dataSource infinityRingView:self willUpdateSubring:itemView dataIndex:dataIndex];
        }
        [dataSource infinityRingView:self updateSubring:itemView dataIndex:dataIndex];
        if (flag.hasDidUpdateImpl) {
            [dataSource infinityRingView:self didUpdateSubring:itemView dataIndex:dataIndex];
        }
        
        [scrollView addSubview:itemView];
        [subrings addObject:itemView];
    }
    _subrings = subrings;
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
        if (movedPage > 0) {
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
        if (movedPage > 0) {
            _offsetRatio            = offsetRatio + movedPage;
            self.currentOffsetPage  -= movedPage;
        }
    }
    else {
        
    }
}

- (void)endScroll:(UIScrollView *)scrollView {
    if (_subringCount > 1 && self.viewInvalidate) {
        
    }
    self.viewInvalidate             = NO;
}

@end
