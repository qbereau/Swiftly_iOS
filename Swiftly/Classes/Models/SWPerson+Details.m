//
//  SWPerson+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPerson+Details.h"

@implementation SWPerson (Details)

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

- (NSString*)displayOriginalPhoneNumbers
{
    /*
    NSMutableString* str = [NSMutableString string];
    for (NSString* phone_nb in self.originalPhoneNumbers)
    {
        [str appendFormat:@"%@, ", phone_nb];
    }
    
    if ([self.originalPhoneNumbers count] > 0)
        return [str substringToIndex:[str length] - 2];    
    
    return str;
     */
    return @"TODO";
}

+ (UIImage*)defaultImage
{
    return [UIImage imageNamed:@"user@2x.png"];
}

// Core Data Helpers

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context
{
    return [self respondsToSelector:@selector(entityInManagedObjectContext:)] ?
    [self performSelector:@selector(entityInManagedObjectContext:) withObject:context] :
    [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+ (NSArray *)findAllObjects
{
    NSMutableArray* output = [NSMutableArray array];
    
    // Find all objects
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSArray* db_set = [context executeFetchRequest:request error:nil];
    
    
    // Find all contacts in AB 
    NSArray* people = [SWPerson getPeopleAB];

    for (SWPerson* p in people)
    {
        // Loop through all persons in AB and check if we can find 
        // one of their originalPhoneNumbers in db_set
        // If we can then we add this reference to the output array (containing server state such as blocked etc.)
        // If we can't then we add AB reference to the output array
        
        BOOL bFoundInDB = NO;
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
    
    return output;
}

+ (NSArray *)findValidObjects
{
    NSArray* output = [SWPerson findAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isUser == %@", [NSNumber numberWithBool:YES]];
    return [output filteredArrayUsingPredicate:predicate];
}

+ (void)deleteAllObjects
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
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
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", serverID];

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
    NSArray* people = [SWPerson findAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY phoneNumbers.phoneNumber == %@", phoneNb];
    NSArray* items = [people filteredArrayUsingPredicate:predicate];
    if (items.count == 0)
        return nil;
    return (SWPerson*)[items objectAtIndex:0];
}

+ (SWPerson*)createEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    SWPerson* obj = [NSEntityDescription
                    insertNewObjectForEntityForName:NSStringFromClass([self class])
                    inManagedObjectContext:context];
    
    return (SWPerson*)obj;
}

+ (SWPerson*)newEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];    
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    SWPerson* obj = [[SWPerson alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    return obj;
}

- (void)updateWithObject:(id)obj
{    
    self.serverID       = [[obj valueForKey:@"id"] intValue];
    self.isUser         = [[obj valueForKey:@"activated"] boolValue];
    self.isBlocked      = [[obj valueForKey:@"blocked"] boolValue];
    self.isBlocking     = [[obj valueForKey:@"blocking"] boolValue];
    self.isLinked       = [[obj valueForKey:@"linked"] boolValue];
    
    NSString* origPhone = [obj valueForKey:@"original_phone_number"];
    if (origPhone && [origPhone class] != [NSNull class])
    {
        SWPhoneNumber* pn   = [SWPhoneNumber findObjectWithPhoneNumber:origPhone];
        if (!pn || pn.person.serverID != self.serverID)
        {
            SWPhoneNumber* pn   = [SWPhoneNumber createEntity];
            pn.phoneNumber      = origPhone;
            pn.normalized       = NO;
            pn.invalid          = NO;
            pn.person           = self;
            [self addPhoneNumbersObject:pn];
        }
    }

    NSString* phone = [obj valueForKey:@"phone_number"];
    if (phone && [phone class] != [NSNull class])
    {
        SWPhoneNumber* pn = [SWPhoneNumber findObjectWithPhoneNumber:phone];
        if (!pn || pn.person.serverID != self.serverID)
        {
            pn              = [SWPhoneNumber createEntity];
            pn.phoneNumber  = phone;
            pn.invalid      = NO;
            pn.normalized   = YES;
            pn.person       = self;
            
            [self addPhoneNumbersObject:pn];
        }
    }
}

- (SWPhoneNumber*)normalizedPhoneNumber
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
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
    NSMutableArray* peopleAB = [NSMutableArray array];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        
        SWPerson* p = [SWPerson newEntity];
        p.firstName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        p.lastName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++)
        {
            SWPhoneNumber* pn = [SWPhoneNumber newEntity];
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

@end
