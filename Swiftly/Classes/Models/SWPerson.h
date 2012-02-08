//
//  SWPerson.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWPerson : NSObject
{
    NSString*           _firstName;
    NSString*           _lastName;
    NSString*           _phoneNumber;
    UIImage*            _thumbnail;
}

@property (nonatomic, strong) NSString*      firstName;
@property (nonatomic, strong) NSString*      lastName;
@property (nonatomic, strong) NSString*      phoneNumber;
@property (nonatomic, strong) UIImage*       thumbnail;

- (NSString*)name;
- (NSString*)predicateContactName;

@end
