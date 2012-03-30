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
#import "SWGroupListViewController.h"
#import "SWAPIClient.h"
#import "SDWebImageDownloader.h"

@interface SWAlbumsViewController : UITableViewController <JSLockScreenDelegate, SDWebImageDownloaderDelegate>
{
    NSArray*                        _sharedAlbums;
    NSArray*                        _specialAlbums;    
    
    
    JSLockScreenViewController*     _lockScreenViewController;    
    
    NSManagedObjectContext*         _managedObjectContext;
    
    int                             _reqAlbumsOps;
    int                             _reqOps;
    NSMutableArray*                 _receivedAlbums;
    
    NSOperationQueue*               _operationQueue;
    NSMutableArray*                 _arrAlbumsID;
    BOOL                            _shouldCleanup;
    
    BOOL                            _shouldResync;        
}

@property (nonatomic, strong) NSMutableArray*           arrAlbumsID;
@property (nonatomic, strong) NSMutableArray*           receivedAlbums;
@property (nonatomic, strong) NSArray*                  sharedAlbums;
@property (nonatomic, strong) NSArray*                  specialAlbums;
@property (nonatomic, strong) NSManagedObjectContext*   managedObjectContext;
@property (nonatomic, assign) int                       reqOps;
@property (nonatomic, assign) int                       reqAlbumsOps;
@property (nonatomic, strong) NSOperationQueue*         operationQueue;
@property (nonatomic, assign) BOOL                      shouldResync;

- (void)refreshedAB:(NSNotification*)notification;
- (void)uploadMediaDone:(NSNotification*)notification;

- (void)processAlbumsWithDict:(NSDictionary*)dict;
- (void)updateAlbumAccounts:(SWAlbum*)album;
- (void)processAlbumID:(int)albumID accounts:(id)responseObject;
- (void)removeOldAlbums;
- (void)saveAndUpdate;
- (void)reload;
- (void)synchronize;

@end
