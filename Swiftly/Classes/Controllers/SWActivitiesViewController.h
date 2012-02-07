//
//  SWSecondViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableView.h"
#import "SWActivityTableViewCell.h"

@interface SWActivitiesViewController : UIViewController
{
    NSArray*        _activities;
}

@property (nonatomic, strong) NSArray*      activities;

@property (nonatomic, weak) IBOutlet UINavigationBar*   navigationBar;
@property (nonatomic, weak) IBOutlet SWTableView*   tableView;

@end
