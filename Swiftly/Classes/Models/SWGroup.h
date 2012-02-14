//
//  SWGroup.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWPerson;

@interface SWGroup : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t serverID;
@property (nonatomic, retain) NSSet *contacts;
@end

@interface SWGroup (CoreDataGeneratedAccessors)

- (void)addContactsObject:(SWPerson *)value;
- (void)removeContactsObject:(SWPerson *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;
@end
