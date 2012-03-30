//
//  SWAlbumThumbnailsViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbumThumbnailsViewController.h"

@implementation SWAlbumThumbnailsViewController

@synthesize contact             = _contact;
@synthesize displayMode         = _displayMode;
@synthesize arrMediasID         = _arrMediasID;
@synthesize selectedAlbum       = _selectedAlbum;
@synthesize mediaDS             = _mediaDS;
@synthesize allowAlbumEdition   = _allowAlbumEditition;
@synthesize operationQueue      = _operationQueue;
@synthesize opReq               = _opReq;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];

    if (self.operationQueue == nil)
        self.operationQueue = [[NSOperationQueue alloc] init];
    
    self.mediaDS = [[SWWebImagesDataSource alloc] init];    
    
    if ( (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM && self.selectedAlbum) || 
         (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_CONTACT && self.contact)
       )
    //if (NO)
    {             
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        NSArray* medias = [SWMedia MR_findByAttribute:@"album.serverID" withValue:[NSNumber numberWithInt:self.selectedAlbum.serverID] inContext:[NSManagedObjectContext MR_context]];
        if ([medias count] == 0)
        {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
            hud.labelText = NSLocalizedString(@"loading", @"loading");            
        }     
        
        // Update Medias
        self.arrMediasID = [NSMutableArray array];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            NSString* uri = @"";
            if (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM)
            {
                uri = [NSString stringWithFormat:@"/albums/%d/medias", self.selectedAlbum.serverID];
            }
            else if (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_CONTACT)
                uri = [NSString stringWithFormat:@"/accounts/%d/medias", self.contact.serverID];
            
            [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:uri, self.selectedAlbum.serverID]
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            
                                            int iTotalPages = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-total-pages"] intValue];
                                            
                                            if (iTotalPages > 1)
                                            {   
                                                @synchronized(self) {
                                                    _shouldUpdate = NO;
                                                    self.opReq = iTotalPages - 1;
                                                }
                                                NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:responseObject, @"objects", nil];
                                                [self updateMediasWithDict:params];                            
                                                
                                                for (int i = 2; i <= iTotalPages; ++i)
                                                {
                                                    [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"%@?page=%d", uri, i]
                                                                             parameters:nil
                                                                                success:^(AFHTTPRequestOperation *op2, id respObj2) {
                                                                                    
                                                                                    @synchronized(self){
                                                                                        --self.opReq;
                                                                                        _shouldUpdate = (self.opReq == 0) ? YES : NO;
                                                                                    }
                                                                                    NSDictionary* params2 = [NSDictionary dictionaryWithObjectsAndKeys:  respObj2, @"objects", nil];                                                                                    
                                                                                    [self updateMediasWithDict:params2];
                                                                                }
                                                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                    NSLog(@"error");
                                                                                }
                                                     ];
                                                }
                                            }
                                            else
                                            {
                                                @synchronized(self) {
                                                    _shouldUpdate = YES;
                                                }
                                                NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:  responseObject, @"objects", nil];
                                                [self updateMediasWithDict:params];
                                                
                                            }

                                        } 
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            // Hide the HUD in the main tread 
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                                                [av show];                                                
                                            });
                                        }
             ];  
            
        });
        
    }
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:NSLocalizedString(@"all", @"all"), NSLocalizedString(@"images", @"images"), NSLocalizedString(@"videos", @"videos"), nil]];
    [segmentedControl addTarget:self
	                     action:@selector(changeMediaType:)
	           forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 170, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segmentedControl;
}

- (void)updateMediasWithDict:(NSDictionary*)dict
{
    //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        id responseObject = [dict objectForKey:@"objects"];
                
        [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {        
            for (id obj in responseObject)
            {
                SWMedia* mediaObj = [SWMedia MR_findFirstByAttribute:@"serverID" withValue:[obj valueForKey:@"id"] inContext:localContext];
                
                SWAlbum* selAlbum;
                SWPerson* selContact;
                if (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM)
                    selAlbum = [self.selectedAlbum MR_inContext:localContext];
                else if (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_CONTACT)
                    selContact = [self.contact MR_inContext:localContext];                
                
                if (!mediaObj)
                    mediaObj = [SWMedia MR_createInContext:localContext];
                [mediaObj updateWithObject:obj];
                mediaObj.isSyncedFromServer = YES;
                
                if (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM && selAlbum)
                {
                    mediaObj.album = selAlbum;
                    [selAlbum addMediasObject:mediaObj];
                }
                else if (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_CONTACT)
                {
                    [mediaObj addSharedPeopleObject:selContact];
                    [selContact addSharedMediasObject:mediaObj];
                }
                @synchronized(self) {
                    [self.arrMediasID addObject:[NSNumber numberWithInt:mediaObj.serverID]];
                }
            } 

        } completion:^{
                       
            if (_shouldUpdate)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.parentViewController.view animated:YES];
                }); 
                
                [self cleanup];
            }
        }];
        
    //});
}

- (void)cleanup
{
    if (_shouldUpdate && self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM)
    {
        _shouldUpdate = NO;
        
        if ([self.arrMediasID count] > 0)
        {
            [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"NOT (serverID IN %@) AND album.serverID = %d", self.arrMediasID, self.selectedAlbum.serverID];
                [SWMedia MR_deleteAllMatchingPredicate:predicate inContext:localContext];
            } completion:^{
                [self reload];
            }];
        }
        else
        {
            [self reload];
        }
    }
    else
    {
        [self reload];
    }
}
 
- (void)reload
{   
    if (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM)
        self.mediaDS.allMedias = [NSMutableArray arrayWithArray:[self.selectedAlbum sortedMedias]];
    else
        self.mediaDS.allMedias = [NSMutableArray arrayWithArray:[self.contact sortedSharedMedias]];

    [self.mediaDS resetFilter];
    [self setDataSource:self.mediaDS];
}

- (void)setAllowAlbumEdition:(BOOL)allowAlbumEdition
{
    _allowAlbumEditition = allowAlbumEdition;
    
    if (!allowAlbumEdition)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"edit", @"edit") style:UIBarButtonItemStylePlain target:self action:@selector(editAlbum:)];
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
    
    [self reload];
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

- (void)editAlbum:(UIBarButtonItem*)button
{
    SWAlbumEditViewController* vc = [[SWAlbumEditViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.album = self.selectedAlbum;
    vc.mode = SW_ALBUM_MODE_EDIT;
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)changeMediaType:(id)sender
{
    if (!self.mediaDS.allMedias)
        return;
    
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        // All
        [self.mediaDS resetFilter];
    }
    else if (segmentedControl.selectedSegmentIndex == 1)
    {
        // Images
        [self.mediaDS imageFilter];        
    }
    else
    {
        // Videos
        [self.mediaDS videoFilter];        
    }
    
    [self setDataSource:self.mediaDS];
}


- (void)didLongPressThumbAtIndex:(NSUInteger)index
{
    if (!_actionSheet)
    {
        _longPressMedia = [(SWWebImagesDataSource*)(self.dataSource) mediaAtIndex:index];
        SWPerson* p = [SWPerson MR_findFirstByAttribute:@"serverID" withValue:[NSNumber numberWithInt:_longPressMedia.creatorID]];
        
        _actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"filter_thumb_title", @"view all files")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button text.")
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"filter_thumb", @"view files shared by..."), p.name], NSLocalizedString(@"filter_thumb_all", @"view all files"), nil];
        [_actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 0)
    {
        // Filter by user
        [self.mediaDS filterByCreatorID:_longPressMedia.creatorID];
        [self setDataSource:self.mediaDS];
    }
    else if (buttonIndex == 1)
    {
        // Everyone
        [self.mediaDS resetFilter];
        [self setDataSource:self.mediaDS];        
    }
    
    _actionSheet = nil;
}


#pragma mark - KTThumbsViewController

- (void)didSelectThumbAtIndex:(NSUInteger)index
{
    SWPhotoScrollViewController* newController = [[SWPhotoScrollViewController alloc] 
                                                  initWithDataSource:[self dataSource] 
                                                  andStartWithPhotoAtIndex:index];
    
    [[self navigationController] pushViewController:newController animated:YES];
}

@end
