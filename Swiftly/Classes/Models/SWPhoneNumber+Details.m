//
//  SWPhoneNumber+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPhoneNumber+Details.h"

@implementation SWPhoneNumber (Details)

// Core Data Helpers

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context
{
    return [self respondsToSelector:@selector(entityInManagedObjectContext:)] ?
    [self performSelector:@selector(entityInManagedObjectContext:) withObject:context] :
    [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+ (NSArray *)findAllObjects
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [SWPhoneNumber findAllObjectsInContext:context];
}

+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    return [context executeFetchRequest:request error:nil];
}

+ (void)deleteAllObjects
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [SWPhoneNumber deleteAllObjectsInContext:context];
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

+ (SWPhoneNumber*)findObjectWithPhoneNumber:(NSString*)phoneNb
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [SWPhoneNumber findObjectWithPhoneNumber:phoneNb inContext:context];
}

+ (SWPhoneNumber*)findObjectWithPhoneNumber:(NSString*)phoneNb inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"phoneNumber == %@", phoneNb];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray* items = [context executeFetchRequest:request error:nil];
    if ([items count] == 0)
        return nil;
    return (SWPhoneNumber*)[items objectAtIndex:0];
}

+ (SWPhoneNumber*)findValidObjectWithPhoneNumber:(NSString*)phoneNb
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [SWPhoneNumber findValidObjectWithPhoneNumber:phoneNb inContext:context];
}

+ (SWPhoneNumber*)findValidObjectWithPhoneNumber:(NSString*)phoneNb inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"phoneNumber = %@", phoneNb];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray* items = [context executeFetchRequest:request error:nil];
    if ([items count] == 0)
        return nil;
    return (SWPhoneNumber*)[items objectAtIndex:0];
}

+ (NSArray*)findObjectsWithPersonID:(int)serverID
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [SWPhoneNumber findObjectsWithPersonID:serverID inContext:context];
}

+ (NSArray*)findObjectsWithPersonID:(int)serverID inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"person.serverID == %d", serverID];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    return [context executeFetchRequest:request error:nil];
}

+ (SWPhoneNumber*)createEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [SWPhoneNumber createEntityInContext:context];
}

+ (SWPhoneNumber*)createEntityInContext:(NSManagedObjectContext *)context
{
    SWPhoneNumber* obj = [NSEntityDescription
                    insertNewObjectForEntityForName:NSStringFromClass([self class])
                    inManagedObjectContext:context];
    
    return (SWPhoneNumber*)obj;
}

+ (SWPhoneNumber*)newEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];    
    return [SWPhoneNumber newEntityInContext:context];
}

+ (SWPhoneNumber*)newEntityInContext:(NSManagedObjectContext *)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    SWPhoneNumber* obj = [[SWPhoneNumber alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
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

@end
