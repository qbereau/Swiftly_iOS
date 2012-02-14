//
//  SWGroup+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWGroup+Details.h"

@implementation SWGroup (Details)

- (NSString*)contacts_str
{
    NSMutableString* output = [[NSMutableString alloc] init];
    for (SWPerson* p in self.contacts)
    {
        [output appendFormat:@"%@, ", [p name]];
    }
    
    if ([self.contacts count] > 0)
        return [output substringToIndex:[output length] - 2];
    
    return output;
}

- (NSArray*)contacts_arr
{
    NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"predicateContactName" ascending:YES];
    return [self.contacts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
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
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
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

+ (SWGroup*)findObjectWithServerID:(int)serverID
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
    return (SWGroup*)[items objectAtIndex:0];
}

+ (SWGroup*)createEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    SWGroup* obj = [NSEntityDescription
                    insertNewObjectForEntityForName:NSStringFromClass([self class])
                    inManagedObjectContext:context];
    
    return (SWGroup*)obj;
}


+ (SWGroup*)newEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];    
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    SWGroup* obj = [[SWGroup alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    return obj;
}

- (void)deleteEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [context deleteObject:self];
}

- (void)updateWithObject:(id)obj
{    
    NSString* g_name = [obj valueForKey:@"name"];
    if (!g_name || [g_name class] == [NSNull class])
        g_name = nil;
    
    if (g_name)
        self.name = g_name;
    
    self.serverID = [[obj valueForKey:@"id"] intValue];
    
    if (self.contacts)
        self.contacts = nil;    
    for (NSNumber* account_id in [obj valueForKey:@"account_ids"])
    {
        SWPerson* p = [SWPerson findObjectWithServerID:[account_id intValue]];
        if (p)
        {
            [self addContactsObject:p];
        }
    }
}

@end
