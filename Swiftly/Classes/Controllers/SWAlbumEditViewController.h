//
//  SWAlbumEditViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAlertView+Blocks.h"
#import "SWTableView.h"
#import "SWTableViewCell.h"

@interface SWAlbumEditViewController : UITableViewController <UITextFieldDelegate>
{
    NSArray*            _people;
}

@property (nonatomic, strong) NSArray*      people;

@end
