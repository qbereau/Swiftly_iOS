//
//  SWGroupEditViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWGroupEditViewController.h"

@implementation SWGroupEditViewController

@synthesize group = _group;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.tableView = [[SWTableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    }
    return self;
}

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
    
    if (!self.group)
        self.group = [SWGroup newEntity];
    
    self.navigationItem.title = self.group.name;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(editGroup:)];
    
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)editGroup:(UIBarButtonItem*)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = NSLocalizedString(@"loading", @"loading");
    
	//dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        void (^success)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (self.group.serverID == 0)
                self.group = [SWGroup createEntity];
            
            [self.group updateWithObject:responseObject];
            
            [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
            
            //dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            //});
            
            [[self navigationController] popViewControllerAnimated:YES];
        };
        
        void (^failure)(AFHTTPRequestOperation*, NSError*) = ^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
            [av show];
            
            // Hide the HUD in the main tread 
            //dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            //});
        };
        
        NSMutableArray* arr_ids = [NSMutableArray array];
        for (SWPerson* p in self.group.contacts)
        {
            [arr_ids addObject:[NSNumber numberWithInt:p.serverID]];
        }        
        
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:self.group.name, @"name", arr_ids, @"account_ids", nil];        
        if (self.group.serverID != 0)
        {
            [[SWAPIClient sharedClient] putPath:[NSString stringWithFormat:@"/groups/%d", self.group.serverID]
                                      parameters:params
                                         success:success
                                         failure:failure
             ];
        }
        else
        {
            [[SWAPIClient sharedClient] postPath:@"/groups"
                                     parameters:params
                                        success:success
                                        failure:failure
             ];
        }
    //});
}

- (void)deleteGroup
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = NSLocalizedString(@"loading", @"loading");
    
	//dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SWAPIClient sharedClient] deletePath:[NSString stringWithFormat:@"/groups/%d", self.group.serverID]
                                    parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {    
                                           
                                           SWGroup* g = [SWGroup findObjectWithServerID:self.group.serverID];
                                           [g deleteEntity];
                                           
                                           //[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];

                                           //dispatch_async(dispatch_get_main_queue(), ^{
                                               [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                           //});                                           
                                           
                                           [[self navigationController] popViewControllerAnimated:YES];
                                       }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                                           [av show];
                                           
                                           // Hide the HUD in the main tread 
                                           //dispatch_async(dispatch_get_main_queue(), ^{
                                               [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                           //});
                                       }
         ];
    //});
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.group.serverID > 0)
        return 3;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return [[self.group contacts_arr] count] + 1;
    return 1;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* v = (UILabel*)[tableView tableHeaderView];
    v.backgroundColor = [UIColor clearColor];
    
    if (section == 0)
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"group_name", @"group name")];
    else if (section == 1)
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"participants", @"participants")];
    else
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"settings", @"settings")];
    
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StaticCellIdentifier = @"StaticGroupedCell";
    static NSString *InputCellIdentifier = @"InputGroupedCell";
    
    SWTableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:InputCellIdentifier];
        if (!cell)
        {
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:InputCellIdentifier];        
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:StaticCellIdentifier];
        if (!cell)
        {
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:StaticCellIdentifier];        
        }
    }
    
    cell.isGrouped = YES;
    cell.isLink = NO;
    cell.isDestructive = NO;
    cell.title.textAlignment = UITextAlignmentLeft;
    
    if (indexPath.section == 0)
    {
        UITextField* tf;
        for (UIView* v in cell.contentView.subviews)
        {
            if (v.tag == 1)
            {
                tf = (UITextField*)v;
                break;
            }
        }
        tf.text = self.group.name;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1)
    {   
        if (indexPath.row < [[self.group contacts_arr] count])
        {
            SWPerson* p = [[self.group contacts_arr] objectAtIndex:indexPath.row];
            cell.title.text = p.name;
            cell.imageView.image = p.thumbnail;
            cell.imageView.frame = CGRectMake(10, 10, 44, 44);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            cell.isLink = YES;
            cell.title.text = NSLocalizedString(@"add_remove_people", @"add / remove people");
            cell.imageView.image = nil;
            cell.title.textAlignment = UITextAlignmentCenter;
            cell.title.textColor = [UIColor colorWithRed:0.300 green:0.431 blue:0.486 alpha:1];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    }
    else if (indexPath.section == 2)
    {
        cell.isLink = YES;
        cell.isDestructive = YES;
        cell.title.text = NSLocalizedString(@"delete_group", @"delete group");
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == [[self.group contacts_arr] count])
    {
        SWPeopleListViewController* plvc = [SWPeopleListViewController new];
        plvc.mode = PEOPLE_LIST_MULTI_SELECTION_MODE;
        plvc.delegate = self;
        plvc.selectedContacts = [NSMutableArray arrayWithArray:[self.group contacts_arr]];
        [self presentViewController:plvc animated:YES completion: nil];
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirmation", @"confirmation") message:NSLocalizedString(@"delete_group_confirmation", @"are you sure...") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"cancel") otherButtonTitles:NSLocalizedString(@"ok", @"ok"), nil];
        [av show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self deleteGroup];
    }
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.group.name = textField.text;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - SWPeopleListViewControllerDelegate
- (void)peopleListViewControllerDidSelectContacts:(NSArray*)arr
{
    if (self.group.contacts)
        [self.group setContacts:nil];
    
    for (SWPerson* p in arr)
    {
        [self.group addContactsObject:p];
    }

    [self.tableView reloadData];
}

@end
