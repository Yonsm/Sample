
#import "HTTPServer.h"
#import "MyHTTPResponse.h"

@implementation MyHTTPResponse

//
+ (void)load
{
	[HTTPResponseHandler registerHandler:self];
}

//
+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
				  method:(NSString *)requestMethod
					 url:(NSURL *)requestURL
			headerFields:(NSDictionary *)requestHeaderFields
{
	return YES;
//	if (requestURL.path.length > 1)
//	{
//		NSString *string = [requestURL.path substringFromIndex:1];
//		NSScanner* scan = [NSScanner scannerWithString:string];
//		int val;
//		return [scan scanInt:&val] && [scan isAtEnd];
//	}
//	
//	return NO;
}

//
- (void)startResponse
{
	NSMutableDictionary *dict = (id)NSUrlQueryToDict(url.query);
	NSData *data = [dict.description dataUsingEncoding:NSUTF8StringEncoding];
	
	CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1);
	CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Type", (CFStringRef)@"text/json");
	CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Connection", (CFStringRef)@"close");
	CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Length", (__bridge CFStringRef)[NSString stringWithFormat:@"%d", (int)[data length]]);
	CFDataRef headerData = CFHTTPMessageCopySerializedMessage(response);
	
	@try
	{
		[fileHandle writeData:(__bridge NSData *)headerData];
		[fileHandle writeData:data];
	}
	@catch (NSException *exception)
	{
		// Ignore the exception, it normally just means the client
		// closed the connection from the other end.
	}
	@finally
	{
		CFRelease(headerData);
		[server closeHandler:self];
	}
}

@end
