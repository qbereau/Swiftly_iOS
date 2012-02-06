//
//  SWAlbumEditViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbumEditViewController.h"


@implementation SWAlbumEditViewController

@synthesize people = _people;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.dataSource = self;
    
    self.people = [NSArray arrayWithObjects:@"Steve Jobs", @"Bill Gates", @"Woz", nil];
    
    self.title = NSLocalizedString(@"edit_album", @"edit album");
}

- (void)done:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* v = (UILabel*)[super tableView:tableView viewForHeaderInSection:section];
    v.backgroundColor = [UIColor clearColor];
    
    switch (section)
    {
        case 0:
            v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"album_name", @"album name")];
            break;
        case 1:
            v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"linked_people", @"people linked to this album")];
            break;
        case 2:
            v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"album_settings", @"album settings")];            
            break;
        case 3:
            v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"media_settings", @"media settings")];
            break;
        case 4:
            v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"security", @"security")];
            break;
        case 5:
            v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"settings", @"settings")];
            break;
    }
    
    return v;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78.0;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
        case 1:
            return [self.people count] + 1;
        case 2:
            return 2;
        case 3:
            return 1;
        case 4:
            return 1;
        case 5:
            return 3; // should be 3 if owner, 2 otherwise ("delete album" if owner)
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StaticCellIdentifier = @"StaticGroupedCell";
    static NSString *InputCellIdentifier = @"InputGroupedCell";
    
    SWTableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:InputCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:InputCellIdentifier];
            cell.isGrouped = YES;
            
            UITextField* inputTitle;
            for (UIView* v in cell.contentView.subviews)
            {
                if ([v isKindOfClass:[UITextField class]])
                {
                    inputTitle = (UITextField*)v;
                    break;
                }
            }
            if (!inputTitle)
            {
                inputTitle = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 200, 35)];
                inputTitle.delegate = self;
                [cell.contentView addSubview:inputTitle];
            }
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:StaticCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:StaticCellIdentifier];
            cell.isGrouped = YES;
        }
    }
    
    // Configure the cell...
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.isLink = NO;
    
    switch (indexPath.section)
    {
        case 0:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.isSingle = YES;
            break;
        case 1:
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.isMiddle = YES;
            
            if (indexPath.row == 0 && [self.people count] == 0)
                cell.isSingle = YES;
            else if (indexPath.row == 0 && [self.people count] > 0)
                cell.isTop = YES;
            
            if (indexPath.row < [self.people count])
                cell.textLabel.text = [self.people objectAtIndex:indexPath.row];
            else
            {
                if ([self.people count] > 0)
                    cell.isBottom = YES;

                cell.isLink = YES;
                cell.textLabel.text = NSLocalizedString(@"add_remove_people", @"Add / Remove people");
                [cell.textLabel sizeToFit];
            }
            
            break;
        case 2:
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            if (indexPath.row == 0)
            {
                cell.isTop = YES;
                cell.textLabel.text = NSLocalizedString(@"album_settings_allow_share_people", @"allow people to share additional persons");
            }
            else if (indexPath.row == 1)
            {
                cell.isBottom = YES;
                cell.textLabel.text = NSLocalizedString(@"album_settings_allow_add_files", @"allow people to add their own files");
            }
            break;
        case 3:
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.isSingle = YES;
            cell.textLabel.text = NSLocalizedString(@"media_settings_save_files", @"allow people to save and forward my files");
            break;
        case 4:
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.isSingle = YES;
            cell.textLabel.text = NSLocalizedString(@"album_settings_lock", @"lock this album");
            cell.detailTextLabel.text = NSLocalizedString(@"album_settings_lock_description", @"you can setup a passcode on the settings page. this will only lock this album for your account.");
            break;
        case 5:
            cell.isLink = YES;
            switch (indexPath.row)
            {
                case 0:
                    // Delete my medias
                    cell.isTop = YES;
                    cell.textLabel.text = NSLocalizedString(@"delete_my_medias", @"delete my files");
                    break;
                case 1:
                    // Unlink from album
                    cell.isMiddle = YES; // Or isBottom if not owner
                    cell.textLabel.text = NSLocalizedString(@"unlink_from_album", @"unlink myself from this album");
                    break;
                case 2:
                    // Delete album
                    cell.isBottom = YES;
                    cell.textLabel.text = NSLocalizedString(@"delete_album", @"delete this album");
                    break;
            }
            
            [cell.textLabel sizeToFit];
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Alert user
    RIButtonItem *btnYES = [RIButtonItem item];
    btnYES.label = [NSLocalizedString(@"yes", @"yes") uppercaseString];
    
    RIButtonItem *btnNO = [RIButtonItem item];
    btnNO.label = [NSLocalizedString(@"no", @"no") uppercaseString];
    
    NSString* msg;
    
    switch (indexPath.section)
    {
        case 5:
            if (indexPath.row == 0)
            {
                msg = NSLocalizedString(@"delete_my_medias_warning", @"");
                btnYES.action = ^{
                    NSLog(@"delete my files");
                };
            }
            else if (indexPath.row == 1)
            {
                msg = NSLocalizedString(@"unlink_from_album_warning", @"");
                btnYES.action = ^{
                    NSLog(@"unlink myself from this album");
                };
            }
            else if (indexPath.row == 2)
            {
                msg = NSLocalizedString(@"delete_album_warning", @"");
                btnYES.action = ^{
                    NSLog(@"delete this album");
                };
            }
            break;
    }
    
    if (msg)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirmation", @"confirmation")
                                                        message:msg
                                               cancelButtonItem:btnNO
                                               otherButtonItems:btnYES, nil];
        [alert show];
    }
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
