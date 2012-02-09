//
//  SWPerson.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPerson.h"

@implementation SWPerson

@synthesize firstName   = _firstName;
@synthesize lastName    = _lastName;
@synthesize phoneNumber = _phoneNumber;
@synthesize thumbnail   = _thumbnail;
@synthesize isUser      = _isUser;
@synthesize isBlocked   = _isBlocked;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.firstName      = [NSString new];
        self.lastName       = [NSString new];
        self.phoneNumber    = [NSString new];
        self.thumbnail      = [UIImage imageNamed:@"user@2x.png"];
        self.isUser         = NO;
        self.isBlocked      = NO;
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

- (UIImage*)contactImage
{
    UIImage* icon;
    if (self.isBlocked)
        icon = [UIImage imageNamed:@"block"];
    else if (self.isUser)
        icon = [UIImage imageNamed:@"valid"];
    else 
        return self.thumbnail;
    
    UIImage* thumb = self.thumbnail;
    
    CGSize size = CGSizeMake(50, 50);
    
    // Reduce contact thumbnail
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [self.thumbnail drawInRect:CGRectMake(0, 0, size.width, size.height)];
    thumb = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();    
    
    
    // Merge tow images
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    [thumb drawInRect:CGRectMake(0, 0, thumb.size.width, thumb.size.height)];
    [icon drawInRect:CGRectMake(34, 34, 16, 16) blendMode:kCGBlendModeNormal alpha:1];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

@end
