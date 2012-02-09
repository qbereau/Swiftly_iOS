//
//  SWPeopleViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPeopleViewController.h"

#define MODE_CONTACTS 0
#define MODE_GROUPS 1

@implementation SWPeopleViewController

@synthesize currentMode = _currentMode;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentMode = MODE_CONTACTS;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:NSLocalizedString(@"contacts", @"contacts"), NSLocalizedString(@"groups", @"groups"), nil]];
    [segmentedControl addTarget:self
	                     action:@selector(changeMode:)
	           forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 170, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segmentedControl;
    
    
    _plvc = [[SWPeopleListViewController alloc] initWithStyle:UITableViewStylePlain];    
    [self addChildViewController:_plvc];
    [self.view addSubview:_plvc.view];
    _plvc.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 93);
    [_plvc didMoveToParentViewController:self];
    
    _glvc = [[SWGroupListViewController alloc] initWithStyle:UITableViewStylePlain];    
    [self addChildViewController:_glvc];
    [self.view addSubview:_glvc.view];
    _glvc.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 93);
    [_glvc didMoveToParentViewController:self];  
    
    _glvc.view.hidden = YES;
}

- (void)addGroup:(id)sender
{
    NSLog(@"push group view controller");
}

- (void)changeMode:(UISegmentedControl*)sender
{
    self.currentMode = !self.currentMode;
    
    if (self.currentMode == MODE_GROUPS)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(addGroup:)];
        
        _plvc.view.hidden = YES;
        _glvc.view.hidden = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
        
        _plvc.view.hidden = NO;
        _glvc.view.hidden = YES;
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
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowContact"])
    {
        SWContactViewController* newController = segue.destinationViewController;
        newController.contact = (SWPerson*)sender;
    }
    else if ([segue.identifier isEqualToString:@"ShowGroup"])
    {
        SWGroupEditViewController* newController = segue.destinationViewController;
        newController.name = (NSString*)sender;
    }
}
*/

@end
