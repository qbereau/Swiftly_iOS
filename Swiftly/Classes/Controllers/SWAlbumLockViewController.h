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
#import "KVPasscodeViewController.h"

@interface SWAlbumLockViewController : UITableViewController <KVPasscodeViewControllerDelegate>
{
    NSNumber*                       _albumLock;    
    NSNumber*                       _newAlbumLock;
    BOOL                            _wantToDeleteAlbumLock;
    BOOL                            _confirmingLock;
    KVPasscodeViewController*       _passcodeController;
}

@property (nonatomic, strong) NSNumber*         albumLock;

@end
