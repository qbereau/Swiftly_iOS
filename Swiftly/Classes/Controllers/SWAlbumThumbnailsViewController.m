//
//  SWAlbumThumbnailsViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbumThumbnailsViewController.h"

@implementation SWAlbumThumbnailsViewController

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
    
    if (self.selectedAlbum)
    {             
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        // Update Medias
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            self.arrMedias = [NSMutableArray array];
            self.mediaDS = [[SWWebImagesDataSource alloc] init];        
            
            self.arrBeforeSyncMedias = [NSMutableArray arrayWithArray:[SWMedia findMediasFromAlbumID:self.selectedAlbum.serverID]];
            
            [self reload];
            
            [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/albums/%d/medias", self.selectedAlbum.serverID]
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            
                                            int iTotalPages = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-total-pages"] intValue];
                                            
                                            if (iTotalPages > 1)
                                            {   
                                                _shouldUpdate = NO;
                                                NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:responseObject, @"objects", nil];
                                                
                                                NSInvocationOperation* operation;
                                                operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                                 selector:@selector(updateMediasWithDict:)
                                                                                                   object:params];
                                                [self.operationQueue addOperation:operation];                                                
                                                
                                                for (int i = 2; i <= iTotalPages; ++i)
                                                {
                                                    __block int opReq = iTotalPages - 1;
                                                    [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/albums/%d/medias?page=%d", self.selectedAlbum.serverID, i]
                                                                             parameters:nil
                                                                                success:^(AFHTTPRequestOperation *op2, id respObj2) {
                                                                                    
                                                                                    --opReq;
                                                                                    _shouldUpdate = (opReq == 0) ? YES : NO;
                                                                                    
                                                                                    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:  respObj2, @"objects", nil];                                                                                    
                                                                                    
                                                                                    NSInvocationOperation* operation;
                                                                                    operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                                                                     selector:@selector(updateMediasWithDict:)
                                                                                                                                       object:params];
                                                                                    [self.operationQueue addOperation:operation];
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
                                                NSInvocationOperation* operation;
                                                operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                                 selector:@selector(updateMediasWithDict:)
                                                                                                   object:params];
                                                [self.operationQueue addOperation:operation];
                                                
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
    
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setParentContext:[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext]];
    
    [context performBlock:^{
        
        SWAlbum* selAlbum = (SWAlbum*)[context objectWithID:self.selectedAlbum.objectID];
        for (id obj in responseObject)
        {
            SWMedia* mediaObj = [SWMedia findObjectWithServerID:[[obj valueForKey:@"id"] intValue] inContext:context];
            if (!mediaObj)
                mediaObj = [SWMedia createEntityInContext:context];
            [mediaObj updateWithObject:obj];
            mediaObj.album = selAlbum;
            [selAlbum addMediasObject:mediaObj];
            [self.arrMedias addObject:mediaObj];
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

- (void)updateMedias:(id)responseObject
{
    for (id obj in responseObject)
    {
        SWMedia* mediaObj = [SWMedia findObjectWithServerID:[[obj valueForKey:@"id"] intValue]];
        if (!mediaObj)
            mediaObj = [SWMedia createEntity];
        [mediaObj updateWithObject:obj];
        mediaObj.album = self.selectedAlbum;
        [self.selectedAlbum addMediasObject:mediaObj];
        [self.arrMedias addObject:mediaObj];
    }
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
    
    if (_shouldUpdate)
    {
        _shouldUpdate = NO;
        
        for (SWMedia* m1 in self.arrBeforeSyncMedias)
        {
            BOOL bFound = NO;
            for (SWMedia* m2 in [SWMedia findMediasFromAlbumID:self.selectedAlbum.serverID])
            {
                if (m1.serverID == m2.serverID)
                {
                    bFound = YES;
                    break;
                }
            }
            if (!bFound)
            {
                [m1 deleteEntity];
            }
        }
    }
    
    [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];    

    [self reload];
}

- (void)reload
{
    self.mediaDS.allMedias = [NSMutableArray arrayWithArray:[self.selectedAlbum sortedMedias]];
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
        SWPerson* p = [SWPerson findObjectWithServerID:_longPressMedia.creatorID];
        
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
