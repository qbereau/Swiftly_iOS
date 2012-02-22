//
//  SWPerson+Details.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPerson.h"
#import <AddressBook/AddressBook.h>

@interface SWPerson (Details)

- (NSString*)name;
- (NSString*)predicateContactName;
- (UIImage*)contactImage;
- (NSString*)displayOriginalPhoneNumbers;
+ (UIImage*)defaultImage;

// Core Data Helpers
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllObjects;
+ (NSArray *)findValidObjects;
+ (void)deleteAllObjects;
+ (SWPerson*)findObjectWithServerID:(int)serverID;
+ (SWPerson*)findObjectWithOriginalPhoneNumber:(NSString*)phoneNb;
+ (SWPerson*)createEntity; // in context
+ (SWPerson*)newEntity; // no context
- (void)updateWithObject:(id)obj;

+ (NSArray*)getPeopleAB;

@end
