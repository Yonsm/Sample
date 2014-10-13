
#import "PredictScrollView.h"


@implementation PredictScrollView

#pragma mark Generic methods

// Constructor
- (id)initWithFrame:(CGRect)frame
{
	_gap = 5;
	frame.origin.x -= _gap;
	frame.size.width += _gap * 2;
	
	self = [super initWithFrame:frame];
	self.pagingEnabled = YES;
	self.delegate = self;
	self.scrollsToTop = NO;
	self.showsHorizontalScrollIndicator = NO;
	
	//self.backgroundColor = [UIColor blackColor];
	
	return self;
}

//
- (void)setGap:(CGFloat)gap
{
	CGRect frame = self.frame;
	frame.origin.x += _gap;
	frame.size.width -= _gap * 2;
	
	frame.origin.x -= gap;
	frame.size.width += gap * 2;
	self.frame = frame;
	_gap = gap;
}

// Remove cached pages
- (void)freePages:(BOOL)force
{
	NSUInteger count = _numberOfPages;
	for (NSUInteger i = 0; i < count; ++i)
	{
		if (![_pages[i] isEqual:NSNull.null])
		{
			if ((i != _currentPage) && (force || ((i != _currentPage - 1) && (i != _currentPage + 1))))
			{
				[_pages[i] removeFromSuperview];
				_pages[i] = NSNull.null;
			}
		}
	}
}

//
- (void)loadPage:(NSUInteger)index
{
	if (index >= _numberOfPages) return;
	if (![_pages[index] isEqual:NSNull.null]) return;
	
	CGRect frame = self.frame;
	frame.origin.y = 0;
	frame.origin.x = frame.size.width * index + _gap;
	frame.size.width -= _gap * 2;

	UIView *page = [_dataSource scrollView:self viewForPage:index inFrame:frame];
	page.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[self addSubview:page];
	_pages[index] = page;
}

//
- (void)loadNearby
{
	[self loadPage:_currentPage - 1];
	[self loadPage:_currentPage + 1];
	_retained_dataSource = nil;
}

//
- (void)loadCurrent
{
	//[self freePages:NO];
	[self loadPage:_currentPage];

	if (!_noPredict)
	{
		_retained_dataSource = _dataSource;
		[self performSelector:@selector(loadNearby) withObject:nil afterDelay:0.2];
	}

	if ([_dataSource respondsToSelector:@selector(scrollView:scrollToPage:)])
	{
		[_dataSource scrollView:self scrollToPage:_currentPage];
	}
}

//
- (void)setCurrentPage:(NSUInteger)currentPage animated:(BOOL)animated
{
	if (currentPage >= _numberOfPages)
	{
		currentPage = 0;
	}
	if (_currentPage != currentPage)
	{
		[self setContentOffset:CGPointMake(self.frame.size.width * currentPage, 0) animated:animated];
	}
	else
	{
		[self loadCurrent];
	}
}

//
- (void)setCurrentPage:(NSUInteger)currentPage
{
	[self setCurrentPage:currentPage animated:NO];
}

//
- (void)setNumberOfPages:(NSUInteger)numberOfPages
{
	if (_numberOfPages)
	{
		while (self.subviews.count)
		{
			UIView* child = self.subviews.lastObject;
			[child removeFromSuperview];
		}
	}

	_numberOfPages = numberOfPages;
	_pages = [NSMutableArray arrayWithCapacity:numberOfPages];
	for (int i  = 0; i < numberOfPages; i++)
	{
		[_pages addObject:NSNull.null];
	}
}


#pragma mark View methods

// Layout subviews.
- (void)layoutSubviews
{
	_bIgnore = YES;
	[super layoutSubviews];
	self.contentSize = CGSizeMake(self.frame.size.width * _numberOfPages, self.frame.size.height);
	_bIgnore = NO;
}

// Set view frame.
- (void)setFrame:(CGRect)frame
{
	_bIgnore = YES;
	[super setFrame:frame];
	self.contentOffset = CGPointMake(frame.size.width * _currentPage, 0);
	_bIgnore = NO;
}


#pragma mark Scroll view methods

//
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (_bIgnore) return;
	
	CGFloat width = scrollView.frame.size.width;
	NSUInteger currentPage = floor((scrollView.contentOffset.x - width / 2) / width) + 1;
	if ((_currentPage != currentPage) && (currentPage < _numberOfPages))
	{
		_currentPage = currentPage;
		[self loadCurrent];
	}
}

@end


//
@implementation PageControlScrollView

//
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	frame.origin.y = frame.size.height - 20;
	frame.size.height = 20;
	_pageCtrl = [[UIPageControl alloc] initWithFrame:frame];
	//_pageCtrl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_pageCtrl.numberOfPages = 0;
	_pageCtrl.currentPage = 0;
	_pageCtrl.hidesForSinglePage = YES;
	[_pageCtrl addTarget:self action:@selector(pageCtrlChanged:) forControlEvents:UIControlEventValueChanged];
	
	return self;
}

//

//
- (void)willMoveToSuperview:(UIView *)newSuperview
{
	if (_hasParent)
	{
		[_pageCtrl removeFromSuperview];
		_hasParent = NO;
	}
}

//
- (void)didMoveToSuperview
{
	if (self.superview)
	{
		_hasParent = YES;
		[self.superview addSubview:_pageCtrl];
	}
}

//
- (void)setNumberOfPages:(NSUInteger)count
{
	[super setNumberOfPages:count];
	_pageCtrl.numberOfPages = count;
}

//
- (void)loadCurrent
{
	_pageCtrl.currentPage = self.currentPage;
	[super loadCurrent];
}

//
- (void)pageCtrlChanged:(UIPageControl *)sender
{
	self.currentPage = _pageCtrl.currentPage;
}

@end

