
#import "NSUtil.h"
#import "UIUtil.h"
#import "HttpUtil.h"

#ifdef TEST
@implementation NSURLRequest (IgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
	return YES;
}
@end
#endif
