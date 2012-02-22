//
//  SWFirstViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbumsViewController.h"

@implementation SWAlbumsViewController

@synthesize sharedAlbums = _sharedAlbums;
@synthesize specialAlbums = _specialAlbums;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize updateAlbumAccounts = _updateAlbumAccounts;
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
    
    UIBarButtonItem* btnUnlock = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"lock"] style:UIBarButtonItemStylePlain target:self action:@selector(unlockAlbums:)];
    self.navigationItem.leftBarButtonItem = btnUnlock;
    
    self.navigationItem.title = NSLocalizedString(@"albums_title", @"Albums");
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.sharedAlbums   = [SWAlbum findUnlockedSharedAlbums];
    self.specialAlbums  = [SWAlbum findAllSpecialAlbums];
    
    __block SWAlbumsViewController* selfBlock = self;
    self.updateAlbumAccounts = ^(int album_id) {
        // Update Accounts
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/albums/%d/accounts", album_id]
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            NSLog(@"[SWAlbumsViewController#updateAlbumAccount] Needs to use pagination....");
                                            SWAlbum* album = [SWAlbum findObjectWithServerID:album_id];
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
                                            
                                            --selfBlock.reqOps;
                                            if (selfBlock.reqOps == 0)
                                                [selfBlock saveAndUpdate];
                                        } 
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"Error: %@", [error description]);
                                        }
             ];
        });    
    };
    
    [self synchronize:NO];    
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
        [[SWAPIClient sharedClient] getPath:@"/albums" 
                                 parameters:nil 
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         if ([responseObject isKindOfClass:[NSArray class]])
                                         {
                                             if ([responseObject count] == 0)
                                                 [self saveAndUpdate];
                                             
                                             NSMutableArray* receivedAlbums = [NSMutableArray array];
                                             for (id obj in responseObject)
                                             {
                                                 SWAlbum* albumObj = [SWAlbum findObjectWithServerID:[[obj valueForKey:@"id"] intValue]];
                                                 
                                                 if (!albumObj)
                                                 {
                                                     albumObj = [SWAlbum createEntity];
                                                     albumObj.isLocked = NO;                                                     
                                                 }
                                                 
                                                 [albumObj updateWithObject:obj];
                                                 
                                                 [receivedAlbums addObject:albumObj];
                                                 
                                                 ++self.reqOps;
                                                 self.updateAlbumAccounts(albumObj.serverID);
                                             }
                                             
                                             // Remove old albums
                                             for (SWAlbum* a in [SWAlbum findAllObjects])
                                             {
                                                 NSPredicate* predicate = [NSPredicate predicateWithFormat:@"serverID == %d", a.serverID];
                                                 NSArray* rez = [receivedAlbums filteredArrayUsingPredicate:predicate];
                                                 if (rez.count == 0)
                                                 {
                                                     [a deleteEntity];
                                                 }
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
