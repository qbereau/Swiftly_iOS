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
+ (NSString*)retrieveContentTypeFromMediaURL:(NSURL*)mediaURL;

- (void)updateWithObject:(id)obj;
+ (NSArray *)findInProgressObjects;
+ (NSArray *)findRecentObjects;
+ (SWMedia*)lastQuickShareMedia;

// Core Data Helpers
/*
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllObjects;

+ (NSArray *)findAllFromCreatorID:(NSInteger)creatorID;

+ (NSArray *)findMediasFromAlbumID:(NSInteger)serverID;
+ (NSArray *)findMediasFromAlbumID:(NSInteger)serverID inContext:(NSManagedObjectContext*)context;

+ (void)deleteAllObjects;

+ (SWMedia*)findObjectWithServerID:(int)serverID inContext:(NSManagedObjectContext*)context;
+ (SWMedia*)findObjectWithServerID:(int)serverID;

+ (SWMedia*)createEntity; // in context
+ (SWMedia*)createEntityInContext:(NSManagedObjectContext*)context; // in context

+ (SWMedia*)newEntity; // no context

- (void)deleteEntity;
- (void)deleteEntityInContext:(NSManagedObjectContext*)context;
*/
@end
