//
//  SWMedia+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWMedia+Details.h"
#import "SDImageCache.h"
#import "KTPhotoView+SDWebImage.h"
#import "KTThumbView+SDWebImage.h"

@implementation SWMedia (Details)

- (UIImage*)thumbnailOrDefaultImage
{
    if (self.thumbnail)
        return self.thumbnail;
    return [UIImage imageNamed:@"photoDefault.png"];
}

- (NSString*)uploadedTime
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [NSString stringWithFormat:NSLocalizedString(@"uploaded_time", @"uploaded now"), [format stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:self.uploadedDate]]];
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

+ (NSArray*)findInProgressObjects
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isUploaded == %@", [NSNumber numberWithBool:NO]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    return [context executeFetchRequest:request error:nil];
}

+ (NSArray*)findRecentObjects
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isUploaded == %@", [NSNumber numberWithBool:YES]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setFetchLimit:20];
    [request setPredicate:predicate];
    
    NSArray* arr = [[context executeFetchRequest:request error:nil] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSTimeInterval t1 = [(SWMedia*)obj1 uploadedDate];
        NSTimeInterval t2 = [(SWMedia*)obj2 uploadedDate];
        return t1 <= t2;
    }];
    
    return arr;
}

+ (void)deleteAllObjects
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:request error:&error];
    
    
    for (SWMedia *managedObject in items) 
    {
        [[SDImageCache sharedImageCache] removeImageForKey:[KTPhotoView cacheKeyForIndex:managedObject.serverID]];
        [[SDImageCache sharedImageCache] removeImageForKey:[KTThumbView cacheKeyForIndex:managedObject.serverID]];
        
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

+ (NSArray *)findMediasFromAlbumID:(NSInteger)serverID
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"album.serverID == %d", serverID];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    return [context executeFetchRequest:request error:nil];
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
    [[SDImageCache sharedImageCache] removeImageForKey:[KTPhotoView cacheKeyForIndex:self.serverID]];
    [[SDImageCache sharedImageCache] removeImageForKey:[KTThumbView cacheKeyForIndex:self.serverID]];
    
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [context deleteObject:self];
}

- (void)updateWithObject:(id)obj
{        
    self.serverID       = [[obj valueForKey:@"id"] intValue];
    self.isReady        = [[obj valueForKey:@"ready"] boolValue];
    self.creatorID      = [[obj valueForKey:@"creator_id"] intValue];
    self.isImage        = [[obj valueForKey:@"image"] boolValue];
    self.isVideo        = [[obj valueForKey:@"video"] boolValue];
    self.isOpen         = [[obj valueForKey:@"open"] boolValue];
    self.isOwner        = [[obj valueForKey:@"owner"] boolValue];
    self.duration       = (int)round([[obj valueForKey:@"duration"] doubleValue]);
    
    id thumb_url = [obj valueForKey:@"thumbnail_url"];
    if (thumb_url && [thumb_url class] != [NSNull class])
        self.thumbnailURL   = thumb_url;
    
    id res_url = [obj valueForKey:@"url"];
    if (res_url && [res_url class] != [NSNull class])
        self.resourceURL = res_url;
    
    id uploadInfo = [obj valueForKey:@"upload_info"];
    if (uploadInfo && [uploadInfo class] != [NSNull class])
    {
        self.contentType    = [uploadInfo valueForKey:@"content_type"];
        self.signature      = [uploadInfo valueForKey:@"signature"];
        self.policy         = [uploadInfo valueForKey:@"policy"];
        self.acl            = [uploadInfo valueForKey:@"acl"];
        self.filename       = [uploadInfo valueForKey:@"filename"];
        self.awsAccessKeyID = [uploadInfo valueForKey:@"aws_access_key_id"];
        self.bucketURL      = [uploadInfo valueForKey:@"bucket_url"];
    }
}

@end
