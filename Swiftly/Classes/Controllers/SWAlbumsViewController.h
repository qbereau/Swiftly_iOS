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
    
    int                             _reqOps;
    NSMutableArray*                 _receivedAlbums;
    
    NSOperationQueue*               _operationQueue;    
}

@property (nonatomic, strong) NSMutableArray*           receivedAlbums;
@property (nonatomic, strong) NSArray*                  sharedAlbums;
@property (nonatomic, strong) NSArray*                  specialAlbums;
@property (nonatomic, strong) NSManagedObjectContext*   managedObjectContext;
@property (nonatomic, assign) int                       reqOps;
@property (nonatomic, strong) NSOperationQueue*         operationQueue;

- (void)processAlbumsWithDict:(NSDictionary*)dict;
- (void)processAlbums:(id)responseObject;
- (void)updateAlbumAccounts:(int)albumID;
- (void)processAlbumID:(NSInteger)albumID accounts:(id)responseObject;
- (void)removeOldAlbums;
- (void)saveAndUpdate;
- (void)reload;
- (void)synchronize:(BOOL)modal;

@end
