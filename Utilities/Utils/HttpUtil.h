
#import <Foundation/Foundation.h>

//
typedef enum
{
	DownloadFromLocal,		// Load from local cache only
	DownloadFromOnline,		// Download from online (and cache it)
	DownloadCheckLocal,		// Check local cache: DownloadFromLocal on existing; DownloadFromOnline otherwise.
	DownloadCheckOnline,	// Check online update: DownloadFromOnline on updating; DownloadFromLocal otherwize.
}
DownloadMode;


//
NS_INLINE NSData *DownloadDataWithMode(NSString *url, NSString *to, DownloadMode mode)
{
	if (url == nil) return nil;

	if ((mode == DownloadFromLocal) || ((mode == DownloadCheckLocal) && [NSFileManager.defaultManager fileExistsAtPath:to]))
	{
		return [NSData dataWithContentsOfFile:to];
	}

	//UIUtil::ShowNetworkIndicator(YES);
	NSError *error = nil;
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:((mode == DownloadCheckOnline) ? 0 : NSUncachedRead) error:&error];
	[data writeToFile:to atomically:NO];
	//UIUtil::ShowNetworkIndicator(NO);
	return data;
}

//
// Download data from local or online
NS_INLINE NSData *DownloadData(NSString *url, NSString *to)
{
	return DownloadDataWithMode(url, to, DownloadCheckOnline);
}

// Request HTTP data
NS_INLINE NSData *HttpRequestData(NSString *url, NSData *post, NSURLRequestCachePolicy cachePolicy, NSURLResponse **response, NSError **error, NSString *contentType)
{
	//UIUtil::ShowNetworkIndicator(YES);

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]cachePolicy:cachePolicy timeoutInterval:30];
	if (post)
	{
		request.HTTPMethod = @"POST";
		request.HTTPBody = post;
		if (contentType) [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	}

	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];

	//UIUtil::ShowNetworkIndicator(NO);
	return data;
}

// Request HTTP data
NS_INLINE NSData *HttpPostData(NSString *url, NSData *post)
{
	return HttpRequestData(url, post, NSURLRequestReloadIgnoringCacheData, nil, nil, nil);
}


//
NS_INLINE NSData *HttpUpload(NSString *url, NSArray *multipart, NSURLRequestCachePolicy cachePolicy, NSURLResponse **response, NSError **error)
{
	NSMutableData *post = [NSMutableData data];
	NSString *boundary = @"---FORM-BOUNDARY---";
	for (NSDictionary *part in multipart)
	{
		if (part[@"data"])
		{
			NSMutableString *header = [NSMutableString stringWithFormat:@"--%@\r\n", boundary];
			[header appendString:@"Content-Disposition: form-data"];
			if (part[@"name"]) [header appendFormat:@"; name=\"%@\"", part[@"name"]];
			if (part[@"file"]) [header appendFormat:@"; filename=\"%@\"", part[@"file"]];
			[header appendString:@"\r\n"];
			if (part[@"mine"]) [header appendFormat:@"Content-Type: %@\r\n", part[@"mine"]];
			[header appendString:@"\r\n"];

			[post appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
			[post appendData:part[@"data"]];
			[post appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	NSString *footer = [NSString stringWithFormat:@"--%@--\r\n", boundary];
	[post appendData:[footer dataUsingEncoding:NSUTF8StringEncoding]];

	return HttpRequestData(url, post, cachePolicy, response, error, [@"multipart/form-data; boundary=" stringByAppendingString:boundary]);
}

// Upload HTTP data as multipart
NS_INLINE NSData *HttpUploadData(NSString *url, NSData *data)
{
	return HttpUpload(url, @[@{@"name":@"UPLOAD", @"file":@"UPLOAD", @"mine":@"application/octet-stream", @"data":data}], NSURLRequestReloadIgnoringCacheData, nil, nil);
}

// Upload HTTP Image as multipart
NS_INLINE NSData *HttpUploadImage(NSString *url, UIImage *image)
{
	return HttpUpload(url, @[@{@"name":@"IMAGE", @"file":@"IMAGE.JPG", @"mine":@"image/jpeg", @"data":UIImageJPEGRepresentation(image, 0.75)}], NSURLRequestReloadIgnoringCacheData, nil, nil);
}

// Request HTTP string
NS_INLINE NSString *HttpString(NSString *url, NSString *post)
{
	NSData *send = post ? [NSData dataWithBytes:[post UTF8String] length:[post length]] : nil;
	NSData *recv = HttpPostData(url, send);
	return recv ? [[NSString alloc] initWithData:recv encoding:NSUTF8StringEncoding] : nil;
}

//
NS_INLINE id HttpJSON(NSString *url, NSString *post, NSJSONReadingOptions options)
{
	NSError *error = nil;
	NSURLResponse *response = nil;
	_Log(@"curl %@ -d \"%@\"", url, post);
	NSData *data = HttpRequestData(url, [post dataUsingEncoding:NSUTF8StringEncoding], NSURLRequestReloadIgnoringCacheData, &response, &error, nil);
	if (data)
	{
		id dict = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
		if (dict == nil)
		{
			_Log(@"Data: %@\n\n Error: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], error);
		}
		return dict;
	}
	return nil;
}

// Request HTTP file
// Return error string, or nil on success
NS_INLINE NSString *HttpFile(NSString *url, NSString *path)
{
	UIShowNetworkIndicator(YES);

	NSError *error = nil;
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url] options:NSUncachedRead error:&error];
	if (data != nil)
	{
		[data writeToFile:path atomically:NO];
	}

	UIShowNetworkIndicator(NO);

	return data ? nil : error.localizedDescription;
}
// Request HTTP data
//NSData *HttpData(NSString *url, NSData *post = nil, NSURLRequestCachePolicy cachePolicy = NSURLRequestReloadIgnoringCacheData, NSURLResponse **response = nil, NSError **error = nil, NSString *contentType = nil);

//
//NS_INLINE NSData *HttpData(NSString *url, NSData *post = nil, NSURLRequestCachePolicy cachePolicy = NSURLRequestReloadIgnoringCacheData, NSURLResponse **response = nil, NSError **error = nil, NSString *contentType = nil)
//{
//	return HttpData(url, post, cachePolicy);
//}

// Upload HTTP multipart
//NSData *HttpUpload(NSString *url, NSArray *multipart, NSURLRequestCachePolicy cachePolicy, NSURLResponse **response, NSError **error);

// Request HTTP string
//NSString *HttpString(NSString *url, NSString *post = nil);

// Request HTTP JSON
//id HttpJSON(NSString *url, NSString *post = nil, NSJSONReadingOptions options = 0);

// Request HTTP file
// Return error string, or nil on success
//NSString *HttpFile(NSString *url, NSString *path);
