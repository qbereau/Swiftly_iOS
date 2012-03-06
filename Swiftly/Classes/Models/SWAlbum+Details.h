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
#import "SWMedia.h"
#import "SWMedia+Details.h"

@interface ImageToDataTransformer : NSValueTransformer

@end

@interface SWAlbum (Details)

- (NSArray*)participants_arr;
- (NSString*)participants_str;
- (NSArray*)sortedMedias;

// Core Data Helpers
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllObjects;
+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext*)context;

+ (NSArray *)findAllLinkableAlbums;
+ (NSArray*)findUnlockedSharedAlbums;
+ (NSArray *)findAllSharedAlbums;
+ (NSArray *)findAllSpecialAlbums;

+ (SWAlbum*)findQuickShareAlbum;
+ (SWAlbum*)findQuickShareAlbumInContext:(NSManagedObjectContext*)context;

+ (void)deleteAllObjects;

+ (SWAlbum*)findObjectWithServerID:(int)serverID;
+ (SWAlbum*)findObjectWithServerID:(int)serverID inContext:(NSManagedObjectContext*)context;

+ (SWAlbum*)createEntity;
+ (SWAlbum*)createEntityInContext:(NSManagedObjectContext*)context;

+ (SWAlbum*)newEntity; // no context

- (void)updateWithObject:(id)obj;
- (NSDictionary*)toDictionnary;

- (void)deleteEntity;
- (void)deleteEntityInContext:(NSManagedObjectContext*)context;

@end
