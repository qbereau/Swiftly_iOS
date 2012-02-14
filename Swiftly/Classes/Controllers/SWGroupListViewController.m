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
    
    [self.tableView setAutoresizesSubviews:YES];
    [self.tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];    

    [self synchronize];
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

    self.groups = [SWGroup findAllObjects];
    [self.tableView reloadData];
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

- (void)synchronize
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = NSLocalizedString(@"loading", @"loading");
    
    //[SWGroup deleteAllObjects];
    
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[SWAPIClient sharedClient] getPath:@"/groups"
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[NSArray class]])
                                        {   
                                            NSMutableArray* arrID = [NSMutableArray array];
                                            for (id obj in responseObject)
                                            {
                                                [arrID addObject:[obj valueForKey:@"id"]];
                                                
                                                SWGroup* groupObj = [SWGroup findObjectWithServerID:[[obj valueForKey:@"id"] intValue]];
                                                
                                                if (!groupObj)
                                                    groupObj = [SWGroup createEntity];
                                                
                                                [groupObj updateWithObject:obj];
                                            }
                                            
                                            [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
                                            
                                            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"NOT (serverID in %@)", arrID];
                                            NSArray* arr = [[SWGroup findAllObjects] filteredArrayUsingPredicate:predicate];
                                            BOOL shouldResync = NO;
                                            for (SWGroup* g in arr)
                                            {
                                                shouldResync = YES;
                                                [g deleteEntity];
                                            }
                                            
                                            if (shouldResync)
                                                [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
                                            
                                            self.groups = [SWGroup findAllObjects];
                                            [self.tableView reloadData];                                            
                                            
                                        }
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                                        [av show];
                                        
                                        // Hide the HUD in the main tread 
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                        });         
                                    }
         ];
    });
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
    cell.subtitle.text = [group contacts_str];
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
