

#import "TableController.h"

@implementation TableController


- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super init];
	_style = style;
	return self;
}

//
- (id)init
{
	self = [super init];
	_style = UIIsOS7() ? UITableViewStyleGrouped : UITableViewStylePlain;
	return self;
}

//
- (void)loadView
{
	[super loadView];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:_style];
	_tableView.showsVerticalScrollIndicator = YES;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.tableFooterView = [[UIView alloc] init];
	[self.view addSubview:_tableView];
	
	_tableView.backgroundColor = UIColor.whiteColor;
	
	if (_style == UITableViewStylePlain)
	{
		_tableView.contentInset = UIEdgeInsetsMake(0, 0, kScrollViewBottomPad, 0);
	}
}

#pragma mark -
#pragma mark Table view methods

//
#if 0 
// NEXT: iOS 6 Plain Style 的标题做成 iOS7 Group 风格？分割线就算了吧
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return ((_style == UITableViewStylePlain) && [self tableView:tableView titleForHeaderInSection:section]) ? 44 : 0;
}

//
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

//
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (_style == UITableViewStylePlain)
	{
		NSString *title = [self tableView:tableView titleForHeaderInSection:section];
		if (title)
		{
			UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
			UIFont *font = [UIFont boldSystemFontOfSize:15];
			UILabel *label = [UILabel labelWithFrame:CGRectMake(14, 22, 300, 16)
												text:title
											   color:UIColorWithRGB(0x4d4d4d)
												font:font
										   alignment:NSTextAlignmentLeft];
			[view addSubview:label];
			
			UIView *line = [[[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 0.5)] autorelease];
			line.backgroundColor = UIColorWithRGB(0xcccccc);
			[view addSubview:line];
			
			view.clipsToBounds = NO;
			return view;
		}
	}
	return nil;
}
#endif

//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *reuse = @"Cell";//[NSString stringWithFormat:@"Cell%d@%d", indexPath.row, indexPath.section];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuse];
		//cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		cell.backgroundColor = UIColor.whiteColor;
	}
	return cell;
}

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end