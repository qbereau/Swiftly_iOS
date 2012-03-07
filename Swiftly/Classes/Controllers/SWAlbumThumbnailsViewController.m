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
@synthesize arrMedias           = _arrMedias;
@synthesize arrBeforeSyncMedias = _arrBeforeSyncMedias;
@synthesize selectedAlbum       = _selectedAlbum;
@synthesize mediaDS             = _mediaDS;
@synthesize allowAlbumEdition   = _allowAlbumEditition;
@synthesize operationQueue      = _operationQueue;

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
    
    if ( (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM && self.selectedAlbum) || 
         (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_CONTACT && self.contact)
       )
    {             
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        // Update Medias
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            self.arrMedias = [NSMutableArray array];
            self.mediaDS = [[SWWebImagesDataSource alloc] init];        
            
            [self reload];
            
            NSString* uri = @"";
            if (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM)
            {
                self.arrBeforeSyncMedias = [NSMutableArray arrayWithArray:[SWMedia MR_findByAttribute:@"album.serverID" withValue:[NSNumber numberWithInt:self.selectedAlbum.serverID]]];
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
                                                _shouldUpdate = NO;
                                                NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:responseObject, @"objects", nil];
                                                [self updateMediasWithDict:params];
                                                
                                                for (int i = 2; i <= iTotalPages; ++i)
                                                {
                                                    __block int opReq = iTotalPages - 1;
                                                    [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"%@?page=%d", uri, self.selectedAlbum.serverID, i]
                                                                             parameters:nil
                                                                                success:^(AFHTTPRequestOperation *op2, id respObj2) {
                                                                                    
                                                                                    --opReq;
                                                                                    _shouldUpdate = (opReq == 0) ? YES : NO;
                                                                                    
                                                                                    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:  respObj2, @"objects", nil];                                                                                    
                                                                                    [self updateMediasWithDict:params];
                                                                                }
                                                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                    NSLog(@"error");
                                                                                }
                                                     ];
                                                }
                                            }
                                            else
                                            {
                                                _shouldUpdate = YES;
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
    id responseObject = [dict objectForKey:@"objects"];
    
    //NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    //[context setParentContext:[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext]];
    //[context performBlock:^{
        
    /*
        SWAlbum* selAlbum;
        SWPerson* selContact;
        if (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM)
            selAlbum = (SWAlbum*)[context objectWithID:self.selectedAlbum.objectID];
        else if (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_CONTACT)
            selContact = (SWPerson*)[context objectWithID:self.contact.objectID];
    */
        
        for (id obj in responseObject)
        {
            SWMedia* mediaObj = [SWMedia MR_findFirstByAttribute:@"serverID" withValue:[obj valueForKey:@"id"]];
            if (!mediaObj)
                mediaObj = [SWMedia MR_createEntity];
            [mediaObj updateWithObject:obj];
            if (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM && self.selectedAlbum)
            {
                mediaObj.album = self.selectedAlbum;
                [self.selectedAlbum addMediasObject:mediaObj];
            }
            else if (self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_CONTACT)
            {
                [mediaObj addSharedPeopleObject:self.contact];
                [self.contact addSharedMediasObject:mediaObj];
            }
            [self.arrMedias addObject:mediaObj];
        }
    
        [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];
    
        if (_shouldUpdate)
        {
            [self cleanup];
            [self reload];
        }
    //}];
}

- (void)cleanup
{
    if (_shouldUpdate && self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM)
    {
        _shouldUpdate = NO;
        
        NSArray* arr = [SWMedia MR_findByAttribute:@"album.serverID" withValue:[NSNumber numberWithInt:self.selectedAlbum.serverID]];
        for (SWMedia* m1 in self.arrBeforeSyncMedias)
        {
            BOOL bFound = NO;
            for (SWMedia* m2 in arr)
            {
                if (m1.serverID == m2.serverID)
                {
                    bFound = YES;
                    break;
                }
            }
            if (!bFound)
            {
                [m1 MR_deleteEntity];
            }
        }
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];
}

/*
- (void)contextDidSave:(NSNotification*)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextDidSave:)
                               withObject:notif
                            waitUntilDone:NO];
        return;
    }
    
    [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] mergeChangesFromContextDidSaveNotification:notif];
    
    if (_shouldUpdate && self.displayMode == ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM)
    {
        _shouldUpdate = NO;
        
        NSArray* selAlbMedias = [SWMedia MR_findByAttribute:@"album.serverID" withValue:[NSNumber numberWithInt:self.selectedAlbum.serverID]];
        for (SWMedia* m1 in self.arrBeforeSyncMedias)
        {
            BOOL bFound = NO;
            
            for (SWMedia* m2 in selAlbMedias)
            {
                if (m1.serverID == m2.serverID)
                {
                    bFound = YES;
                    break;
                }
            }
            if (!bFound)
            {
                [m1 MR_deleteEntity];
            }
        }
    }
    
    [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];    

    [self reload];
}
*/
 
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
