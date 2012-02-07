//
//  SWSecondViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWActivitiesViewController.h"

@implementation SWActivitiesViewController

@synthesize navigationBar;
@synthesize tableView;
@synthesize activities = _activities;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.topItem.title = NSLocalizedString(@"menu_activities", @"Activities");
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];    

    self.activities = [NSArray arrayWithObjects:@"object 1", @"obejct 2", @"object 3", nil];
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [self.activities count];
    return 0;
}

- (UIView*)tableView:(UITableView*)tv viewForHeaderInSection:(NSInteger)section
{
    UILabel* v = [[UILabel alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableview_header"]];
    v.textColor = [UIColor whiteColor];
    v.font = [UIFont boldSystemFontOfSize:14.0];
    
    if (section == 0)
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"activities_in_progress", @"in progress")];
    else
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"activities_recent", @"recent")];
    
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78.0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWActivityTableViewCell* cell = [tv dequeueReusableCellWithIdentifier:@"ActivityCell"];
    
    if (!cell)
    {
        cell = [[SWActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActivityCell"];
        cell.opaque = NO;
    }
            
    cell.textLabel.text = [self.activities objectAtIndex:indexPath.row];
    cell.progress = 0;
    cell.imageView.image = [UIImage imageNamed:@"photoDefault.png"];
    
    return cell;
}

@end
