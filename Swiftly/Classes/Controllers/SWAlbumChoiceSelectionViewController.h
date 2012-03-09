//
//  SWAlbumChoiceSelectionViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableView.h"
#import "SWTableViewCell.h"
#import "SWAlbumEditViewController.h"

@interface SWAlbumChoiceSelectionViewController : UITableViewController
{
    NSArray*            _filesToUpload;
}

@property (nonatomic, strong) NSArray*      filesToUpload;

@end
