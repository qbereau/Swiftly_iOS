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
- (void)setupSectionChooseAlbumToLink:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
- (void)setupSectionShareToPeople:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath;


- (void)handleSectionParticipantsWithIndexPath:(NSIndexPath*)indexPath;
- (void)handleSectionAlbumSettingsWithIndexPath:(NSIndexPath*)indexPath;
- (void)handleSectionMediaSettingsWithIndexPath:(NSIndexPath*)indexPath;
- (void)handleSectionSecurityWithIndexPath:(NSIndexPath*)indexPath;
- (void)handleSectionSettingsWithIndexPath:(NSIndexPath*)indexPath;
- (void)handleSectionChooseAlbumToLinkWithIndexPath:(NSIndexPath*)indexPath;
- (void)handleSectionShareToPeopleWithIndexPath:(NSIndexPath*)indexPath;

@end

@implementation SWAlbumEditViewController

@synthesize album = _album;
@synthesize filesToUpload = _filesToUpload;
@synthesize mode = _mode;

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
}

- (void)setFilesToUpload:(NSArray *)filesToUpload
{
    _filesToUpload = filesToUpload;
}

- (void)setMode:(NSInteger)mode
{
    _mode = mode;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    if (self.mode == SW_ALBUM_MODE_EDIT)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)];        
    }
    else if (self.mode == SW_ALBUM_MODE_CREATE)
    {
        self.album = [SWAlbum new];
    }
    else if (self.mode == SW_ALBUM_MODE_LINK)
    {
        // Temporary
        SWAlbum* a1 = [SWAlbum new];
        a1.name = @"Album 1";
        SWAlbum* a2 = [SWAlbum new];
        a2.name = @"Album 2";
        _linkedAlbums = [NSArray arrayWithObjects:a1, a2, nil];
    }
    else if (self.mode == SW_ALBUM_MODE_QUICK_SHARE)
    {
        
    }
}

- (void)done:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    
    if (self.mode == SW_ALBUM_MODE_EDIT)
    {
        NSLog(@"[SWAlbumEditViewController#done] edit album");
    }
    else if (self.mode == SW_ALBUM_MODE_CREATE)
    {
        NSLog(@"[SWAlbumEditViewController#done] create album");
    }
    else if (self.mode == SW_ALBUM_MODE_LINK)
    {
        NSLog(@"[SWAlbumEditViewController#done] link album");
    }
    else if (self.mode == SW_ALBUM_MODE_QUICK_SHARE)
    {
        NSLog(@"[SWAlbumEditViewController#done] quick share");
    }
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
    switch (self.mode)
    {
        case SW_ALBUM_MODE_EDIT:
            if (self.album.isOwner)
                return 6;
            return 5;         
        case SW_ALBUM_MODE_CREATE:
            return 5;
        case SW_ALBUM_MODE_LINK:
            return 2;
        case SW_ALBUM_MODE_QUICK_SHARE:
            return 1;
        default:
            return 0;
    }
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
    
    if (self.mode == SW_ALBUM_MODE_EDIT)
    {
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
    }
    else if (self.mode == SW_ALBUM_MODE_CREATE)
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
        }        
    }
    else if (self.mode == SW_ALBUM_MODE_LINK)
    {
        switch (section)
        {
            case 0:
                v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"choose_album_to_link", @"choose an album where your files will be linked")];
                break;
            case 1:
                v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"media_settings", @"media settings")];
                break;
        }       
    }
    else if (self.mode == SW_ALBUM_MODE_QUICK_SHARE)
    {
        switch (section)
        {
            case 0:
                v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"share_to_people", @"Share to the following people")];
                break;
        }       
    }    
        
    return v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.mode == SW_ALBUM_MODE_EDIT)
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
    }
    else if (self.mode == SW_ALBUM_MODE_CREATE)
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
        }
    }
    else if (self.mode == SW_ALBUM_MODE_LINK)
    {
        switch (section)
        {
            case 0:
                // should come from CoreData...
                return [_linkedAlbums count];
            case 1:
                return 1;
        }
    }
    else if (self.mode == SW_ALBUM_MODE_QUICK_SHARE)
    {
        switch (section)
        {
            case 0:
                return [_quickSharePeople count] + 1;
        }
    }    
        
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StaticCellIdentifier = @"StaticGroupedCell";
    static NSString *InputCellIdentifier = @"InputGroupedCell";
    
    SWTableViewCell *cell;
    if ((self.mode == SW_ALBUM_MODE_EDIT || self.mode == SW_ALBUM_MODE_CREATE) && indexPath.section == 0 && indexPath.row == 0)
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
    
    if (self.mode == SW_ALBUM_MODE_EDIT)
    {
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
    }
    else if (self.mode == SW_ALBUM_MODE_CREATE)
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
        }        
    }
    else if (self.mode == SW_ALBUM_MODE_LINK)
    {
        switch (indexPath.section)
        {
            case 0:
                [self setupSectionChooseAlbumToLink:cell indexPath:indexPath];
                break;
            case 1:
                [self setupSectionMediaSettings:cell indexPath:indexPath];
                break;
        }
    }
    else if (self.mode == SW_ALBUM_MODE_QUICK_SHARE)
    {
        switch (indexPath.section)
        {
            case 0:
                [self setupSectionShareToPeople:cell indexPath:indexPath];
                break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.mode == SW_ALBUM_MODE_EDIT)
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
    else if (self.mode == SW_ALBUM_MODE_CREATE)
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
        }          
    }
    else if (self.mode == SW_ALBUM_MODE_LINK)
    {
        switch (indexPath.section)
        {
            case 0:
                [self handleSectionChooseAlbumToLinkWithIndexPath:indexPath];
                break;
            case 1:
                [self handleSectionMediaSettingsWithIndexPath:indexPath];
                break;
        }
    }
    else if (self.mode == SW_ALBUM_MODE_QUICK_SHARE)
    {
        switch (indexPath.section)
        {
            case 0:
                [self handleSectionShareToPeopleWithIndexPath:indexPath];
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
    if (self.mode == SW_ALBUM_MODE_QUICK_SHARE)
    {
        _quickSharePeople = arr;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:NO];
    }
    else
    {
        self.album.participants = arr;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:NO];
    }
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
    
    if (self.mode == SW_ALBUM_MODE_LINK)
    {
        cell.accessoryType = _canExportMediasForLinkedAlbum ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    else
    {
        cell.accessoryType = self.album.canExportMedias ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
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

- (void)setupSectionChooseAlbumToLink:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row < [_linkedAlbums count])
    {
        SWAlbum* p = [_linkedAlbums objectAtIndex:indexPath.row];
        // if (p.canEditMedias)
        cell.title.text = p.name;
        cell.accessoryType = (p == _selectedLinkedAlbum) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
}

- (void)setupSectionShareToPeople:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row < [_quickSharePeople count])
    {
        SWPerson* p = [_quickSharePeople objectAtIndex:indexPath.row];
        cell.title.text = p.name;
        cell.imageView.image = p.thumbnail;
    }
    else
    {
        cell.isLink = YES;
        cell.title.text = NSLocalizedString(@"add_remove_people", @"Add / Remove people");
    }
}

- (void)handleSectionParticipantsWithIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == [self.album.participants count])
    {
        if ((self.mode == SW_ALBUM_MODE_EDIT && self.album.isOwner) || self.mode == SW_ALBUM_MODE_CREATE)
        {
            SWPeopleListViewController* plvc = [SWPeopleListViewController new];
            plvc.mode = PEOPLE_LIST_MULTI_SELECTION_MODE;
            plvc.delegate = self;
            plvc.selectedContacts = [NSMutableArray arrayWithArray:self.album.participants];
            [self presentViewController:plvc animated:YES completion: nil];
        }
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
    if (self.mode == SW_ALBUM_MODE_LINK)
    {
        _canExportMediasForLinkedAlbum = !_canExportMediasForLinkedAlbum;
    }
    else
    {
        self.album.canExportMedias = !self.album.canExportMedias;
    }
    
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

- (void)handleSectionChooseAlbumToLinkWithIndexPath:(NSIndexPath*)indexPath
{
    _selectedLinkedAlbum = [_linkedAlbums objectAtIndex:indexPath.row];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:YES];    
}

- (void)handleSectionShareToPeopleWithIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == [_quickSharePeople count])
    {
        SWPeopleListViewController* plvc = [SWPeopleListViewController new];
        plvc.mode = PEOPLE_LIST_MULTI_SELECTION_MODE;
        plvc.delegate = self;
        plvc.selectedContacts = [NSMutableArray arrayWithArray:_quickSharePeople];
        [self presentViewController:plvc animated:YES completion: nil]; 
    }
}

@end