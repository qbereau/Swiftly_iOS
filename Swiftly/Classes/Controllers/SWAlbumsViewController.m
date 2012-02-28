//
//  SWFirstViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbumsViewController.h"

@implementation SWAlbumsViewController

@synthesize operationQueue = _operationQueue;
@synthesize receivedAlbums = _receivedAlbums;
@synthesize sharedAlbums = _sharedAlbums;
@synthesize specialAlbums = _specialAlbums;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize reqOps = _reqOps;

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
    
    self.sharedAlbums   = [SWAlbum findUnlockedSharedAlbums];
    self.specialAlbums  = [SWAlbum findAllSpecialAlbums];
    
    [self synchronize:NO];    
}

- (void)updateAlbumAccounts:(int)albumID
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/albums/%d/accounts", albumID]
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        
                                        int iTotalPages = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-total-pages"] intValue];
                                        
                                        if (iTotalPages > 1)
                                        {   
                                            for (int i = 2; i <= iTotalPages; ++i)
                                            {
                                                ++self.reqOps;
                                                [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/albums/%d/accounts?page=%d", albumID, i]
                                                                         parameters:nil
                                                                            success:^(AFHTTPRequestOperation *op2, id respObj2) {
                                                                                
                                                                                [self processAlbumID:albumID accounts:respObj2];
                                                                                --self.reqOps;
                                                                                if (self.reqOps == 0)
                                                                                    [self saveAndUpdate];
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
                                            --self.reqOps;
                                            if (self.reqOps == 0)
                                                [self saveAndUpdate];
                                        }
                                    } 
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error: %@", [error description]);
                                    }
         ];
    });
}

- (void)processAlbumID:(NSInteger)albumID accounts:(id)responseObject
{
    SWAlbum* album = [SWAlbum findObjectWithServerID:albumID];
    if (album)   
    {
        [album setParticipants:nil];
        
        for (id o in responseObject)
        {
            SWPerson* p = [SWPerson findObjectWithServerID:[[o valueForKey:@"id"] intValue]];
            if (!p)
            {
                p = [SWPerson createEntity];
                [p updateWithObject:o];
            }
            
            [album addParticipantsObject:p];
        }
    }    
}

- (void)saveAndUpdate
{
    [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{    
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    });
    
    [self reload];    
}

- (void)reload
{
    self.sharedAlbums  = [SWAlbum findUnlockedSharedAlbums];
    self.specialAlbums = [SWAlbum findAllSpecialAlbums];
    [self.tableView reloadData];
}

- (void)synchronize:(BOOL)modal
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    if (modal)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = NSLocalizedString(@"loading", @"loading");
    }
    
    self.reqOps = 0;    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        self.receivedAlbums = [NSMutableArray array];
        
        [[SWAPIClient sharedClient] getPath:@"/albums" 
                                 parameters:nil 
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         if ([responseObject isKindOfClass:[NSArray class]])
                                         {
                                             if ([responseObject count] == 0)
                                                 [self saveAndUpdate];
                                             
                                             int iTotalPages = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-total-pages"] intValue];
                                             
                                             if (iTotalPages > 1)
                                             {   
                                                 // Update for first page
                                                 NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:responseObject, @"objects", 
                                                                         [NSNumber numberWithBool:NO], @"shouldRemoveOldAlbums",
                                                                         nil];
                                                 NSInvocationOperation* operation;
                                                 operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                                  selector:@selector(processAlbumsWithDict:)
                                                                                                    object:params];
                                                 [self.operationQueue addOperation:operation];                                                 
                                                 // -------
                                                 
                                                 __block int opReq = iTotalPages - 1;
                                                 for (int i = 2; i <= iTotalPages; ++i)
                                                 {
                                                     [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/albums?page=%d", i]
                                                                              parameters:nil
                                                                                 success:^(AFHTTPRequestOperation *op2, id respObj2) {
                                                                                     
                                                                                     // Update for first page
                                                                                     --opReq;
                                                                                     BOOL shouldCleanup = (opReq == 0) ? YES : NO;                                                                                     
                                                                                     
                                                                                     NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:respObj2, @"objects", 
                                                                                                             [NSNumber numberWithBool:shouldCleanup], @"shouldRemoveOldAlbums",
                                                                                                             nil];
                                                                                     NSInvocationOperation* operation;
                                                                                     operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                                                                      selector:@selector(processAlbumsWithDict:)
                                                                                                                                        object:params];
                                                                                     [self.operationQueue addOperation:operation];
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
                                                 NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:  responseObject, @"objects", 
                                                                         [NSNumber numberWithBool:YES], @"shouldRemoveOldAlbums",
                                                                         nil];
                                                 NSInvocationOperation* operation;
                                                 operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                                  selector:@selector(processAlbumsWithDict:)
                                                                                                    object:params];
                                                 [self.operationQueue addOperation:operation];                                                 
                                             }
                                         }
                                     }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                            
                                            UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                                            [av show];                                            
                                        });
                                    }
         ];   
    });
}

- (void)processAlbumsWithDict:(NSDictionary *)dict
{
    id responseObject   = [dict objectForKey:@"objects"];
    BOOL shouldCleanup  = [[dict objectForKey:@"shouldRemoveOldAlbums"] boolValue];
    
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setParentContext:[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext]];
    
    [context performBlock:^{
        
        for (id obj in responseObject)
        {
            SWAlbum* albumObj = [SWAlbum findObjectWithServerID:[[obj valueForKey:@"id"] intValue] inContext:context];
            
            if (!albumObj)
            {
                albumObj = [SWAlbum createEntityInContext:context];
                albumObj.isLocked = NO;                                                     
            }
            
            [albumObj updateWithObject:obj];
            
            [self.receivedAlbums addObject:albumObj];
            
            ++self.reqOps;
            [self updateAlbumAccounts:albumObj.serverID];
        }        
        
        if (shouldCleanup)
        {
            for (SWAlbum* a in [SWAlbum findAllObjectsInContext:context])
            {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"serverID == %d", a.serverID];
                NSArray* rez = [self.receivedAlbums filteredArrayUsingPredicate:predicate];
                if (rez.count == 0)
                {
                    [a deleteEntityInContext:context];
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(contextDidSave:) 
                                                     name:NSManagedObjectContextDidSaveNotification 
                                                   object:context];
        
        [context save:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:NSManagedObjectContextDidSaveNotification 
                                                      object:context];        
        
    }];     
}

- (void)contextDidSave:(NSNotification*)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextDidSave:)
                               withObject:notif
                            waitUntilDone:NO];
        return;
    }
    
    [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] mergeChangesFromContextDidSaveNotification:notif];
    
    [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
    
    [self reload];
}

- (void)processAlbums:(id)responseObject
{
    for (id obj in responseObject)
    {
        SWAlbum* albumObj = [SWAlbum findObjectWithServerID:[[obj valueForKey:@"id"] intValue]];
        
        if (!albumObj)
        {
            albumObj = [SWAlbum createEntity];
            albumObj.isLocked = NO;                                                     
        }
        
        [albumObj updateWithObject:obj];
        
        [self.receivedAlbums addObject:albumObj];
        
        ++self.reqOps;
        [self updateAlbumAccounts:albumObj.serverID];
    }
}



- (void)removeOldAlbums
{
    for (SWAlbum* a in [SWAlbum findAllObjects])
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"serverID == %d", a.serverID];
        NSArray* rez = [self.receivedAlbums filteredArrayUsingPredicate:predicate];
        if (rez.count == 0)
        {
            [a deleteEntity];
        }
    }
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
    
    self.sharedAlbums   = [SWAlbum findUnlockedSharedAlbums];
    self.specialAlbums  = [SWAlbum findAllSpecialAlbums];    
    [self.tableView reloadData];
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
        albumThumbnailsVC.allowAlbumEdition = YES;
        albumThumbnailsVC.selectedAlbum = selectedAlbum;
    }
    else if ([[segue identifier] isEqualToString:@"SelectedOtherAlbum"])
    {
        NSIndexPath* idxPath = [self.tableView indexPathForSelectedRow];
        SWAlbum* selectedAlbum = [self.specialAlbums objectAtIndex:idxPath.row];
        SWAlbumThumbnailsViewController* albumThumbnailsVC = (SWAlbumThumbnailsViewController*)segue.destinationViewController;
        albumThumbnailsVC.allowAlbumEdition = NO;
        albumThumbnailsVC.selectedAlbum = selectedAlbum;        
    }
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [self.sharedAlbums count];
    return [self.specialAlbums count];
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* v = (UILabel*)[tableView tableHeaderView];
    
    if (section == 0)
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"albums_shared_albums_header", @"shared albums")];
    else
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"albums_other_albums_header", @"other albums")];
    
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWTableViewCell* cell;
    SWAlbum* album;
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellAlbum"];
        album = [self.sharedAlbums objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellSharedAlbum"];
        album = [self.specialAlbums objectAtIndex:indexPath.row];
    }
    
    cell.title.text = album.name;
    cell.subtitle.text = [album participants_str];
    cell.imageView.image = album.thumbnail;    
    
    return cell;
}

#pragma mark - JSLockScreenViewController
- (void)lockScreenDidUnlock:(JSLockScreenViewController *)lockScreen
{
    self.sharedAlbums   = [SWAlbum findAllSharedAlbums];
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
