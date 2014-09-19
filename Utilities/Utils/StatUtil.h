
#ifdef kAppStatKey
#import "MobClick.h"
#endif

//
NS_INLINE void StatStartWithChannel(NSString *channeId)
{
#ifdef kAppStatKey
	[MobClick startWithAppkey:kAppStatKey reportPolicy:BATCH channelId:channeId];
#endif
}

//
NS_INLINE void StatStart()
{
#ifdef kAppStatKey
	[MobClick startWithAppkey:kAppStatKey];
#endif
}

//
NS_INLINE void StatEvent(NSString *event)
{
#ifdef kAppStatKey
	[MobClick event:event];
#endif
}

//
NS_INLINE void StatEventWithAttributes(NSString *event, NSDictionary *attrs)
{
#ifdef kAppStatKey
	if (attrs) [MobClick event:event attributes:attrs];
	else [MobClick event:event];
#endif
}

//
NS_INLINE void StatEvent1(NSString *event, NSString *attr)
{
#ifdef kAppStatKey
	StatEventWithAttributes(event, @{@"u": attr});
#endif
}

//
NS_INLINE void StatEvent2(NSString *event, NSString *attr1, NSString *attr2)
{
#ifdef kAppStatKey
	StatEventWithAttributes(event, @{@"u": attr1, @"a", attr2});
#endif
}

//
NS_INLINE void StatPageBegin(NSString *page)
{
#ifdef kAppStatKey
	[MobClick beginLogPageView:page];
#endif
	_Log(@"Enter Page: %@", page);
}

//
NS_INLINE void StatPageEnded(NSString *page)
{
	_Log(@"Leave Page: %@", page);
#ifdef kAppStatKey
	[MobClick endLogPageView:page];
#endif
}
