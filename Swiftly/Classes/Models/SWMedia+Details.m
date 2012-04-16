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
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

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
    self.isReady                    = [obj objectForKey:@"ready"] ? [[obj valueForKey:@"ready"] boolValue] : YES;
    self.creatorID                  = [[obj valueForKey:@"creator_id"] intValue];
    
    NSString* contentType = [obj objectForKey:@"content_type"];
    if ([contentType rangeOfString:@"image"].location != NSNotFound)
    {
        self.isImage    = YES;
        self.isVideo    = NO;
    }
    else if ([contentType rangeOfString:@"video"].location != NSNotFound)
    {
        self.isImage    = NO;
        self.isVideo    = YES;
    }

    self.isOwner                    = [[obj valueForKey:@"owner"] boolValue];
    self.nbComments                 = [[obj valueForKey:@"comment_count"] intValue];
    self.isOpen                     = [[obj objectForKey:@"grant"] boolValue];
    
    // --
    id aData = [obj objectForKey:@"adata"];
    if (aData && [aData class] != [NSNull class])
    {
        self.duration    = [aData objectForKey:@"duration"] ? (int)round([[aData objectForKey:@"duration"] doubleValue]) : 0;
    }
    // --    
    
    id thumb_url = [obj valueForKey:@"thumbnail_url"];
    if (thumb_url && [thumb_url class] != [NSNull class])
        self.thumbnailURL   = thumb_url;
    
    id res_url = [obj valueForKey:@"url"];
    if (res_url && [res_url class] != [NSNull class])
        self.resourceURL = res_url;
    
    id uploadInfo = [obj valueForKey:@"meta"];
    if (uploadInfo && [uploadInfo class] != [NSNull class])
    {
        self.bucketURL      = [uploadInfo valueForKey:@"bucket_url"];        
        
        id orig                     = [uploadInfo valueForKey:@"original"];
        self.originalContentType    = [orig valueForKey:@"content_type"];
        self.originalSignature      = [orig valueForKey:@"signature"];
        self.originalPolicy         = [orig valueForKey:@"policy"];
        self.originalACL            = [orig valueForKey:@"acl"];
        self.originalFilename       = [orig valueForKey:@"filename"];
        self.originalAWSAccessKeyID = [orig valueForKey:@"aws_access_key_id"];
        
        id th                        = [uploadInfo valueForKey:@"thumbnail"];
        self.thumbnailContentType    = [th valueForKey:@"content_type"];
        self.thumbnailSignature      = [th valueForKey:@"signature"];
        self.thumbnailPolicy         = [th valueForKey:@"policy"];
        self.thumbnailACL            = [th valueForKey:@"acl"];
        self.thumbnailFilename       = [th valueForKey:@"filename"];
        self.thumbnailAWSAccessKeyID = [th valueForKey:@"aws_access_key_id"];        
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
