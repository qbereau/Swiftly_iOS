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
    return 1;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* v = (UILabel*)[super tableView:tableView viewForHeaderInSection:section];
    
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
    UITableViewCell* cell;
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellAlbum"];

        SWAlbum* album = [self.albums objectAtIndex:indexPath.row];
        cell.textLabel.text = album.name;
        cell.detailTextLabel.text = @"Quentin Bereau, John Doe, Steve Jobs, Steve Wozniak";
        cell.imageView.image = album.thumbnail;
    }
    else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellSharedAlbum"];
        cell.textLabel.text = NSLocalizedString(@"albums_quick_share", @"quick share");
        cell.imageView.image = [UIImage imageNamed:@"pic3.png"]; // hack, should come from server
    }
    
    return cell;
}

@end
