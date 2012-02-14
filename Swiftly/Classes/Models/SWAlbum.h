//
//  SWAlbum.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWPerson;

@interface SWAlbum : NSManagedObject

@property (nonatomic) BOOL canEditMedias;
@property (nonatomic) BOOL canEditPeople;
@property (nonatomic) BOOL canExportMedias;
@property (nonatomic) BOOL isLocked;
@property (nonatomic) BOOL isOwner;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t ownerID;
@property (nonatomic, retain) id thumbnail;
@property (nonatomic) int32_t serverID;
@property (nonatomic) BOOL isQuickShareAlbum;
@property (nonatomic) BOOL isMyMediasAlbum;
@property (nonatomic, retain) NSSet *participants;
@end

@interface SWAlbum (CoreDataGeneratedAccessors)

- (void)addParticipantsObject:(SWPerson *)value;
- (void)removeParticipantsObject:(SWPerson *)value;
- (void)addParticipants:(NSSet *)values;
- (void)removeParticipants:(NSSet *)values;
@end
