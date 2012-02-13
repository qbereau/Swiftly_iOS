//
//  SWGroup.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWPerson;

@interface SWGroup : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *contacts;
@end

@interface SWGroup (CoreDataGeneratedAccessors)

- (void)addContactsObject:(SWPerson *)value;
- (void)removeContactsObject:(SWPerson *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;
@end
