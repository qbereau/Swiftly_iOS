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

+ (NSString*)retrieveContentTypeFromMediaURL:(NSURL*)mediaURL
{
    if ([[[mediaURL absoluteString] lowercaseString] rangeOfString:@"ext=png"].location != NSNotFound)
        return @"image/png";
    else if ([[[mediaURL absoluteString] lowercaseString] rangeOfString:@"ext=mov"].location != NSNotFound)
        return @"video/quicktime";
    return @"image/jpeg";
}

- (void)updateWithObject:(id)obj
{        
    self.serverID                   = [[obj valueForKey:@"id"] intValue];
    self.isReady                    = [[obj valueForKey:@"ready"] boolValue];
    self.creatorID                  = [[obj valueForKey:@"creator_id"] intValue];
    self.isImage                    = [[obj valueForKey:@"image"] boolValue];
    self.isVideo                    = [[obj valueForKey:@"video"] boolValue];
    self.isOpen                     = [[obj valueForKey:@"open"] boolValue];
    self.isOwner                    = [[obj valueForKey:@"owner"] boolValue];
    self.duration                   = (int)round([[obj valueForKey:@"duration"] doubleValue]);
    
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

+ (NSArray*)findInProgressObjects
{
    return [SWMedia MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"isUploaded = NO AND (isCancelled = NO OR isCancelled = nil)"]];
}

+ (NSArray*)findRecentObjects
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isUploaded = YES OR isCancelled = YES) AND (isHiddenFromActivities = NO OR isHiddenFromActivities = nil)"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"serverID" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *request = [SWMedia MR_requestAllWithPredicate:predicate];
    [request setFetchLimit:25];
    [request setSortDescriptors:sortDescriptors];
    
    return [SWMedia MR_executeFetchRequest:request];
}

@end
