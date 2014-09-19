
#import "SettingController.h"

@implementation SettingController

#pragma mark Generic methods

// Constructor
- (id)init
{
	self = [super init];
	self.title = NSLocalizedString(@"Settings", @"设置");
	return self;
}

#pragma mark View methods

// Creates the view that the controller manages.
//- (void)loadView
//{
//	[super loadView];
//}

// Do additional setup after loading the view.
//- (void)viewDidLoad
//{
//	[super viewDidLoad];
//}

//
- (void)loadPage
{
	BOOL iPhone5 = UIIsPhone5();
	UIImage *image = [UIImage imageNamed:@"Icon"];
	_logoButton = [UIButton buttonWithImage:image];
	_logoButton.layer.cornerRadius = 8;
	_logoButton.clipsToBounds = YES;
	[_logoButton addTarget:self action:@selector(logoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	_logoButton.center = CGPointMake(1024/2, (iPhone5 ? 20 : 6) + image.size.height / 2);
	[self addView:_logoButton];
	
	UILabel *label = UILabelWithFrame(CGRectMake((1024-300)/2, _contentHeight + 4, 300, iPhone5 ? 40 : 20)
											, [NSString stringWithFormat:NSLocalizedString(@"Version %@ %@© %@", @"版本 %@ %@© %@"), NSBundleVersion(), (iPhone5 ? @"\n" : @" "), NSBundleDisplayName()]
											, [UIFont systemFontOfSize:15]
											, [UIColor darkGrayColor]
											);
	label.textAlignment = NSTextAlignmentCenter;
	[self addView:label];
	if (iPhone5)
	{
		label.numberOfLines = 2;
		[self spaceWithHeight:24];
	}
	else
	{
		[self spaceWithHeight:14];
	}
	
	{
		[self cellButtonWithName:NSLocalizedString(@"Network Cache", @"网络缓存")
						  detail:[NSString stringWithFormat:@"%.2f MB", float(NSCacheSize() / 1024.0 / 1024.0)]
						   title:NSLocalizedString(@"Clean", @"清除")
						  action:@selector(clearButtonClicked:)
						   width:56];
	}
	
	if (DataLoader.isLogon)
	{
		//self.navigationItem.rightBarButtonItem = [UIBarButtonItem _buttonItemWithTitle: target:self action:@selector(logoutButtonClicked:)];
		[self majorButtonWithTitle:NSLocalizedString(@"Logout", @"安全退出") action:@selector(logoutButtonClicked:)];
		
		if (!iPhone5) [self spaceWithHeight:-3];
	}
	
	[self spaceWithHeight:kDefaultHeaderHeight];
	{
		[self cellWithName:NSLocalizedString(@"Rate Me", @"给个好评") detail:nil action:@selector(starButtonClicked:)];
		[self cellWithName:NSLocalizedString(@"About", @"关于") detail:nil action:@selector(logoButtonClicked:)];
	}
	
	if (!iPhone5) [self spaceWithHeight:-10];
}

#pragma mark Event methods

//
#define kCleanCacheAlertViewTag 12517
- (void)clearButtonClicked:(UIButton *)sender
{
	UIAlertView *alertView = UIUtil::ShowAlert(NSLocalizedString(@"Clean Cache", @"清除缓存"),
											   NSLocalizedString(@"Are you sure to clear cache?", @"你确定要清除网络缓存吗？"),
											   self,
											   NSLocalizedString(@"Cancel", @"取消"),
											   NSLocalizedString(@"Clean", @"清除"));
	objc_setAssociatedObject(alertView, (__bridge void *)@"SENDER", sender, OBJC_ASSOCIATION_ASSIGN);
	alertView.tag = kCleanCacheAlertViewTag;
}

//
- (void)starButtonClicked:(WizardCell *)sender
{
	UIUtil::OpenUrl(kAppStoreUrl);
}

//
- (void)logoutButtonClicked:(id)sender
{
	UIUtil::ShowAlert(NSLocalizedString(@"Logout", @"注销"), NSLocalizedString(@"Are you sure to logout?", @"你要退出当前账户吗?"), self, NSLocalizedString(@"Cancel", @"取消"), NSLocalizedString(@"OK", @"确定"));
}

//
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == alertView.cancelButtonIndex) return;
	
	if (alertView.tag == kCleanCacheAlertViewTag)
	{
		NSUtil::CleanCache();
		WizardCell *cell = (WizardCell *)[objc_getAssociatedObject(alertView, (__bridge void *)@"SENDER") superview];
		cell.detail = nil;
		UIButton *button = (UIButton *)cell.accessoryView;
		[button setTitle:NSLocalizedString(@"Cleansed", @"已清除") forState:UIControlStateNormal];
		button.enabled = NO;
		return;
	}
	
	[DataLoader logout];
	[self.navigationController popViewControllerAnimated:YES];
}

//
- (void)logoButtonClicked:(UIView *)sender
{
	UIUtil::ShowStatusBar(NO, UIStatusBarAnimationSlide);
	
	UIImage *image = [UIImage imageNamed:UIUtil::IsPad() ? @"DefaultPad" : (UIUtil::IsPhone5() ? @"Default-568h" : @"Default")];
	UIButton *button = [UIButton buttonWithImage:image];
	[button setImage:image forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(sloganButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	objc_setAssociatedObject(button, (__bridge void *)@"SENDER", sender, OBJC_ASSOCIATION_ASSIGN);
	[self.view.window addSubview:button];
	
	CGRect frame = button.frame;
	button.frame = [self.view.window convertRect:sender.frame fromView:sender.superview];
	button.alpha = 0;
	[UIView animateWithDuration:0.4 animations:^()
	 {
		 button.alpha = 1;
		 button.frame = frame;
	 }];
}

//
- (void)sloganButtonClicked:(UIButton *)sender
{
	UIUtil::ShowStatusBar(YES, UIStatusBarAnimationSlide);
	[UIView animateWithDuration:0.4 animations:^()
	 {
		 sender.alpha = 0;
		 UIView *to = objc_getAssociatedObject(sender, (__bridge void *)@"SENDER");
		 sender.frame = [self.view.window convertRect:to.frame fromView:to.superview];;
	 } completion:^(BOOL finished)
	 {
		 [sender removeFromSuperview];
	 }];
}

@end
