//
//  SWPhoneNumber+Details.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPhoneNumber.h"

@interface SWPhoneNumber (Details)

// Core Data Helpers
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllObjects;
+ (SWPhoneNumber*)findObjectWithPhoneNumber:(NSString*)phoneNb;
+ (SWPhoneNumber*)findValidObjectWithPhoneNumber:(NSString*)phoneNb;
+ (NSArray*)findObjectsWithPersonID:(int)serverID;
+ (void)deleteAllObjects;
+ (SWPhoneNumber*)createEntity; // in context
+ (SWPhoneNumber*)newEntity; // no context
- (void)deleteEntity;


@end
