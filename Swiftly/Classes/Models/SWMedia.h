//
//  SWMedia.h
//  Swiftly
//
//  Created by Quentin Bereau on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWAlbum, SWComment, SWPerson;

@interface SWMedia : NSManagedObject

@property (nonatomic, retain) NSString * originalACL;
@property (nonatomic, retain) NSString * assetURL;
@property (nonatomic, retain) NSString * originalAWSAccessKeyID;
@property (nonatomic, retain) NSString * bucketURL;
@property (nonatomic, retain) NSString * originalContentType;
@property (nonatomic) int32_t creatorID;
@property (nonatomic) int32_t duration;
@property (nonatomic, retain) NSString * originalFilename;
@property (nonatomic) BOOL isCancelled;
@property (nonatomic) BOOL isHiddenFromActivities;
@property (nonatomic) BOOL isImage;
@property (nonatomic) BOOL isOpen;
@property (nonatomic) BOOL isOwner;
@property (nonatomic) BOOL isReady;
@property (nonatomic) BOOL isSyncedFromServer;
@property (nonatomic) BOOL isUploaded;
@property (nonatomic) BOOL isVideo;
@property (nonatomic, retain) NSString * localResourceURL;
@property (nonatomic, retain) NSString * localThumbnailURL;
@property (nonatomic, retain) NSString * originalPolicy;
@property (nonatomic, retain) NSString * resourceURL;
@property (nonatomic) int32_t serverID;
@property (nonatomic, retain) NSString * originalSignature;
@property (nonatomic, retain) id thumbnail;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic) NSTimeInterval uploadedDate;
@property (nonatomic) float uploadProgress;
@property (nonatomic, retain) NSString * thumbnailACL;
@property (nonatomic, retain) NSString * thumbnailAWSAccessKeyID;
@property (nonatomic, retain) NSString * thumbnailContentType;
@property (nonatomic, retain) NSString * thumbnailFilename;
@property (nonatomic, retain) NSString * thumbnailPolicy;
@property (nonatomic, retain) NSString * thumbnailSignature;
@property (nonatomic) int32_t nbComments;
@property (nonatomic, retain) SWAlbum *album;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *sharedPeople;
@end

@interface SWMedia (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(SWComment *)value;
- (void)removeCommentsObject:(SWComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addSharedPeopleObject:(SWPerson *)value;
- (void)removeSharedPeopleObject:(SWPerson *)value;
- (void)addSharedPeople:(NSSet *)values;
- (void)removeSharedPeople:(NSSet *)values;

@end
