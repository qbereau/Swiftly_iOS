//
//  SWGroup.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWGroup.h"

@implementation SWGroup

@synthesize name        = _name;
@synthesize contacts    = _contacts;

- (NSString*)participants
{
    NSMutableString* output = [[NSMutableString alloc] init];
    for (SWPerson* p in _contacts)
    {
        [output appendFormat:@"%@, ", p.name];
    }
    
    if ([_contacts count] > 0)
        return [output substringToIndex:[output length] - 2];
    
    return output;
}

@end
