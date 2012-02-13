//
//  SWSwichButton.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWSwitchButton.h"

@implementation SWSwitchButton

@synthesize pushed = _pushed;

- (void)setPushed:(BOOL)p
{
    _pushed = p;
    
    if (_pushed)
    {
        [self setBackgroundImage:[[UIImage imageNamed:@"rounded_button_pushed"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateNormal];
    }
    else
    {
        [self setBackgroundImage:[[UIImage imageNamed:@"rounded_button"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateNormal];        
    }
}

@end
