//
//  SWPhoneNumber.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWPerson;

@interface SWPhoneNumber : NSManagedObject

@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic) BOOL invalid;
@property (nonatomic) BOOL normalized;
@property (nonatomic, retain) SWPerson *person;

@end
