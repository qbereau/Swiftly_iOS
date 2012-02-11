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
        self.group = [SWGroup new];
    
    self.navigationItem.title = self.group.name;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(editGroup:)];
    
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)editGroup:(UIBarButtonItem*)sender
{
    NSLog(@"[SWGroupEditViewController#editGroup] Save");
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
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    
    return [self.group.contacts count] + 1;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* v = (UILabel*)[tableView tableHeaderView];
    v.backgroundColor = [UIColor clearColor];
    
    if (section == 0)
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"group_name", @"group name")];
    else
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"participants", @"participants")];
    
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
        if (indexPath.row < [self.group.contacts count])
        {
            SWPerson* p = [self.group.contacts objectAtIndex:indexPath.row];
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == [self.group.contacts count])
    {
        SWPeopleListViewController* plvc = [SWPeopleListViewController new];
        plvc.mode = PEOPLE_LIST_MULTI_SELECTION_MODE;
        plvc.delegate = self;
        plvc.selectedContacts = [NSMutableArray arrayWithArray:self.group.contacts];
        [self presentViewController:plvc animated:YES completion: nil];
    }
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - SWPeopleListViewControllerDelegate
- (void)peopleListViewControllerDidSelectContacts:(NSArray*)arr
{
    self.group.contacts = arr;
    [self.tableView reloadData];
}

@end
