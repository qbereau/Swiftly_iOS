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

- (void)updateWithObject:(id)obj;
- (NSDictionary*)toDictionnary;

+ (NSArray *)findAllLinkableAlbums;
+ (NSArray *)findAllSharedAlbums;
+ (NSArray*)findUnlockedSharedAlbums;
+ (NSArray *)findAllSpecialAlbums;
+ (SWAlbum*)findQuickShareAlbum;
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
