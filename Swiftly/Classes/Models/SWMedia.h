//
//  SWMedia.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWAlbum;

@interface SWMedia : NSManagedObject

@property (nonatomic, retain) NSString * acl;
@property (nonatomic, retain) NSString * assetURL;
@property (nonatomic, retain) NSString * awsAccessKeyID;
@property (nonatomic, retain) NSString * bucketURL;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic) int32_t creatorID;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic) BOOL isImage;
@property (nonatomic) BOOL isOpen;
@property (nonatomic) BOOL isReady;
@property (nonatomic) BOOL isUploaded;
@property (nonatomic) BOOL isVideo;
@property (nonatomic, retain) NSString * policy;
@property (nonatomic, retain) NSString * resourceURL;
@property (nonatomic) int32_t serverID;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) id thumbnail;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic) NSTimeInterval uploadedDate;
@property (nonatomic) float uploadProgress;
@property (nonatomic) BOOL isOwner;
@property (nonatomic, retain) SWAlbum *album;

@end
