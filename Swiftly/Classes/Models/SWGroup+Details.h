//
//  SWGroup+Details.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWGroup.h"
#import "SWPerson.h"
#import "SWPerson+Details.h"

@interface SWGroup (Details)

- (NSArray*)contacts_arr;
- (NSString*)contacts_str;
- (void)updateWithObject:(id)obj inContext:(NSManagedObjectContext*)context;
+ (SWGroup*)newEntityInContext:(NSManagedObjectContext*)context;

/*
// Core Data Helpers
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllObjects;
+ (void)deleteAllObjects;
+ (SWGroup*)findObjectWithServerID:(int)serverID;
+ (SWGroup*)createEntity; // in context
- (void)deleteEntity;
*/

@end
