//
//  SWSwichButton.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWSwitchButton : UIButton
{
    BOOL            _pushed;
}

@property (nonatomic, assign) BOOL      pushed;

@end
