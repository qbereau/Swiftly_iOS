//
//  SWPerson+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPerson+Details.h"

@implementation SWPerson (Details)

- (NSArray*)sortedSharedMedias
{
    return [[self.sharedMedias allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SWMedia* m1 = (SWMedia*)obj1;
        SWMedia* m2 = (SWMedia*)obj2;
        return m1.serverID < m2.serverID;
    }];
}

- (NSArray*)arrStrPhoneNumbers
{
    NSMutableArray* arr = [NSMutableArray array];
    for (SWPhoneNumber* pn in self.phoneNumbers)
        [arr addObject:pn.phoneNumber];
    return arr;
}

- (NSString*)name
{
    if (self.isSelf)
        return NSLocalizedString(@"me", @"me");
    else if (self.firstName || self.lastName)
        return [NSString stringWithFormat:@"%@ %@", self.firstName ? self.firstName : @"", self.lastName ? self.lastName : @""];
    return NSLocalizedString(@"unknown", @"unknown");
}

- (NSString*)predicateContactName
{
    if (self.lastName.length > 0)
        return self.lastName;
    return [self name];
}

- (UIImage*)contactImage
{
    UIImage* icon;
    if (self.isBlocked)
        icon = [UIImage imageNamed:@"block"];
    else if (self.isUser)
        icon = [UIImage imageNamed:@"valid"];
    else 
        return self.thumbnail;
    
    UIImage* thumb = self.thumbnail;
    
    CGSize size = CGSizeMake(50, 50);
    
    // Reduce contact thumbnail
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [self.thumbnail drawInRect:CGRectMake(0, 0, size.width, size.height)];
    thumb = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();    
    
    
    // Merge two images
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    [thumb drawInRect:CGRectMake(0, 0, thumb.size.width, thumb.size.height)];
    [icon drawInRect:CGRectMake(34, 34, 16, 16) blendMode:kCGBlendModeNormal alpha:1];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage*)defaultImage
{
    return [UIImage imageNamed:@"user@2x.png"];
}

- (void)updateWithObject:(id)obj inContext:(NSManagedObjectContext*)context
{    
    self.serverID       = [[obj valueForKey:@"id"] intValue];
    self.isUser         = [[obj valueForKey:@"activated"] boolValue];
    self.isBlocked      = [[obj valueForKey:@"blocked"] boolValue];
    self.isBlocking     = [[obj valueForKey:@"blocking"] boolValue];
    self.isLinked       = [[obj valueForKey:@"linked"] boolValue];
    
    NSString* origPhone = [obj valueForKey:@"original_phone_number"];
    if (origPhone && [origPhone class] != [NSNull class])
    {
        SWPhoneNumber* pn   = [SWPhoneNumber MR_findFirstByAttribute:@"phoneNumber" withValue:origPhone inContext:context];
        if (!pn || pn.person.serverID != self.serverID)
        {
            SWPhoneNumber* pn   = [SWPhoneNumber MR_createInContext:context];
            pn.phoneNumber      = origPhone;
            pn.normalized       = NO;
            pn.invalid          = NO;
            pn.person           = (SWPerson*)[context objectWithID:self.objectID];
            [self addPhoneNumbersObject:pn];
        }
    }
    
    NSString* phone = [obj valueForKey:@"phone_number"];
    if (phone && [phone class] != [NSNull class])
    {
        SWPhoneNumber* pn = [SWPhoneNumber MR_findFirstByAttribute:@"phoneNumber" withValue:phone inContext:context];
        if (!pn || pn.person.serverID != self.serverID)
        {
            pn              = [SWPhoneNumber MR_createInContext:context];
            pn.phoneNumber  = phone;
            pn.invalid      = NO;
            pn.normalized   = YES;
            pn.person       = (SWPerson*)[context objectWithID:self.objectID];
            
            [self addPhoneNumbersObject:pn];
        }
    }
}

+ (NSArray*)getPeopleABInContext:(NSManagedObjectContext *)context
{
    NSMutableArray* peopleAB = [NSMutableArray array];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        
        SWPerson* p = [SWPerson newEntityInContext:context];
        p.firstName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        p.lastName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++)
        {
            SWPhoneNumber* pn = [SWPhoneNumber newEntityInContext:context];
            pn.phoneNumber  = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers,i);
            pn.normalized   = NO;
            pn.invalid      = NO;
            pn.person       = p;
            [p addPhoneNumbersObject:pn];
        }
        
        if (ABPersonHasImageData(ref))
        {
            NSData *imageData = (__bridge NSData*)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
            p.thumbnail = [UIImage imageWithData:imageData]; 
            
        }
        else
            p.thumbnail = [SWPerson defaultImage];
        
        if (p.firstName || p.lastName)
            [peopleAB addObject:p];
        
        CFRelease(ref);
    }
    
    return peopleAB;
}

static NSArray* __sharedAllValidObjects;

+ (NSArray*)sharedAllValidObjects:(NSManagedObjectContext *)context
{
    if (__sharedAllValidObjects)
        return __sharedAllValidObjects;
    return [SWPerson findAllObjectsInContext:context];
}

+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context
{
    NSMutableArray* output = [NSMutableArray array];
    
    // Find all objects
    NSArray* db_set = [SWPerson MR_findAll];
    
    
    // Find all contacts in AB 
    NSArray* people = [SWPerson getPeopleABInContext:context];
    
    for (SWPerson* p in people)
    {
        // Loop through all persons in AB and check if we can find 
        // one of their originalPhoneNumbers in db_set
        // If we can then we add this reference to the output array (containing server state such as blocked etc.)
        // If we can't then we add AB reference to the output array
        
        BOOL bFoundInDB = NO;
        
        // Warning: Bottleneck!!
        for (SWPhoneNumber* pn in p.phoneNumbers)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY phoneNumbers.phoneNumber == %@", pn.phoneNumber];
            NSArray* rez = [db_set filteredArrayUsingPredicate:predicate];
            if (rez.count > 0)
            {
                [output addObject:(SWPerson*)[rez objectAtIndex:0]];
                bFoundInDB = YES;
                break;
            }
        }
        
        if (!bFoundInDB)
        {
            [output addObject:p];
        }
    }
    
    
    __sharedAllValidObjects = [NSArray arrayWithArray:output];
    
    return output;
}

+ (NSArray *)findValidObjectsInContext:(NSManagedObjectContext *)context
{
    NSArray* output = [SWPerson sharedAllValidObjects:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isUser = YES"];
    return [output filteredArrayUsingPredicate:predicate];
}

+ (SWPerson*)newEntityInContext:(NSManagedObjectContext *)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    SWPerson* obj = [[SWPerson alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    return obj;
}

+ (SWPerson*)findObjectWithPhoneNumber:(NSString*)phoneNb inContext:(NSManagedObjectContext*)context people:(NSArray*)people
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY phoneNumbers.phoneNumber == %@", phoneNb];
    NSArray* items = [people filteredArrayUsingPredicate:predicate];
    if (items.count == 0)
        return nil;
    return (SWPerson*)[items objectAtIndex:0];
}

/*
// Core Data Helpers

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context
{
    return [self respondsToSelector:@selector(entityInManagedObjectContext:)] ?
    [self performSelector:@selector(entityInManagedObjectContext:) withObject:context] :
    [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+ (void)deleteAllObjects
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [SWPerson deleteAllObjectsInContext:context];
}

+ (void)deleteAllObjectsInContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:request error:&error];
    
    
    for (NSManagedObject *managedObject in items) 
    {
        [context deleteObject:managedObject];
    }
    
    [context save:&error];
}

+ (SWPerson*)findObjectWithServerID:(int)serverID
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [SWPerson findObjectWithServerID:serverID inContext:context];
}

+ (SWPerson*)findObjectWithServerID:(int)serverID inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID = %@", [NSNumber numberWithInt:serverID]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray* items = [context executeFetchRequest:request error:nil];
    if ([items count] == 0)
        return nil;
    return (SWPerson*)[items objectAtIndex:0];
}

+ (SWPerson*)findObjectWithPhoneNumber:(NSString*)phoneNb
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [SWPerson findObjectWithPhoneNumber:phoneNb inContext:context];
}

+ (SWPerson*)findObjectWithPhoneNumber:(NSString*)phoneNb inContext:(NSManagedObjectContext*)context
{
    NSArray* people = [SWPerson sharedAllValidObjects:context];
    return [SWPerson findObjectWithPhoneNumber:phoneNb inContext:context people:people];
}

+ (SWPerson*)findObjectWithPhoneNumber:(NSString*)phoneNb inContext:(NSManagedObjectContext*)context people:(NSArray*)people
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY phoneNumbers.phoneNumber == %@", phoneNb];
    NSArray* items = [people filteredArrayUsingPredicate:predicate];
    if (items.count == 0)
        return nil;
    return (SWPerson*)[items objectAtIndex:0];
}

+ (SWPerson*)createEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [SWPerson createEntityInContext:context];
}

+ (SWPerson*)createEntityInContext:(NSManagedObjectContext *)context
{
    SWPerson* obj = [NSEntityDescription
                     insertNewObjectForEntityForName:NSStringFromClass([self class])
                     inManagedObjectContext:context];
    
    return (SWPerson*)obj;
}

+ (SWPerson*)newEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];    
    return [SWPerson newEntityInContext:context];
}

+ (SWPerson*)newEntityInContext:(NSManagedObjectContext *)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    SWPerson* obj = [[SWPerson alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    return obj;
}

- (void)deleteEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [self deleteEntityInContext:context];
}

- (void)deleteEntityInContext:(NSManagedObjectContext *)context
{
    [context deleteObject:self];
}

- (void)updateWithObject:(id)obj
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];    
    [self updateWithObject:obj inContext:context];
}

- (SWPhoneNumber*)normalizedPhoneNumber
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [self normalizedPhoneNumberInContext:context];
}

- (SWPhoneNumber*)normalizedPhoneNumberInContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [SWPerson entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY phoneNumbers.normalized == %@", [NSNumber numberWithBool:YES], self.serverID];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray* items = [context executeFetchRequest:request error:nil];
    if (items.count == 0)
        return nil;
    return (SWPhoneNumber*)[items objectAtIndex:0];
}

+ (NSArray*)getPeopleAB
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [SWPerson getPeopleABInContext:context];
}
*/
@end
