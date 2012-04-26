//
//  SWFirstViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbumsViewController.h"

@implementation SWAlbumsViewController

@synthesize arrAlbumsID = _arrAlbumsID;
@synthesize operationQueue = _operationQueue;
@synthesize receivedAlbums = _receivedAlbums;
@synthesize sharedAlbums = _sharedAlbums;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize reqOps = _reqOps;
@synthesize reqAlbumsOps = _reqAlbumsOps;
@synthesize shouldResync = _shouldResync;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.operationQueue == nil)
        self.operationQueue = [[NSOperationQueue alloc] init];    

    UIBarButtonItem* btnUnlock = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"lock"] style:UIBarButtonItemStylePlain target:self action:@selector(unlockAlbums:)];
    self.navigationItem.leftBarButtonItem = btnUnlock;
    
    self.navigationItem.title = NSLocalizedString(@"albums_title", @"Albums");
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self reload];
    
    if ([SWAPIClient isNetworkReachable])
        [self synchronize];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNetworkStatus:)
                                                 name:@"SWReceivedNetworkStatus"
                                               object:nil
     ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadMediaDone:)
                                                 name:@"SWUploadMediaDone"
                                               object:nil
     ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNewMedias:)
                                                 name:@"SWReceivedNewMedias"
                                               object:nil
     ];    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshedAB:)
                                                 name:@"SWABProcessDone"
                                               object:nil
     ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshedAB:)
                                                 name:@"SWABProcessFailed"
                                               object:nil
     ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshedGroups:)
                                                 name:@"SWGroupSyncDone"
                                               object:nil
     ];
}

- (void)receivedNetworkStatus:(NSNotification*)notification
{
    if ([SWAPIClient isNetworkReachable])
        [self synchronize];
}

- (void)refreshedAB:(NSNotification*)notification
{
    [SWGroupListViewController synchronize];
}

- (void)refreshedGroups:(NSNotification*)notification
{
    [MBProgressHUD hideHUDForView:self.parentViewController.view animated:YES];
    [self reload];
}

- (void)uploadMediaDone:(NSNotification*)notification
{
    self.shouldResync = YES;
}

- (void)receivedNewMedias:(NSNotification*)notification
{
    [self synchronize];
}

- (void)updateAlbumAccounts:(SWAlbum*)album
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int albumID = album.serverID;
        [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/nodes/%d/users", album.serverID]
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        
                                        int iTotalPages = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-total-pages"] intValue];
                                        
                                        if (iTotalPages > 1)
                                        {   
                                            [self processAlbumID:albumID accounts:responseObject];
                                            
                                            for (int i = 2; i <= iTotalPages; ++i)
                                            {
                                                @synchronized(self) {
                                                    ++self.reqOps;
                                                }
                                                [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/nodes/%d/users?page=%d", album.serverID, i]
                                                                         parameters:nil
                                                                            success:^(AFHTTPRequestOperation *op2, id respObj2) {
                                                                                
                                                                                [self processAlbumID:albumID accounts:respObj2];
                                                                            }
                                                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                NSLog(@"error");
                                                                            }
                                                 ];
                                            }
                                        }
                                        else
                                        {
                                            [self processAlbumID:albumID accounts:responseObject];
                                        }
                                    } 
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error: %@", [error description]);
                                    }
         ];
    });
}

- (void)processAlbumID:(int)albumID accounts:(id)responseObject
{
    NSLog(@"===> processAlbumID");    
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        
        SWAlbum* a = [SWAlbum MR_findFirstByAttribute:@"serverID" withValue:[NSNumber numberWithInt:albumID] inContext:localContext];
        [a setParticipants:nil];
        
        for (id o in responseObject)
        {
            SWPerson* p = [SWPerson MR_findFirstByAttribute:@"serverID" withValue:[o valueForKey:@"id"] inContext:localContext];
            if (!p)
            {
                p = [SWPerson MR_createInContext:localContext];
                [p updateWithObject:o inContext:localContext];
            }
            [a addParticipantsObject:p];
        }
    } completion:^{
        @synchronized(self) {
            --self.reqOps;
        }
        
        if (self.reqOps == 0)
        {
            [self saveAndUpdate];
        }
    }];
}

- (void)saveAndUpdate
{
    self.shouldResync = NO;    
    
    [self removeOldAlbums];
}

- (void)reload
{
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        
    } completion:^{
        self.sharedAlbums  = [SWAlbum findUnlockedSharedAlbums:[NSManagedObjectContext MR_contextForCurrentThread]];
        [self.tableView reloadData];
    }];
}

- (void)synchronize
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    @synchronized(self) {
        self.reqOps                 = 0;
        self.arrAlbumsID            = [NSMutableArray array];
    }
    
    NSArray* albums = [SWAlbum MR_findAll];
    if ([albums count] == 0)
    {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
        hud.labelText = NSLocalizedString(@"loading", @"loading");
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/nodes/%d/children", [SWAppDelegate serviceID]]
                                 parameters:nil 
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         if ([responseObject isKindOfClass:[NSArray class]])
                                         {
                                             int iTotalPages = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-total-pages"] intValue];
                                             
                                             if (iTotalPages > 1)
                                             {   
                                                 // Update for first page
                                                 _shouldCleanup = NO;
                                                 NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:responseObject, @"objects", 
                                                                         nil];
                                                 [self processAlbumsWithDict:params];
                                                 // -------

                                                 @synchronized(self) {
                                                     self.reqAlbumsOps = iTotalPages - 1;
                                                 }
                                                 for (int i = 2; i <= iTotalPages; ++i)
                                                 {
                                                     [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/nodes/%d/children?page=%d", [SWAppDelegate serviceID], i]
                                                                              parameters:nil
                                                                                 success:^(AFHTTPRequestOperation *op2, id respObj2) {
                                                                                     
                                                                                     // Update for first page
                                                                                     @synchronized(self) {
                                                                                         --self.reqAlbumsOps;
                                                                                         _shouldCleanup = (self.reqAlbumsOps == 0) ? YES : NO;
                                                                                     }
                                                                                     
                                                                                     NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:respObj2, @"objects", nil];
                                                                                     [self processAlbumsWithDict:params];
                                                                                     // ------
                                                                                 }
                                                                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                     NSLog(@"error");
                                                                                 }
                                                      ];
                                                 }
                                             }
                                             else
                                             {
                                                 _shouldCleanup = YES;
                                                 
                                                 NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:  responseObject, @"objects", 
                                                                         nil];
                                                 [self processAlbumsWithDict:params];
                                             }
                                         }
                                     }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                                            [av show];
                                        });
                                    }
         ];   
    });
}

- (void)processAlbumsWithDict:(NSDictionary *)dict
{
    NSLog(@"===> processAlbumsWithDict");
    //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        id responseObject   = [dict objectForKey:@"objects"];
    
        if (!responseObject || [responseObject count] == 0)
        {
            [self saveAndUpdate];
        }
        else 
        {
            [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
                for (id obj in responseObject)
                {
                    SWAlbum* localAlbum = [SWAlbum MR_findFirstByAttribute:@"serverID" withValue:[obj valueForKey:@"id"] inContext:localContext];
                    
                    if (!localAlbum)
                    {
                        localAlbum = [SWAlbum MR_createInContext:localContext];
                        localAlbum.updated = YES;
                        localAlbum.isLocked = NO;
                    }
                    [localAlbum updateWithObject:obj];
                    
                    @synchronized(self) {
                        ++self.reqOps;
                    }
                }
            } completion:^{
                for (id obj in responseObject)
                {
                    SWAlbum* album = [SWAlbum MR_findFirstByAttribute:@"serverID" withValue:[obj valueForKey:@"id"]];
                    
                    if (!album.thumbnail || album.updated)
                    {
                        SDWebImageDownloader* downloader = [SDWebImageDownloader downloaderWithURL:[NSURL URLWithString:album.thumbnailURL] delegate:self];
                        downloader.userInfo = [NSDictionary dictionaryWithObject:album forKey:@"album"];
                    }
                    
                    @synchronized(self){
                        [self.arrAlbumsID addObject:[NSNumber numberWithInt:album.serverID]];
                    }
                    [self updateAlbumAccounts:album];
                }
            }];            
        }
    //});
}

- (void)imageDownloader:(SDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image
{
    NSDictionary* dict = [downloader userInfo];
    SWAlbum* album = [dict objectForKey:@"album"];
    
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        SWAlbum* localAlbum = [SWAlbum MR_findFirstByAttribute:@"serverID" withValue:[NSNumber numberWithInt:album.serverID] inContext:localContext];
        localAlbum.thumbnail = image;
    }];
}

- (void)removeOldAlbums
{
    if ([self.arrAlbumsID count] > 0)
    {
        [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"NOT serverID IN %@", self.arrAlbumsID];
            [SWAlbum MR_deleteAllMatchingPredicate:predicate inContext:localContext];            
        } completion:^{
            [self checkAndCreateQuickShareAlbum];
        }];
    }
    else
    {
        [self checkAndCreateQuickShareAlbum];
    }
}

- (void)checkAndCreateQuickShareAlbum
{
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        
    } completion:^{
        SWAlbum* qsAlbum = [SWAlbum findQuickShareAlbum:[NSManagedObjectContext MR_contextForCurrentThread]];
        if (!qsAlbum)
        {
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:  @"folder", @"type",
                                                                              @"QuickShare", @"name",
                                                                              [NSNumber numberWithInt:[SWAppDelegate serviceID]], @"parent_id",
                                                                              @"quickshare", @"tags",
                                  nil];
            [[SWAPIClient sharedClient] postPath:@"/nodes"
                                      parameters:dict 
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             
                                             [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
                                                 
                                                 SWAlbum* localAlbum = [SWAlbum MR_createInContext:localContext];
                                                 localAlbum.updated = YES;
                                                 localAlbum.isLocked = NO;
                                                 [localAlbum updateWithObject:responseObject];
                                                 
                                             } completion:^{
                                                 [SWPeopleListViewController synchronize];                                                
                                             }];
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [SWPeopleListViewController synchronize];
                                         }
             ];
        }
        else 
        {
            [SWPeopleListViewController synchronize];        
        }        
    }];
}

- (void)unlockAlbums:(UIButton*)sender
{
    _lockScreenViewController = [[JSLockScreenViewController alloc] initWithDelegate:self];
    
    UIWindow *window = (UIWindow*)[[[UIApplication sharedApplication] delegate] window];
    [_lockScreenViewController showInWindow:window];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SWResetAlbumsBadgeValue" object:nil];
    
    if (self.shouldResync)
    {
        [self synchronize];
        self.shouldResync = NO;
    }
    
    [self reload];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SelectedSharedAlbum"])
    {
        NSIndexPath* idxPath = [self.tableView indexPathForSelectedRow];
        SWAlbum* selectedAlbum = [self.sharedAlbums objectAtIndex:idxPath.row];
        SWAlbumThumbnailsViewController* albumThumbnailsVC = (SWAlbumThumbnailsViewController*)segue.destinationViewController;
        albumThumbnailsVC.allowAlbumEdition = !selectedAlbum.isQuickShareAlbum;
        albumThumbnailsVC.selectedAlbum = selectedAlbum;
        
        [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
            selectedAlbum.updated = NO;
        }];
    }
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sharedAlbums count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CellAlbum"];
    SWAlbum* album = [self.sharedAlbums objectAtIndex:indexPath.row];
    
    cell.title.text = album.name;
    cell.subtitle.text = [album participants_str];
    cell.imageView.image = [album customThumbnail];
    
    return cell;
}

#pragma mark - JSLockScreenViewController
- (void)lockScreenDidUnlock:(JSLockScreenViewController *)lockScreen
{
    self.sharedAlbums   = [SWAlbum MR_findAll];
    [self.tableView reloadData];
}

- (void)lockScreenFailedUnlock:(JSLockScreenViewController *)lockScreen
{

}

- (void)lockScreenDidCancel:(JSLockScreenViewController *)lockScreen
{

}

- (void)lockScreenDidDismiss:(JSLockScreenViewController *)lockScreen
{

}

@end
