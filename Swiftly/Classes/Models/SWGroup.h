//
//  SWGroup.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWPerson.h"

@interface SWGroup : NSObject
{
    NSNumber*               _objectID;
    NSString*               _name;
    NSArray*                _contacts;
}

@property (nonatomic, strong) NSNumber*             objectID;
@property (nonatomic, strong) NSString*             name;
@property (nonatomic, strong) NSArray*              contacts;

- (NSString*)participants;

@end
