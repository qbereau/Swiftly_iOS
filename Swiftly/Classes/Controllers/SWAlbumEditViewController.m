//
//  SWAlbumEditViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbumEditViewController.h"

@interface SWAlbumEditViewController (Private)

- (void)setupSectionParticipants:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
- (void)setupSectionAlbumSettings:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
- (void)setupSectionMediaSettings:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
- (void)setupSectionSecurity:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
- (void)setupSectionSettings:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath;


- (void)handleSectionParticipantsWithIndexPath:(NSIndexPath*)indexPath;
- (void)handleSectionAlbumSettingsWithIndexPath:(NSIndexPath*)indexPath;
- (void)handleSectionMediaSettingsWithIndexPath:(NSIndexPath*)indexPath;
- (void)handleSectionSecurityWithIndexPath:(NSIndexPath*)indexPath;
- (void)handleSectionSettingsWithIndexPath:(NSIndexPath*)indexPath;

@end

@implementation SWAlbumEditViewController

@synthesize album = _album;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)];
    
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.dataSource = self;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.title = NSLocalizedString(@"edit_album", @"edit album");
    
    // Data
    SWPerson* qb = [SWPerson new];
    qb.firstName = @"Quentin";
    qb.lastName = @"Bereau";
    qb.phoneNumber = @"079 629 41 79";
    
    SWPerson* pb = [SWPerson new];
    pb.firstName = @"Patrick";
    pb.lastName = @"Bereau";
    pb.phoneNumber = @"+41 78 842 41 86";
    
    SWPerson* tb = [SWPerson new];
    tb.firstName = @"Tristan";
    tb.lastName = @"Bereau";
    tb.phoneNumber = @"+41 78 744 51 47";
    
    SWPerson* pc = [SWPerson new];
    pc.firstName = @"Paul";
    pc.lastName = @"Carneiro";
    pc.phoneNumber = @"+41 79 439 10 72";        
    
    self.album = [SWAlbum new];
    self.album.name = @"test";
    self.album.participants = [NSArray arrayWithObjects:qb, pb, tb, pc, nil];
}

- (void)done:(id)sender
{
    NSLog(@"[SWAlbumEditViewController#done] Sync with server");    
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
    if (self.album.isOwner)
        return 6;
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* v = [[UILabel alloc] initWithFrame:CGRectZero];
    v.textColor = [UIColor whiteColor];
    v.font = [UIFont boldSystemFontOfSize:14.0];
    v.backgroundColor = [UIColor clearColor];
    
    if (self.album.isOwner)
    {
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
    }
    else
    {
        switch (section)
        {
            case 0:
                v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"album_name", @"album name")];
                break;
            case 1:
                v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"linked_people", @"people linked to this album")];
                break;
            case 2:
                v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"media_settings", @"media settings")];                
                break;
            case 3:
                v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"security", @"security")];                
                break;
            case 4:
                v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"settings", @"settings")];
                break;
        }
    }
    
    return v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.album.isOwner)
    {
        switch (section)
        {
            case 0:
                return 1;
            case 1:
                return [self.album.participants count] + 1;
            case 2:
                return 2;
            case 3:
                return 1;
            case 4:
                return 1;
            case 5:
                return 3;
        }        
    }
    else
    {
        switch (section)
        {
            case 0:
                return 1;
            case 1:
                return [self.album.participants count];
            case 2:
                return 1;
            case 3:
                return 1;
            case 4:
                return 2;
        }            
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
                inputTitle = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, cell.frame.size.width - 35, cell.frame.size.height)];
                inputTitle.placeholder = NSLocalizedString(@"album_name", @"album's name");
                inputTitle.delegate = self;
                [cell.contentView addSubview:inputTitle];
            }
            
            inputTitle.text = self.album.name;            
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:StaticCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:StaticCellIdentifier];
        }
    }
    
    // Configure the cell...
    cell.isGrouped = YES;
    cell.title.text = @"";
    cell.subtitle.text = @"";
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = nil;
    cell.isLink = NO;
    cell.isDestructive = NO;
    
    if (self.album.isOwner)
    {
        switch (indexPath.section)
        {
            case 1:
                [self setupSectionParticipants:cell indexPath:indexPath];
                break;
            case 2:
                [self setupSectionAlbumSettings:cell indexPath:indexPath];
                break;
            case 3:
                [self setupSectionMediaSettings:cell indexPath:indexPath];
                break;
            case 4:
                [self setupSectionSecurity:cell indexPath:indexPath];
                break;
            case 5:
                [self setupSectionSettings:cell indexPath:indexPath];
                break;
        }
    }
    else
    {
        switch (indexPath.section)
        {
            case 1:
                [self setupSectionParticipants:cell indexPath:indexPath];
                break;
            case 2:
                [self setupSectionMediaSettings:cell indexPath:indexPath];
                break;
            case 3:
                [self setupSectionSecurity:cell indexPath:indexPath];
                break;
            case 4:
                [self setupSectionSettings:cell indexPath:indexPath];
                break;
        }        
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.album.isOwner)
    {
        switch (indexPath.section)
        {
            case 1:
                [self handleSectionParticipantsWithIndexPath:indexPath];
                break;
            case 2:
                [self handleSectionAlbumSettingsWithIndexPath:indexPath];
                break;
            case 3:
                [self handleSectionMediaSettingsWithIndexPath:indexPath];
                break;
            case 4:
                [self handleSectionSecurityWithIndexPath:indexPath];
                break;
            case 5:
                [self handleSectionSettingsWithIndexPath:indexPath];
                break;
        }
    }
    else
    {
        switch (indexPath.section)
        {
            case 1:
                [self handleSectionParticipantsWithIndexPath:indexPath];
                break;
            case 2:
                [self handleSectionMediaSettingsWithIndexPath:indexPath];
                break;
            case 3:
                [self handleSectionSecurityWithIndexPath:indexPath];
                break;
            case 4:
                [self handleSectionSettingsWithIndexPath:indexPath];
                break;
        }        
    }
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - SWPeopleListViewControllerDelegate
- (void)peopleListViewControllerDidSelectContacts:(NSArray*)arr
{
    self.album.participants = arr;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:NO];
}

@end

@implementation SWAlbumEditViewController (Private)

- (void)setupSectionParticipants:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row < [self.album.participants count])
    {
        SWPerson* p = [self.album.participants objectAtIndex:indexPath.row];
        cell.title.text = p.name;
        cell.imageView.image = p.thumbnail;
    }
    else
    {
        cell.isLink = YES;
        cell.title.text = NSLocalizedString(@"add_remove_people", @"Add / Remove people");
    }
}

- (void)setupSectionAlbumSettings:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0)
    {
        cell.title.text = NSLocalizedString(@"album_settings_allow_share_people", @"allow people to share additional persons");
        
        cell.accessoryType = self.album.canEditPeople ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone; 
    }
    else if (indexPath.row == 1)
    {
        cell.title.text = NSLocalizedString(@"album_settings_allow_add_files", @"allow people to add their own files");
        
        cell.accessoryType = self.album.canEditMedias ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;  
    }
}

- (void)setupSectionMediaSettings:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    cell.title.text = NSLocalizedString(@"media_settings_save_files", @"allow people to save and forward my files");
    
    cell.accessoryType = self.album.canExportMedias ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;    
}

- (void)setupSectionSecurity:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    cell.title.text = NSLocalizedString(@"album_settings_lock", @"lock this album");
    cell.subtitle.text = NSLocalizedString(@"album_settings_lock_description", @"you can setup a passcode on the settings page. this will only lock this album for your account.");
    
    cell.accessoryType = self.album.isLocked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;        
}

- (void)setupSectionSettings:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    cell.isLink = YES;
    cell.isDestructive = YES;
    switch (indexPath.row)
    {
        case 0:
            // Delete my medias
            cell.title.text = NSLocalizedString(@"delete_my_medias", @"delete my files");
            break;
        case 1:
            // Unlink from album
            cell.title.text = NSLocalizedString(@"unlink_from_album", @"unlink myself from this album");
            break;
        case 2:
            // Delete album
            cell.title.text = NSLocalizedString(@"delete_album", @"delete this album");
            break;
    }    
}

- (void)handleSectionParticipantsWithIndexPath:(NSIndexPath*)indexPath
{
    if (self.album.isOwner)
    {
        SWPeopleListViewController* plvc = [SWPeopleListViewController new];
        plvc.mode = PEOPLE_LIST_MULTI_SELECTION_MODE;
        plvc.delegate = self;
        plvc.selectedContacts = [NSMutableArray arrayWithArray:self.album.participants];
        [self presentViewController:plvc animated:YES completion: nil];
    }    
}

- (void)handleSectionAlbumSettingsWithIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0)
        self.album.canEditPeople = !self.album.canEditPeople;
    else
        self.album.canEditMedias = !self.album.canEditMedias;            
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:YES];
}

- (void)handleSectionMediaSettingsWithIndexPath:(NSIndexPath*)indexPath
{
    self.album.canExportMedias = !self.album.canExportMedias;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:YES];       
}

- (void)handleSectionSecurityWithIndexPath:(NSIndexPath*)indexPath
{
    self.album.isLocked = !self.album.isLocked;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:YES];
}

- (void)handleSectionSettingsWithIndexPath:(NSIndexPath*)indexPath
{
    // Alert user
    RIButtonItem *btnYES = [RIButtonItem item];
    btnYES.label = [NSLocalizedString(@"yes", @"yes") uppercaseString];
    
    RIButtonItem *btnNO = [RIButtonItem item];
    btnNO.label = [NSLocalizedString(@"no", @"no") uppercaseString];
    
    NSString* msg;
    
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
    
    if (msg)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirmation", @"confirmation")
                                                        message:msg
                                               cancelButtonItem:btnNO
                                               otherButtonItems:btnYES, nil];
        [alert show];
    }    
}

@end