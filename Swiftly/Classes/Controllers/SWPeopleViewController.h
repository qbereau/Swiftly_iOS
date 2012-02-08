//
//  SWPeopleViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "SWTableViewCell.h"
#import "SWPerson.h"

@interface SWPeopleViewController : UITableViewController
{
    NSInteger           _currentMode;
    NSArray*            _groups;
    NSArray*            _contacts;
}

@property (nonatomic, assign) NSInteger         currentMode;
@property (nonatomic, strong) NSArray*          groups;
@property (nonatomic, strong) NSArray*          contacts;

- (NSPredicate*)predicateForSection:(NSInteger)idx;

@end
