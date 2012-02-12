//
//  SWAlbumLockViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableView.h"
#import "SWTableViewCell.h"
#import "JSLockScreenViewController.h"

@interface SWAlbumLockViewController : UITableViewController
{
    NSNumber*                       _albumLock;
}

@property (nonatomic, strong) NSNumber*         albumLock;

@end
