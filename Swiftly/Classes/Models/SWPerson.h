//
//  SWPerson.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWAlbum, SWComment, SWGroup, SWMedia, SWPhoneNumber;

@interface SWPerson : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic) BOOL isBlocked;
@property (nonatomic) BOOL isBlocking;
@property (nonatomic) BOOL isLinked;
@property (nonatomic) BOOL isSelf;
@property (nonatomic) BOOL isUser;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic) int32_t serverID;
@property (nonatomic, retain) id thumbnail;
@property (nonatomic, retain) NSSet *albums;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) NSSet *phoneNumbers;
@property (nonatomic, retain) NSSet *sharedMedias;
@end

@interface SWPerson (CoreDataGeneratedAccessors)

- (void)addAlbumsObject:(SWAlbum *)value;
- (void)removeAlbumsObject:(SWAlbum *)value;
- (void)addAlbums:(NSSet *)values;
- (void)removeAlbums:(NSSet *)values;
- (void)addCommentsObject:(SWComment *)value;
- (void)removeCommentsObject:(SWComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;
- (void)addGroupsObject:(SWGroup *)value;
- (void)removeGroupsObject:(SWGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;
- (void)addPhoneNumbersObject:(SWPhoneNumber *)value;
- (void)removePhoneNumbersObject:(SWPhoneNumber *)value;
- (void)addPhoneNumbers:(NSSet *)values;
- (void)removePhoneNumbers:(NSSet *)values;
- (void)addSharedMediasObject:(SWMedia *)value;
- (void)removeSharedMediasObject:(SWMedia *)value;
- (void)addSharedMedias:(NSSet *)values;
- (void)removeSharedMedias:(NSSet *)values;
@end
