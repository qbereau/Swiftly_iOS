//
//  SWMedia+Details.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWMedia.h"

@interface SWMedia (Details)

- (UIImage*)thumbnailOrDefaultImage;
- (NSString*)uploadedTime;

// Core Data Helpers
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllObjects;

+ (NSArray *)findInProgressObjects;

+ (NSArray *)findRecentObjects;

+ (NSArray *)findMediasFromAlbumID:(NSInteger)serverID;
+ (NSArray *)findMediasFromAlbumID:(NSInteger)serverID inContext:(NSManagedObjectContext*)context;

+ (void)deleteAllObjects;

+ (SWMedia*)findObjectWithServerID:(int)serverID;

+ (SWMedia*)createEntity; // in context
+ (SWMedia*)createEntityInContext:(NSManagedObjectContext*)context; // in context

+ (SWMedia*)newEntity; // no context

- (void)deleteEntity;
- (void)deleteEntityInContext:(NSManagedObjectContext*)context;

- (void)updateWithObject:(id)obj;

@end
