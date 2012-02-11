//
//  SWAlbumEditViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAlertView+Blocks.h"
#import "SWPeopleListViewController.h"
#import "SWAlbum.h"
#import "SWPerson.h"
#import "SWTableView.h"
#import "SWTableViewCell.h"

@interface SWAlbumEditViewController : UITableViewController <UITextFieldDelegate, SWPeopleListViewControllerDelegate>
{
    SWAlbum*            _album;
}

@property (nonatomic, strong) SWAlbum*      album;

@end
