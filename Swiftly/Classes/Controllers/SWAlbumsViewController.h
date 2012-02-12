//
//  SWFirstViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWAlbum.h"
#import "SWAlbumThumbnailsViewController.h"
#import "SWTableViewCell.h"
#import "JSLockScreenViewController.h"

@interface SWAlbumsViewController : UITableViewController <JSLockScreenDelegate>
{
    NSMutableArray*                 _albums;
    
    JSLockScreenViewController*     _lockScreenViewController;    
}

@property (nonatomic, strong) NSMutableArray*           albums;

@end
