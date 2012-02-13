//
//  SWPerson+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPerson+Details.h"

@implementation SWPerson (Details)

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    if (!((SWPerson*)object).phoneNumber || [((SWPerson*)object).phoneNumber length] == 0)
        return NO;
    if ([((SWPerson*)object).phoneNumber isEqualToString:self.phoneNumber])
        return YES;
    return NO;
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
        return [UIImage imageWithData:self.thumbnail];
    
    UIImage* thumb = [UIImage imageWithData:self.thumbnail];
    
    CGSize size = CGSizeMake(50, 50);
    
    // Reduce contact thumbnail
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [[UIImage imageWithData:self.thumbnail] drawInRect:CGRectMake(0, 0, size.width, size.height)];
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
