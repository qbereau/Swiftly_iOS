//
//  SWPhoneNumber.h
//  Swiftly
//
//  Created by Quentin Bereau on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWPerson;

@interface SWPhoneNumber : NSManagedObject

@property (nonatomic) BOOL invalid;
@property (nonatomic) BOOL normalized;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) SWPerson *person;

@end
