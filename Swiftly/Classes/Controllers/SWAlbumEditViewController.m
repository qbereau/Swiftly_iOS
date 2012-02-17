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
@synthesize linkableAlbums = _linkableAlbums;
@synthesize uploadMediasBlock = _uploadMediasBlock;
@synthesize genericFailureBlock = _genericFailureBlock;

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
    
    
    __block SWAlbumEditViewController* blockSelf = self;
    self.uploadMediasBlock = ^(int album_id) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            __block int processedEntity = 0;
            for (NSDictionary* media in blockSelf.filesToUpload)
            {                    
                NSString* fileType = @"image/jpeg";
                NSURL* mediaUrl = [media valueForKey:@"UIImagePickerControllerReferenceURL"];
                if ([[[mediaUrl absoluteString] lowercaseString] rangeOfString:@"ext=png"].location != NSNotFound)
                    fileType = @"image/png";
                else if ([[[mediaUrl absoluteString] lowercaseString] rangeOfString:@"ext=mov"].location != NSNotFound)
                    fileType = @"video/quicktime";
                
                UIImage* mediaThumbnail =  [media valueForKey:@"UIImagePickerControllerThumbnail"];                    
                
                NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:fileType, @"content_type", [NSNumber numberWithInt:album_id], @"album_id", nil];
                
                [[SWAPIClient sharedClient] postPath:@"/medias"
                                          parameters:params
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 
                                                 SWMedia* mediaObj = [SWMedia createEntity];
                                                 [mediaObj updateWithObject:responseObject];
                                                 mediaObj.uploadProgress    = 0.0f;
                                                 mediaObj.isUploaded        = NO;
                                                 mediaObj.thumbnail         = mediaThumbnail;
                                                 mediaObj.assetURL          = [mediaUrl absoluteString];
                                                 
                                                 ++processedEntity;
                                                 if (processedEntity == [blockSelf.filesToUpload count])
                                                 {
                                                     [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
                                                     [MBProgressHUD hideHUDForView:blockSelf.navigationController.view animated:YES];
                                                     
                                                     blockSelf.tabBarController.selectedIndex = 1;
                                                     [blockSelf.navigationController popToRootViewControllerAnimated:NO];
                                                 }                                                     
                                                 
                                             } 
                                             failure:blockSelf.genericFailureBlock
                 ];                                        
            }
        });        
    };
    
    self.genericFailureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:blockSelf.navigationController.view animated:YES];
            UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
            [av show];                                               
        });
    };
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
        self.album = [SWAlbum newEntity];
    }
    else if (self.mode == SW_ALBUM_MODE_LINK)
    {
        self.linkableAlbums = [SWAlbum findAllLinkableAlbums];
    }
    else if (self.mode == SW_ALBUM_MODE_QUICK_SHARE)
    {

    }
}

- (void)done:(id)sender
{    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = NSLocalizedString(@"loading", @"loading");
    
    if (self.mode == SW_ALBUM_MODE_EDIT)
    {        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [[SWAPIClient sharedClient]     putPath:[NSString stringWithFormat:@"/albums/%d", self.album.serverID]
                                         parameters:[self.album toDictionnary]
                                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                
                                                BOOL shouldBeLocked = self.album.isLocked;
                                                if (self.album.serverID == 0)
                                                    self.album = [SWAlbum createEntity];
                                                
                                                self.album.isLocked = shouldBeLocked;
                                                [self.album updateWithObject:responseObject];                                               
                                                
                                                [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
                                                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                                
                                                [self.navigationController popToRootViewControllerAnimated:NO];
                                            }
                                            failure:self.genericFailureBlock
             ];
        });
    }
    else if (self.mode == SW_ALBUM_MODE_CREATE)
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [[SWAPIClient sharedClient] postPath:@"/albums"
                                      parameters:[self.album toDictionnary]
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             
                                             NSMutableArray* contacts_arr = [NSMutableArray array];
                                             for (SWPerson* p in self.album.participants)
                                             {
                                                 [contacts_arr addObject:[NSNumber numberWithInt:p.serverID]];
                                             }
                                             
                                             BOOL shouldLockAlbum = self.album.isLocked;
                                             self.album = [SWAlbum createEntity];
                                             self.album.isLocked = shouldLockAlbum;
                                             [self.album updateWithObject:responseObject];
                                             
                                             [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
                                             
                                             NSDictionary* contacts = [NSDictionary dictionaryWithObject:contacts_arr forKey:@"add_account_ids"];
                                             
                                             [[SWAPIClient sharedClient] putPath:[NSString stringWithFormat:@"/albums/%d", self.album.serverID]
                                                                       parameters:contacts
                                                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                              self.uploadMediasBlock(self.album.serverID);
                                                                          }
                                                                          failure:self.genericFailureBlock
                                              ];
                                         }
                                         failure:self.genericFailureBlock 
             ];            

        });
    }
    else if (self.mode == SW_ALBUM_MODE_LINK)
    {
        if (!_selectedLinkedAlbum)
        {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];  
            
            UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"select_linkable_album", @"select an album") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
            [av show];       
        }
        else
        {
            self.uploadMediasBlock(_selectedLinkedAlbum.serverID);
        }
    }
    else if (self.mode == SW_ALBUM_MODE_QUICK_SHARE)
    {
        __block SWAlbumEditViewController* blockSelf = self;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            __block int processedEntity = 0;
            __block NSMutableArray* newMedias = [NSMutableArray array];
            for (NSDictionary* media in blockSelf.filesToUpload)
            {                    
                NSString* fileType = @"image/jpeg";
                NSURL* mediaUrl = [media valueForKey:@"UIImagePickerControllerReferenceURL"];
                if ([[[mediaUrl absoluteString] lowercaseString] rangeOfString:@"ext=png"].location != NSNotFound)
                    fileType = @"image/png";
                else if ([[[mediaUrl absoluteString] lowercaseString] rangeOfString:@"ext=mov"].location != NSNotFound)
                    fileType = @"video/quicktime";
                
                UIImage* mediaThumbnail =  [media valueForKey:@"UIImagePickerControllerThumbnail"];                    
                
                NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:fileType, @"content_type", nil];
                
                [[SWAPIClient sharedClient] postPath:@"/medias"
                                          parameters:params
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 
                                                 SWMedia* mediaObj = [SWMedia createEntity];
                                                 [mediaObj updateWithObject:responseObject];
                                                 mediaObj.uploadProgress    = 0.0f;
                                                 mediaObj.isUploaded        = NO;
                                                 mediaObj.thumbnail         = mediaThumbnail;
                                                 mediaObj.assetURL          = [mediaUrl absoluteString];
                                                 
                                                 [newMedias addObject:[NSNumber numberWithInt:mediaObj.serverID]];
                                                 
                                                 ++processedEntity;
                                                 if (processedEntity == [blockSelf.filesToUpload count])
                                                 {
                                                     NSMutableArray* accountIDs = [NSMutableArray array]; 
                                                     for (SWPerson* p in _quickSharePeople)
                                                     {
                                                         [accountIDs addObject:[NSNumber numberWithInt:p.serverID]];
                                                     }
                                                     
                                                     NSDictionary* quickshareParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                       newMedias, @"media_ids",
                                                                                       accountIDs, @"account_ids"
                                                                                       , nil];
                                                     [[SWAPIClient sharedClient] putPath:@"/medias/quickshare"
                                                                              parameters:quickshareParams
                                                                                 success:^(AFHTTPRequestOperation *op2, id respObj2) {
                                                                                     
                                                                                     [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
                                                                                     [MBProgressHUD hideHUDForView:blockSelf.navigationController.view animated:YES];
                                                                                     
                                                                                     blockSelf.tabBarController.selectedIndex = 1;
                                                                                     [blockSelf.navigationController popToRootViewControllerAnimated:NO];                                                                                      
                                                                                     
                                                                                 } 
                                                                                 failure:blockSelf.genericFailureBlock
                                                      ];                                                         
                                                 }                                                     
                                                 
                                             } 
                                             failure:blockSelf.genericFailureBlock
                 ];                                        
            }
        });
    }
}

- (void)cleanupAlbum:(BOOL)shouldUnlink
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = NSLocalizedString(@"loading", @"loading");
    
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSString* unlink; 
        if (shouldUnlink)
            unlink = @"&unlink";
        else
            unlink = @"";
        
        [[SWAPIClient sharedClient] putPath:[NSString stringWithFormat:@"/albums/%d/cleanup%@", self.album.serverID, unlink]
                                    parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {    
                                           [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                           [[self navigationController] popToRootViewControllerAnimated:YES];
                                       }
                                    failure:self.genericFailureBlock
         ];
    });
}

- (void)deleteAlbum:(BOOL)shouldUnlink
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = NSLocalizedString(@"loading", @"loading");
    
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSString* unlink; 
        if (shouldUnlink)
            unlink = @"&unlink";
        else
            unlink = @"";
        
        [[SWAPIClient sharedClient] deletePath:[NSString stringWithFormat:@"/albums/%d%@", self.album.serverID, unlink]
                                    parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {    
                                           
                                           SWAlbum* album = [SWAlbum findObjectWithServerID:self.album.serverID];
                                           [album deleteEntity];
                                           [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
                                           [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                           [[self navigationController] popToRootViewControllerAnimated:YES];
                                       }
                                       failure:self.genericFailureBlock
         ];
    });
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
            if ([self.linkableAlbums count] > 0)
                return 2;
            return 1;
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
                    if (self.album.participants)
                        return [[self.album participants_arr] count] + 1;
                    return 0;
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
                    return [[self.album participants_arr] count];
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
                return [[self.album participants_arr] count] + 1;
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
                if ([self.linkableAlbums count] > 0)
                    return [self.linkableAlbums count];
                return 1;
            case 1:
                if ([self.linkableAlbums count] > 0)
                    return 1;
                return 0;
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
    self.album.name = textField.text;
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
        if (self.album.participants)
            [self.album setParticipants:nil];
        
        for (SWPerson* p in arr)
        {
            [self.album addParticipantsObject:p];
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:NO];
    }
}

@end

@implementation SWAlbumEditViewController (Private)

- (void)setupSectionParticipants:(SWTableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row < [[self.album participants_arr] count])
    {
        SWPerson* p = [[self.album participants_arr] objectAtIndex:indexPath.row];
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
    if ([self.linkableAlbums count] > 0)
    {
        if (indexPath.row < [self.linkableAlbums count])
        {
            SWAlbum* p = [self.linkableAlbums objectAtIndex:indexPath.row];
            // if (p.canEditMedias)
            cell.title.text = p.name;
            cell.accessoryType = (p == _selectedLinkedAlbum) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }
    else
    {
        cell.title.text = NSLocalizedString(@"no_linkable_album", @"no albums available");
        cell.subtitle.text = NSLocalizedString(@"no_linkable_album_subtitle", @"no albums linkable...");
        self.navigationItem.rightBarButtonItem = nil;
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
    if (indexPath.row == [[self.album participants_arr] count])
    {
        if ((self.mode == SW_ALBUM_MODE_EDIT && self.album.isOwner) || self.mode == SW_ALBUM_MODE_CREATE)
        {
            SWPeopleListViewController* plvc = [SWPeopleListViewController new];
            plvc.mode = PEOPLE_LIST_MULTI_SELECTION_MODE;
            plvc.delegate = self;
            plvc.selectedContacts = [NSMutableArray arrayWithArray:[self.album participants_arr]];
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
            [self cleanupAlbum:NO];
        };
    }
    else if (indexPath.row == 1)
    {
        msg = NSLocalizedString(@"unlink_from_album_warning", @"");
        btnYES.action = ^{
            [self deleteAlbum:YES];
        };
    }
    else if (indexPath.row == 2)
    {
        msg = NSLocalizedString(@"delete_album_warning", @"");
        btnYES.action = ^{
            [self deleteAlbum:NO];
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
    if ([self.linkableAlbums count] > 0)
    {
        _selectedLinkedAlbum = [self.linkableAlbums objectAtIndex:indexPath.row];

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:YES];    
    }
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