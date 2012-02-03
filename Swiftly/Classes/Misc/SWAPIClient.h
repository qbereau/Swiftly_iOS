#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

extern NSString * const kSWClientID;
extern NSString * const kSWBaseURLString;

@interface SWAPIClient : AFHTTPClient
+ (SWAPIClient *)sharedClient;
@end
