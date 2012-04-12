//
//  SWAlbum.h
//  Swiftly
//
//  Created by Quentin Bereau on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWMedia, SWPerson;

@interface SWAlbum : NSManagedObject

@property (nonatomic) BOOL canAddMedias;
@property (nonatomic) BOOL canEditPeople;
@property (nonatomic) BOOL canExportMedias;
@property (nonatomic) BOOL isLocked;
@property (nonatomic) BOOL isOwner;
@property (nonatomic) BOOL isQuickShareAlbum;
@property (nonatomic) NSTimeInterval lastUpdate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t ownerID;
@property (nonatomic) int32_t serverID;
@property (nonatomic, retain) id thumbnail;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic) BOOL updated;
@property (nonatomic, retain) NSSet *medias;
@property (nonatomic, retain) NSSet *participants;
@end

@interface SWAlbum (CoreDataGeneratedAccessors)

- (void)addMediasObject:(SWMedia *)value;
- (void)removeMediasObject:(SWMedia *)value;
- (void)addMedias:(NSSet *)values;
- (void)removeMedias:(NSSet *)values;

- (void)addParticipantsObject:(SWPerson *)value;
- (void)removeParticipantsObject:(SWPerson *)value;
- (void)addParticipants:(NSSet *)values;
- (void)removeParticipants:(NSSet *)values;

@end
