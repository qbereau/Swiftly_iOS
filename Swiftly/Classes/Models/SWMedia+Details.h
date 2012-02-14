//
//  SWMedia+Details.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWMedia.h"

@interface SWMedia (Details)

// Core Data Helpers
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllObjects;
+ (void)deleteAllObjects;
+ (SWMedia*)findObjectWithServerID:(int)serverID;
+ (SWMedia*)createEntity; // in context
+ (SWMedia*)newEntity; // no context
- (void)updateWithObject:(id)obj;

@end
