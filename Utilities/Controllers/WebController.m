
#import "UIUtil.h"
#import "WebController.h"

@implementation WebController

#pragma mark Generic methods

// Contructor
- (id)initWithURL:(NSURL *)URL
{
	self = [super init];
	self.URL = URL;
	return self;
}

//
- (id)initWithHTML:(NSString *)HTML
{
	self = [super init];
	self.HTML = HTML;
	return self;
}

// Contructor
- (id)initWithUrl:(NSString *)url
{
	return [self initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

// Destructor
- (void)dealloc
{
	if (_loading) UIShowNetworkIndicator(NO);
}

//
- (UIWebView *)webView
{
	[self view];
	return _webView;
}

//
- (NSString *)url
{
	return self.URL.absoluteString;
}

//
- (void)setUrl:(NSString *)url
{
	self.URL = [NSURL URLWithString:url];
}

//
- (void)setURL:(NSURL *)URL
{
	if (URL != _URL)
	{
		_URL = URL;
	}
	if (URL) [self.webView loadRequest:[NSURLRequest requestWithURL:_URL]];
}

//
- (NSString *)HTML
{
	return [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
}

//
- (void)setHTML:(NSString *)HTML
{
	[self.webView loadHTMLString:HTML baseURL:nil];
}

//
- (void)loadHTML:(NSString *)HTML baseURL:(NSURL *)baseURL
{
	[self.webView loadHTMLString:HTML baseURL:baseURL];
}


#pragma mark View methods

//
- (void)loadView
{
	[super loadView];

	_webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_webView.scalesPageToFit = YES;
	_webView.delegate = self;
	[self.view addSubview:_webView];
}

// Do additional setup after loading the view.
//- (void)viewDidLoad
//{
//	[super viewDidLoad];
//
//	//self.URL = _URL;
//}

// Override to allow rotation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark -
#pragma mark Web view delegate

//
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	_Log(@"shouldStartLoadWithRequest %d: <url:%@>", (int)navigationType, request.URL);
	if ([request.URL.scheme isEqualToString:@"close"])
	{
		if (self.navigationController && ([self.navigationController.viewControllers objectAtIndex:0] != self))
		{
			[self.navigationController popViewControllerAnimated:YES];
		}
		else
		{
			[self dismissViewControllerAnimated:YES completion:nil];
		}
		return NO;
	}
	return YES;
}

//
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	if (_loading++ == 0) UIShowNetworkIndicator(YES);
	self.title = NSLocalizedString(@"Loading...", @"加载中⋯");

	_rightButton = self.navigationItem.rightBarButtonItem;

	UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:indicator];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	[indicator startAnimating];
}

//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if (_loading != 0) _loading--;
	if (_loading == 0) UIShowNetworkIndicator(NO);
	self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	[self.navigationItem setRightBarButtonItem:_rightButton animated:YES];

	_rightButton = nil;
}

//
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self webViewDidFinishLoad:webView];
	if (error.code != -999)
	{
#ifdef _WebViewInlineError
		NSString *string = [NSString stringWithFormat:
							@"<head>"
							@"<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"/>"
							@"<title>%@</title>"
							@"<head>"
							@"<body>%@</body>",
							NSLocalizedString(@"Error", @"错误"),
							error.localizedDescription];

		[((UIWebView *)self.view) loadHTMLString:string baseURL:nil];
#else
		UIAlertViewWithTitleAndMessage(NSLocalizedString(@"Error", @"错误"), error.localizedDescription);
#endif
	}
}

@end
