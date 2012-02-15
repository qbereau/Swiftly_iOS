//
//  SWAlbum+Details.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbum.h"
#import "SWAppDelegate.h"
#import "SWPerson+Details.h"

@interface ImageToDataTransformer : NSValueTransformer

@end

@interface SWAlbum (Details)

- (NSArray*)participants_arr;
- (NSString*)participants_str;

// Core Data Helpers
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllObjects;
+ (NSArray *)findAllLinkableAlbums;
+ (NSArray*)findUnlockedSharedAlbums;
+ (NSArray *)findAllSharedAlbums;
+ (NSArray *)findAllSpecialAlbums;
+ (void)deleteAllObjects;
+ (SWAlbum*)findObjectWithServerID:(int)serverID;
+ (SWAlbum*)createEntity; // in context
+ (SWAlbum*)newEntity; // no context
- (void)updateWithObject:(id)obj;
- (NSDictionary*)toDictionnary;
- (void)deleteEntity;

@end
