//
//  SWPeopleListViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "SWContactViewController.h"
#import "SWTableView.h"
#import "SWTableViewCell.h"
#import "SWPerson.h"

@interface SWPeopleListViewController : UITableViewController
{
    NSArray*            _contacts;
}

@property (nonatomic, strong) NSArray*          contacts;

- (NSPredicate*)predicateForSection:(NSInteger)idx;

@end
