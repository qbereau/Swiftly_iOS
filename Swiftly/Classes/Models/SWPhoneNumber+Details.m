//
//  SWPhoneNumber+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPhoneNumber+Details.h"

@implementation SWPhoneNumber (Details)

+ (SWPhoneNumber*)newEntityInContext:(NSManagedObjectContext *)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    SWPhoneNumber* obj = [[SWPhoneNumber alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    return obj;
}

@end
