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

// Core Data Helpers
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllObjects;
+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext*)context;

+ (NSArray *)findValidObjects;
+ (NSArray *)findValidObjectsInContext:(NSManagedObjectContext*)context;

+ (void)deleteAllObjects;
+ (void)deleteAllObjectsInContext:(NSManagedObjectContext*)context;

- (void)deleteEntity;
- (void)deleteEntityInContext:(NSManagedObjectContext *)context;

+ (SWPerson*)findObjectWithServerID:(int)serverID;
+ (SWPerson*)findObjectWithServerID:(int)serverID inContext:(NSManagedObjectContext*)context;

+ (SWPerson*)findObjectWithPhoneNumber:(NSString*)phoneNb;
+ (SWPerson*)findObjectWithPhoneNumber:(NSString*)phoneNb inContext:(NSManagedObjectContext*)context;
+ (SWPerson*)findObjectWithPhoneNumber:(NSString*)phoneNb inContext:(NSManagedObjectContext*)context people:(NSArray*)people;

+ (SWPerson*)createEntity;
+ (SWPerson*)createEntityInContext:(NSManagedObjectContext*)context;

+ (SWPerson*)newEntity;
+ (SWPerson*)newEntityInContext:(NSManagedObjectContext*)context;

- (void)updateWithObject:(id)obj;
- (void)updateWithObject:(id)obj inContext:(NSManagedObjectContext*)context;

- (SWPhoneNumber*)normalizedPhoneNumber;
- (SWPhoneNumber*)normalizedPhoneNumberInContext:(NSManagedObjectContext*)context;

+ (NSArray*)getPeopleAB;
+ (NSArray*)getPeopleABInContext:(NSManagedObjectContext*)context;

@end
