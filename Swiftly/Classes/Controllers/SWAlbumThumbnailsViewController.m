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
@synthesize medias              = _medias;
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
    
    self.medias = [SWWebImagesDataSource new];
    [self setDataSource:self.medias];
    
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
    
    SWAlbum* album = [SWAlbum new];
    album.name = @"test";
    album.participants = [NSArray arrayWithObjects:qb, pb, tb, pc, nil];
    // -------
    
    SWAlbumEditViewController* vc = [[SWAlbumEditViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.album = album;
    [[self navigationController] pushViewController:vc animated:YES];
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
