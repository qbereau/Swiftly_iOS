//
//  SWGroup+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWGroup+Details.h"

@implementation SWGroup (Details)

- (NSString*)participants
{
    NSMutableString* output = [[NSMutableString alloc] init];
    for (SWPerson* p in self.contacts)
    {
        [output appendFormat:@"%@, ", [p name]];
    }
    
    if ([self.contacts count] > 0)
        return [output substringToIndex:[output length] - 2];
    
    return output;
}

@end
