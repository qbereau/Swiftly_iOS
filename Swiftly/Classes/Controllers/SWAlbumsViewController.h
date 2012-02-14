//
//  SWFirstViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTabBarController.h"
#import "SWAlbum.h"
#import "SWAlbumThumbnailsViewController.h"
#import "SWTableViewCell.h"
#import "JSLockScreenViewController.h"
#import "SWAPIClient.h"

@interface SWAlbumsViewController : UITableViewController <JSLockScreenDelegate>
{
    NSArray*                        _sharedAlbums;
    NSArray*                        _specialAlbums;    
    
    
    JSLockScreenViewController*     _lockScreenViewController;    
    
    NSManagedObjectContext*         _managedObjectContext;
}

@property (nonatomic, strong) NSArray*              sharedAlbums;
@property (nonatomic, strong) NSArray*              specialAlbums;
@property (nonatomic, strong) NSManagedObjectContext*   managedObjectContext;

- (void)synchronize;

@end
