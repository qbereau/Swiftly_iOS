//
//  SWGroupListViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWGroupListViewController.h"


@implementation SWGroupListViewController

@synthesize groups = _groups;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tableView = [[SWTableView alloc] initWithFrame:self.view.frame style:style];
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
    
    SWGroup* g1 = [SWGroup new];
    g1.name = @"Family";
    g1.contacts = [NSArray arrayWithObjects:qb, pb, tb, nil];
    
    SWGroup* g2 = [SWGroup new];
    g2.name = @"Friends";
    g2.contacts = [NSArray arrayWithObjects:pc, tb, nil];
    
    SWGroup* g3 = [SWGroup new];
    g3.name = @"Colleagues";
    g3.contacts = [NSArray arrayWithObjects:qb, pb, pc, nil];
    
    self.groups = [NSArray arrayWithObjects:g1, g2, g3, nil];
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


#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groups count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellID = @"GroupCell";
    
    SWTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    SWGroup* group = [self.groups objectAtIndex:indexPath.row];
    cell.title.text = group.name;
    cell.subtitle.text = [group participants];
    cell.imageView.image = nil;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWGroup* group = [self.groups objectAtIndex:indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    SWGroupEditViewController* groupEditViewController = [storyboard instantiateViewControllerWithIdentifier:@"GroupEditViewController"];
    groupEditViewController.group = group;
    [[self navigationController] pushViewController:groupEditViewController animated:YES];
}

@end
