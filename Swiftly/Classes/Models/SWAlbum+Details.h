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

- (SWAlbum*)deepCopyInContext:(NSManagedObjectContext*)context;

- (void)updateWithObject:(id)obj;
- (NSDictionary*)toDictionnary;

+ (NSArray *)findAllLinkableAlbums:(NSManagedObjectContext*)context;
+ (NSArray *)findAllSharedAlbums:(NSManagedObjectContext*)context;
+ (NSArray*)findUnlockedSharedAlbums:(NSManagedObjectContext*)context;
+ (NSArray *)findAllSpecialAlbums:(NSManagedObjectContext*)context;
+ (SWAlbum*)findQuickShareAlbum:(NSManagedObjectContext*)context;
+ (SWAlbum*)newEntityInContext:(NSManagedObjectContext*)context;

// Core Data Helpers
/*
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllObjects;
+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext*)context;

+ (void)deleteAllObjects;

+ (SWAlbum*)findObjectWithServerID:(int)serverID;
+ (SWAlbum*)findObjectWithServerID:(int)serverID inContext:(NSManagedObjectContext*)context;

+ (SWAlbum*)createEntity;
+ (SWAlbum*)createEntityInContext:(NSManagedObjectContext*)context;

- (void)deleteEntity;
- (void)deleteEntityInContext:(NSManagedObjectContext*)context;
 */

@end
