
//
@class PredictScrollView;
@protocol PredictScrollViewDataSource <NSObject>
@required
- (UIView *)scrollView:(PredictScrollView *)scrollView viewForPage:(NSUInteger)index inFrame:(CGRect)frame;
@optional
- (void)scrollView:(PredictScrollView *)scrollView scrollToPage:(NSUInteger)index;
@end


//
@interface PredictScrollView : UIScrollView <UIScrollViewDelegate>
{
	BOOL _bIgnore;
	id _retained_dataSource;
}

@property(nonatomic,assign) CGFloat gap;
@property(nonatomic,assign) BOOL noPredict;

@property(nonatomic,readonly) NSMutableArray *pages;
@property(nonatomic,assign) NSUInteger currentPage;
@property(nonatomic,assign) NSUInteger numberOfPages;
@property(nonatomic,weak) id<PredictScrollViewDataSource> dataSource;

- (void)setCurrentPage:(NSUInteger)currentPage animated:(BOOL)animated;

- (void)freePages:(BOOL)force;

@end


//
@interface PageControlScrollView : PredictScrollView
{
	BOOL _hasParent;
	UIPageControl *_pageCtrl;
}
@property(nonatomic,readonly) UIPageControl *pageCtrl;
@end
