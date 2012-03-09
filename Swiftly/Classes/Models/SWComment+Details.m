//
//  SWComment+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWComment+Details.h"

@implementation SWComment (Details)

- (void)updateWithObject:(id)obj inContext:(NSManagedObjectContext *)context
{    
    NSString* content = [obj valueForKey:@"content"];
    if (!content || [content class] == [NSNull class])
        content = nil;
    
    if (content)
        self.content = content;
    
    self.serverID = [[obj valueForKey:@"id"] intValue];
    
    NSString* creation = [obj valueForKey:@"created_at"];
    if (!creation || [creation class] == [NSNull class])
        creation = nil;
    
    if (creation)
    {
        self.createdDT = [[creation stringByReplacingOccurrencesOfString:@"T" withString:@" "] stringByReplacingOccurrencesOfString:@"Z" withString:@" "];
    }
    
    SWPerson* p = [SWPerson MR_findFirstByAttribute:@"serverID" withValue:[obj valueForKey:@"author_id"] inContext:context];
    self.author = p;
}

+ (NSArray*)findLatestCommentsForMediaID:(int)mediaID inContext:(NSManagedObjectContext*)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"media.serverID == %d", mediaID];
    return [SWComment MR_findAllWithPredicate:predicate inContext:context];
}

// Core Data Helpers
/*
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

+ (SWComment*)findObjectWithServerID:(int)serverID
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
    return (SWComment*)[items objectAtIndex:0];
}

+ (NSArray*)findLatestCommentsForMediaID:(int)mediaID
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"media.serverID == %d", mediaID];
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:@"createdDT"
                                ascending:NO
                                selector:@selector(compare:)];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setSortDescriptors:[NSArray arrayWithObject:sorter]];
    [request setEntity:entity];
    [request setFetchLimit:25];
    [request setPredicate:predicate];
    
    return [[[context executeFetchRequest:request error:nil] reverseObjectEnumerator] allObjects];
}

+ (SWComment*)createEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    SWComment* obj = [NSEntityDescription
                    insertNewObjectForEntityForName:NSStringFromClass([self class])
                    inManagedObjectContext:context];
    
    return (SWComment*)obj;
}


+ (SWComment*)newEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];    
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    SWComment* obj = [[SWComment alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    return obj;
}

- (void)deleteEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [context deleteObject:self];
}
*/
@end
