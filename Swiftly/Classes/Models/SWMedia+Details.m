//
//  SWMedia+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWMedia+Details.h"

@implementation SWMedia (Details)

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

+ (SWMedia*)findObjectWithServerID:(int)serverID
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
    return (SWMedia*)[items objectAtIndex:0];
}

+ (SWMedia*)createEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    SWMedia* obj = [NSEntityDescription
                    insertNewObjectForEntityForName:NSStringFromClass([self class])
                    inManagedObjectContext:context];
    
    return (SWMedia*)obj;
}


+ (SWMedia*)newEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];    
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    SWMedia* obj = [[SWMedia alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    return obj;
}

- (void)deleteEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [context deleteObject:self];
}

- (void)updateWithObject:(id)obj
{        
    self.serverID = [[obj valueForKey:@"id"] intValue];
    
    id uploadInfo = [obj valueForKey:@"upload_info"];
    if (uploadInfo)
    {
        self.contentType    = [uploadInfo valueForKey:@"content_type"];
        self.signature      = [uploadInfo valueForKey:@"signature"];
        self.policy         = [uploadInfo valueForKey:@"policy"];
        self.acl            = [uploadInfo valueForKey:@"acl"];
        self.filename       = [uploadInfo valueForKey:@"filename"];
        self.awsAccessKeyID = [uploadInfo valueForKey:@"aws_access_key_id"];        
    }
}

@end
