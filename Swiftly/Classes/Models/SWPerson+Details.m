//
//  SWPerson+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPerson+Details.h"

@implementation SWPerson (Details)

/*
- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    if (!((SWPerson*)object).phoneNumber || [((SWPerson*)object).phoneNumber length] == 0)
        return NO;
    if ([((SWPerson*)object).phoneNumber isEqualToString:self.phoneNumber])
        return YES;
    return NO;
}
 */

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

// Core Data Helpers

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context
{
    return [self respondsToSelector:@selector(entityInManagedObjectContext:)] ?
    [self performSelector:@selector(entityInManagedObjectContext:) withObject:context] :
    [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+ (NSArray *)findAllObjects
{
    NSMutableArray* phones = [NSMutableArray array];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);

        NSString* phoneNumber = @"";
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        NSString *mobileNumber;
        NSString *mobileLabel;
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++)
        {
            mobileLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
            if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneMobileLabel] || [mobileNumber isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]) 
            {
                phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers,i);
                break;
            }
        }
        
        [phones addObject:phoneNumber];
        
        CFRelease(ref);
    }     
    
    
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"originalPhoneNumber IN %@", phones];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];    
    return [context executeFetchRequest:request error:nil];
}

+ (NSArray *)findValidObjects
{
    NSMutableArray* phones = [NSMutableArray array];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        
        NSString* phoneNumber = @"";
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        NSString *mobileNumber;
        NSString *mobileLabel;
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++)
        {
            mobileLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
            if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneMobileLabel] || [mobileNumber isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]) 
            {
                phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers,i);
                break;
            }
        }
        
        [phones addObject:phoneNumber];
        
        CFRelease(ref);
    }     
    
    
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"originalPhoneNumber IN %@ AND isUser == %@", phones, [NSNumber numberWithBool:YES]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];    
    return [context executeFetchRequest:request error:nil];
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

+ (SWPerson*)findObjectWithOriginalPhoneNumber:(NSString*)phoneNb
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"originalPhoneNumber == %@", phoneNb];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray* items = [context executeFetchRequest:request error:nil];
    if ([items count] == 0)
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
    if (!origPhone || [origPhone class] == [NSNull class])
        origPhone = nil;
    self.originalPhoneNumber    = origPhone;

    NSString* phone = [obj valueForKey:@"phone_number"];
    if (!phone || [phone class] == [NSNull class])
        phone = nil;
    self.phoneNumber            = phone;
}

@end
