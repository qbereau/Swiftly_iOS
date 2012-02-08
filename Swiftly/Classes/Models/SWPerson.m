//
//  SWPerson.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPerson.h"

@implementation SWPerson

@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize phoneNumber = _phoneNumber;
@synthesize thumbnail = _thumbnail;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.firstName      = [NSString new];
        self.lastName       = [NSString new];
        self.phoneNumber    = [NSString new];
        self.thumbnail      = [UIImage imageNamed:@"user@2x.png"];
    }
    
    return self;
}

- (NSString*)name
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName ? self.firstName : @"", self.lastName ? self.lastName : @""];
}

- (NSString*)predicateContactName
{
    if (self.lastName.length > 0)
        return self.lastName;
    return [self name];
}

@end
