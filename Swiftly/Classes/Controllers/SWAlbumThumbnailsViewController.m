//
//  SWAlbumThumbnailsViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbumThumbnailsViewController.h"

@implementation SWAlbumThumbnailsViewController

@synthesize selectedAlbum = _selectedAlbum;
@synthesize medias = _medias;

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
    
    self.medias = [SWWebImagesDataSource new];
    [self setDataSource:self.medias];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"edit", @"edit") style:UIBarButtonItemStylePlain target:self action:@selector(editAlbum:)];
    
    
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
    SWAlbumEditViewController* newController = [[SWAlbumEditViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [[self navigationController] pushViewController:newController animated:YES];
}

- (void)changeMediaType:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    NSLog(@"%d", segmentedControl.selectedSegmentIndex);
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
