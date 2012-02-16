//
//  SWAlbumThumbnailsViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbumThumbnailsViewController.h"

@implementation SWAlbumThumbnailsViewController

@synthesize selectedAlbum       = _selectedAlbum;
@synthesize mediaDS             = _mediaDS;
@synthesize allowAlbumEdition   = _allowAlbumEditition;

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
    
    if (self.selectedAlbum)
    {             
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = NSLocalizedString(@"loading", @"loading");
        __block int reqCounter = 0;
        
        // Update Medias
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            ++reqCounter;
            [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/albums/%d/medias", self.selectedAlbum.serverID]
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            NSLog(@"obj: %@ - %@", responseObject, [responseObject class]);
                                            self.mediaDS = [[SWWebImagesDataSource alloc] init];
                                            
                                            NSMutableArray* arrMedias = [NSMutableArray new];
                                            for (id obj in responseObject)
                                            {
                                                SWMedia* mediaObj = [SWMedia createEntity];
                                                [mediaObj updateWithObject:obj];
                                                [arrMedias addObject:mediaObj];
                                            }
                                            
                                            self.mediaDS.allMedias = arrMedias;
                                            [self.mediaDS resetFilter];
                                            [self setDataSource:self.mediaDS]; 
                                            
                                            // Hide the HUD in the main tread 
                                            --reqCounter;
                                            if (reqCounter <= 0)
                                            {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                                });
                                            }
                                        } 
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            // Hide the HUD in the main tread 
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                                UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                                                [av show];                                                
                                            });
                                        }
             ];  
            
        });
        
        // Update Accounts
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            ++reqCounter;
            [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/albums/%d/accounts", self.selectedAlbum.serverID]
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            NSLog(@"obj: %@", responseObject);
                                           
                                            [self.selectedAlbum setParticipants:nil];
                                            for (id o in responseObject)
                                            {
                                                SWPerson* p = [SWPerson findObjectWithServerID:[[o valueForKey:@"id"] intValue]];
                                                if (!p)
                                                    p = [SWPerson newEntity];
                                                [self.selectedAlbum addParticipantsObject:p];
                                            }
                                            
                                            // Hide the HUD in the main tread 
                                            --reqCounter;
                                            if (reqCounter <= 0)
                                            {                                            
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                                });
                                            }
                                        } 
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            // Hide the HUD in the main tread 
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
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
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)changeMediaType:(id)sender
{
    if (!self.mediaDS.allMedias)
        return;
    
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    NSLog(@"%d", segmentedControl.selectedSegmentIndex);
    
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

#pragma mark - KTThumbsViewController

- (void)didSelectThumbAtIndex:(NSUInteger)index
{
    SWPhotoScrollViewController* newController = [[SWPhotoScrollViewController alloc] 
                                                  initWithDataSource:[self dataSource] 
                                                  andStartWithPhotoAtIndex:index];
    
    [[self navigationController] pushViewController:newController animated:YES];
}

@end
