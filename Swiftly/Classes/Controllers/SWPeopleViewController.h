//
//  SWPeopleViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWGroupListViewController.h"
#import "SWPeopleListViewController.h"

@interface SWPeopleViewController : UIViewController
{
    NSInteger           _currentMode;
    
    SWPeopleListViewController*         _plvc;
    SWGroupListViewController*          _glvc;
}

@property (nonatomic, assign) NSInteger         currentMode;

- (void)changeMode:(UISegmentedControl*)sender;

@end
