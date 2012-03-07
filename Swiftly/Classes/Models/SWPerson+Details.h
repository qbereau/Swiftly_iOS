//
//  SWPerson+Details.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPerson.h"
#import "SWPhoneNumber.h"
#import "SWPhoneNumber+Details.h"
#import "SWMedia.h"
#import "SWMedia+Details.h"
#import <AddressBook/AddressBook.h>

@interface SWPerson (Details)

- (NSArray*)sortedSharedMedias;
- (NSArray*)arrStrPhoneNumbers;
- (NSString*)name;
- (NSString*)predicateContactName;
- (UIImage*)contactImage;
+ (UIImage*)defaultImage;

- (void)updateWithObject:(id)obj inContext:(NSManagedObjectContext*)context;
+ (NSArray*)getPeopleABInContext:(NSManagedObjectContext*)context;
+ (NSArray*)sharedAllValidObjects:(NSManagedObjectContext *)context;
+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext*)context;
+ (NSArray *)findValidObjectsInContext:(NSManagedObjectContext*)context;
+ (SWPerson*)newEntityInContext:(NSManagedObjectContext*)context;
+ (SWPerson*)findObjectWithPhoneNumber:(NSString*)phoneNb inContext:(NSManagedObjectContext*)context people:(NSArray*)people;

// Core Data Helpers
/*
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

+ (void)deleteAllObjects;
+ (void)deleteAllObjectsInContext:(NSManagedObjectContext*)context;

- (void)deleteEntity;
- (void)deleteEntityInContext:(NSManagedObjectContext *)context;

+ (SWPerson*)findObjectWithServerID:(int)serverID;
+ (SWPerson*)findObjectWithServerID:(int)serverID inContext:(NSManagedObjectContext*)context;

+ (SWPerson*)createEntity;
+ (SWPerson*)createEntityInContext:(NSManagedObjectContext*)context;

- (void)updateWithObject:(id)obj;

- (SWPhoneNumber*)normalizedPhoneNumber;
- (SWPhoneNumber*)normalizedPhoneNumberInContext:(NSManagedObjectContext*)context;
 */

@end
