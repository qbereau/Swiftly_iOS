//
//  SWGroupEditViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWPeopleListViewController.h"
#import "SWTableView.h"
#import "SWTableViewCell.h"
#import "SWPerson.h"
#import "SWGroup.h"

@interface SWGroupEditViewController : UITableViewController <UITextFieldDelegate, SWPeopleListViewControllerDelegate>
{
    SWGroup*            _group;
}

@property (nonatomic, strong) SWGroup*              group;

@end