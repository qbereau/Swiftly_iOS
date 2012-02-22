//
//  SWComment+Details.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWComment.h"
#import "SWPerson.h"
#import "SWPerson+Details.h"

@interface SWComment (Details)

// Core Data Helpers
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllObjects;
+ (NSArray*)findLatestCommentsForMediaID:(int)mediaID;
+ (void)deleteAllObjects;
+ (SWComment*)findObjectWithServerID:(int)serverID;
+ (SWComment*)createEntity; // in context
+ (SWComment*)newEntity; // no context
- (void)deleteEntity;
- (void)updateWithObject:(id)obj;

@end
