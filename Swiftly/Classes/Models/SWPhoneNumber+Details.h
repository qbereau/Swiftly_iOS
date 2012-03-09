//
//  SWPhoneNumber+Details.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPhoneNumber.h"

@interface SWPhoneNumber (Details)

+ (SWPhoneNumber*)newEntityInContext:(NSManagedObjectContext*)context;

// Core Data Helpers
/*
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllObjects;
+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext*)context;

+ (SWPhoneNumber*)findObjectWithPhoneNumber:(NSString*)phoneNb;
+ (SWPhoneNumber*)findObjectWithPhoneNumber:(NSString*)phoneNb inContext:(NSManagedObjectContext*)context;

+ (SWPhoneNumber*)findValidObjectWithPhoneNumber:(NSString*)phoneNb;
+ (SWPhoneNumber*)findValidObjectWithPhoneNumber:(NSString*)phoneNb inContext:(NSManagedObjectContext*)context;

+ (NSArray*)findObjectsWithPersonID:(int)serverID;
+ (NSArray*)findObjectsWithPersonID:(int)serverID inContext:(NSManagedObjectContext*)context;

+ (void)deleteAllObjects;
+ (void)deleteAllObjectsInContext:(NSManagedObjectContext*)context;

+ (SWPhoneNumber*)createEntity;
+ (SWPhoneNumber*)createEntityInContext:(NSManagedObjectContext*)context;

- (void)deleteEntity;
- (void)deleteEntityInContext:(NSManagedObjectContext*)context;
*/

@end
