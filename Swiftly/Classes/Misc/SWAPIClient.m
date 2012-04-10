#import "SWAPIClient.h"
#import "AFJSONRequestOperation.h"

// DevKey: 80A4F23BBF417BBD6E89341E3C7DE195
// KeyToken: 622673F034A64C220D08A17CF19D10FB

NSString * const kSWBaseURLString = @"http://swiftly.herokuapp.com";

@implementation SWAPIClient

+ (NSDictionary*)userCredentials
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:SWIFTLY_APP_ID accessGroup:nil];
    NSString* key = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString* token = [keychain objectForKey:(__bridge id)kSecValueData];    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isUserActivated = [defaults boolForKey:@"account_activated"];    
    
    return [NSDictionary dictionaryWithObjectsAndKeys:key, @"key", token, @"token", [NSNumber numberWithBool:isUserActivated], @"account_activated", nil];
}

+ (SWAPIClient *)sharedClient
{
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
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    self.parameterEncoding = AFJSONParameterEncoding;
    
    return self;
}

- (NSDictionary*)credentials
{
    NSDictionary* dict              = [SWAPIClient userCredentials];
    NSString* key                   = (NSString*)[dict objectForKey:@"key"];
    NSString* token                 = (NSString*)[dict objectForKey:@"token"];    
    return [NSDictionary dictionaryWithObjectsAndKeys:key, @"key", token, @"token", [NSNumber numberWithInt:50], @"per_page", nil];
}

- (void)getPath:(NSString *)path 
     parameters:(NSDictionary *)parameters 
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [dict addEntriesFromDictionary:[self credentials]];
    [super getPath:path parameters:dict success:success failure:failure];
}

- (void)postPath:(NSString *)path 
      parameters:(NSDictionary *)parameters 
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [dict addEntriesFromDictionary:[self credentials]];
    [super postPath:path parameters:dict success:success failure:failure];
}

- (void)putPath:(NSString *)path 
     parameters:(NSDictionary *)parameters 
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [dict addEntriesFromDictionary:[self credentials]];
    [super putPath:path parameters:dict success:success failure:failure];
}

- (void)deletePath:(NSString *)path 
        parameters:(NSDictionary *)parameters 
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [dict addEntriesFromDictionary:[self credentials]];
    [super deletePath:path parameters:dict success:success failure:failure];
}

@end
