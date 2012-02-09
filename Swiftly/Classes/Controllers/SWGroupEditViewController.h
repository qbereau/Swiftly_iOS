//
//  SWGroupEditViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableView.h"
#import "SWTableViewCell.h"
#import "SWPerson.h"

@interface SWGroupEditViewController : UITableViewController <UITextFieldDelegate>
{
    NSString*           _name;
    NSArray*            _contacts;
}

@property (nonatomic, strong) NSString*             name;
@property (nonatomic, strong) NSArray*              contacts;

@end
