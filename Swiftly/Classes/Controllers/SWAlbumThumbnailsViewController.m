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
            
            
            [self reload];
            
            [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/albums/%d/medias", self.selectedAlbum.serverID]
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            
                                            int iTotalPages = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-total-pages"] intValue];
                                            
                                            if (iTotalPages > 1)
                                            {   
                                                for (int i = 2; i <= iTotalPages; ++i)
                                                {
                                                    __block int opReq = iTotalPages - 2;
                                                    [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/albums/%d/medias?page=%d", self.selectedAlbum.serverID, i]
                                                                             parameters:nil
                                                                                success:^(AFHTTPRequestOperation *op2, id respObj2) {
                                                                                    
                                                                                    //[self updateMedias:responseObject];
                                                                                    
                                                                                    --opReq;
                                                                                    BOOL shouldUpdate = (opReq == 0) ? YES : NO;
                                                                                    
                                                                                    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:  responseObject, @"objects", 
                                                                                                            [NSNumber numberWithBool:shouldUpdate], @"shouldUpdate",
                                                                                                            nil];                                                                                    
                                                                                    
                                                                                    NSInvocationOperation* operation;
                                                                                    operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                                                                     selector:@selector(updateMedias:)
                                                                                                                                       object:params];
                                                                                    [self.operationQueue addOperation:operation];
                                                                                    
                                                                                    /*
                                                                                    --opReq;
                                                                                    if (opReq == 0)
                                                                                        [self finishedUpdateMedias];
                                                                                    */
                                                                                }
                                                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                    NSLog(@"error");
                                                                                }
                                                     ];
                                                }
                                            }
                                            else
                                            {
                                                //[self updateMedias:responseObject];
                                                
                                                NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:  responseObject, @"objects", 
                                                                                                                    [NSNumber numberWithBool:YES], @"shouldUpdate",
                                                                        nil];
                                                NSInvocationOperation* operation;
                                                operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                                 selector:@selector(updateMedias:)
                                                                                                   object:params];
                                                [self.operationQueue addOperation:operation];
                                                
                                                
                                                //[self finishedUpdateMedias];
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

- (void)updateMedias:(NSDictionary*)dict
{
    id responseObject = [dict objectForKey:@"objects"];
    BOOL shouldUpdate = [[dict objectForKey:@"shouldUpdate"] boolValue];    
    
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setParentContext:[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext]];
    
    [context performBlock:^{
        
        SWAlbum* selAlbum = (SWAlbum*)[context existingObjectWithID:self.selectedAlbum.objectID error:nil];
        for (id obj in responseObject)
        {
            SWMedia* mediaObj = [SWMedia findObjectWithServerID:[[obj valueForKey:@"id"] intValue]];
            if (!mediaObj)
                mediaObj = [SWMedia createEntityInContext:context];
            [mediaObj updateWithObject:obj];
            if (!mediaObj.album)
            {
                mediaObj.album = selAlbum;
                [selAlbum addMediasObject:mediaObj];
            }
            [self.arrMedias addObject:mediaObj];
        }
        
        if (shouldUpdate)
        {
            for (SWMedia* m in [SWMedia findMediasFromAlbumID:selAlbum.serverID])
            {
                if (![self.arrMedias containsObject:m])
                {
                    [m deleteEntityInContext:context];
                }
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(contextDidSave:) 
                                                         name:NSManagedObjectContextDidSaveNotification 
                                                       object:context];
            
            [context save:nil];
            [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                            name:NSManagedObjectContextDidSaveNotification 
                                                          object:context];
        }        
    }];    
    
    /*
    NSManagedObjectContext* context     = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator]];
    
    id responseObject = [dict objectForKey:@"objects"];
    BOOL shouldUpdate = [[dict objectForKey:@"shouldUpdate"] boolValue];
    
    SWAlbum* selAlbum = (SWAlbum*)[context existingObjectWithID:self.selectedAlbum.objectID error:nil];
    
    for (id obj in responseObject)
    {
        SWMedia* mediaObj = [SWMedia findObjectWithServerID:[[obj valueForKey:@"id"] intValue]];
        if (!mediaObj)
            mediaObj = [SWMedia createEntityInContext:context];
        [mediaObj updateWithObject:obj];
        mediaObj.album = selAlbum;
        [selAlbum addMediasObject:mediaObj];
        [self.arrMedias addObject:mediaObj];
    }
    
    NSError* err;
    [context save:&err];
    NSLog(@"Error: %@", [err description]);
    
    if (shouldUpdate)
    {
        [self finishedUpdateMedias];
    }
     */
}

- (void)contextDidSave:(NSNotification*)notif
{
    [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] mergeChangesFromContextDidSaveNotification:notif];

    [self reload];
}

- (void)reload
{
    self.mediaDS.allMedias = [NSMutableArray arrayWithArray:[self.selectedAlbum sortedMedias]];
    [self.mediaDS resetFilter];
    [self setDataSource:self.mediaDS];
}

- (void)finishedUpdateMedias
{
    NSManagedObjectContext* context     = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator]];
    
    for (SWMedia* m in [SWMedia findMediasFromAlbumID:self.selectedAlbum.serverID])
    {
        if (![self.arrMedias containsObject:m])
        {
            [m deleteEntityInContext:context];
        }
    }
    
    [context save:nil];
    
    [self performSelectorOnMainThread:@selector(reload)
                           withObject:nil
                        waitUntilDone:YES];
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
