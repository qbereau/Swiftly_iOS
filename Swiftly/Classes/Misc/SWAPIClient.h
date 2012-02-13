#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "AFHTTPClient.h"
#import "KeychainItemWrapper.h"

extern NSString * const kSWClientID;
extern NSString * const kSWBaseURLString;

@interface SWAPIClient : AFHTTPClient
+ (NSDictionary*)userCredentials;
+ (SWAPIClient *)sharedClient;
- (NSDictionary*)credentials;
@end
