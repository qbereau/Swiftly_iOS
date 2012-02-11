//
//  SWFirstViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbumsViewController.h"

@implementation SWAlbumsViewController

@synthesize albums = _albums;

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
    
    SWAlbum* album1 = [[SWAlbum alloc] init];
    album1.name = @"Amsterdam (49)";
    album1.thumbnail = [UIImage imageNamed:@"pic1.png"];
    
    SWAlbum* album2 = [[SWAlbum alloc] init];
    album2.name = @"ISE 2012 (4)";
    album2.thumbnail = [UIImage imageNamed:@"pic2.png"];
    
    self.albums = [NSMutableArray arrayWithObjects:album1, album2, nil];
}

- (void)unlockAlbums:(UIButton*)sender
{
    SWPromptView* pv = [[SWPromptView alloc] initWithTitle:NSLocalizedString(@"enter_album_lock", @"enter your album lock") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"cancel") okButtonTitle:NSLocalizedString(@"ok", @"ok")];
    [pv show];
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
        if (idxPath.section == 0)
        {
            // Shared Album only here...
            SWAlbum* selectedAlbum = [self.albums objectAtIndex:idxPath.row];
            SWAlbumThumbnailsViewController* albumThumbnailsVC = (SWAlbumThumbnailsViewController*)segue.destinationViewController;
            albumThumbnailsVC.allowAlbumEdition = YES;
            albumThumbnailsVC.selectedAlbum = selectedAlbum;
        }
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
        return [self.albums count];
    return 2;
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
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellAlbum"];

        SWAlbum* album = [self.albums objectAtIndex:indexPath.row];
        cell.title.text = album.name;
        cell.subtitle.text = @"Quentin Bereau, John Doe, Steve Jobs, Steve Wozniak";
        cell.imageView.image = album.thumbnail;
    }
    else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellSharedAlbum"];
        cell.imageView.image = [UIImage imageNamed:@"pic3.png"]; // hack, should come from server
        
        if (indexPath.row == 0)
            cell.title.text = NSLocalizedString(@"albums_quick_share", @"quick share");
        else if (indexPath.row == 1)
            cell.title.text = @"My Medias";
    }
    
    return cell;
}

#pragma mark - SWPrompt
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        NSString *entered = [(SWPromptView *)alertView enteredText];
        NSLog(@"%@", [NSString stringWithFormat:@"You typed: %@", entered]);
    }
}

@end
