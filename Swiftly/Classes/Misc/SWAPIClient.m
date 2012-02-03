#import "SWAPIClient.h"

#import "AFJSONRequestOperation.h"

//NSString * const kSWClientID = @"e7ccb7d3d2414eb2af4663fc91eb2793";
NSString * const kSWBaseURLString = @"https://api.swiftlyapp.com/";

@implementation SWAPIClient

+ (SWAPIClient *)sharedClient {
    static SWAPIClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kSWBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
        
    return self;
}

@end
