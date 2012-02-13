//
//  SWPerson.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWAlbum, SWGroup;

@interface SWPerson : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic) BOOL isBlocked;
@property (nonatomic) BOOL isBlocking;
@property (nonatomic) BOOL isLinked;
@property (nonatomic) BOOL isUser;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSSet *albums;
@property (nonatomic, retain) NSSet *groups;
@end

@interface SWPerson (CoreDataGeneratedAccessors)

- (void)addAlbumsObject:(SWAlbum *)value;
- (void)removeAlbumsObject:(SWAlbum *)value;
- (void)addAlbums:(NSSet *)values;
- (void)removeAlbums:(NSSet *)values;
- (void)addGroupsObject:(SWGroup *)value;
- (void)removeGroupsObject:(SWGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;
@end
