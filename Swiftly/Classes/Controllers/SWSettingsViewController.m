//
//  SWSettingsViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWSettingsViewController.h"

@implementation SWSettingsViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    self.navigationItem.title = NSLocalizedString(@"menu_settings", @"settings");
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
    return 3;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* v = [[UILabel alloc] initWithFrame:CGRectZero];
    v.textColor = [UIColor whiteColor];
    v.font = [UIFont boldSystemFontOfSize:14.0];
    v.backgroundColor = [UIColor clearColor];
    
    switch (section)
    {
        case 0:
            v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"app_settings", @"App Settings")];
            break;
        case 1:
            v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"help", @"help")];  
            break;
        case 2:
            v.text = nil;
            break;
    }
    
    return v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 1;
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellID = @"SettingsCell";
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cellID = @"RightDetailSettingsCell";
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    cell.detailTextLabel.text = nil;
    
    UIView* bgSelView = [UIView new];
    [bgSelView setBackgroundColor:[UIColor colorWithRed:0.843 green:0.843 blue:0.843 alpha:1]];
    bgSelView.layer.cornerRadius = 10;
    cell.selectedBackgroundView = bgSelView;
    
    switch (indexPath.section)
    {
        case 0:
            if (indexPath.row == 0)
            {
                // App version
                cell.textLabel.text = NSLocalizedString(@"app_version", @"version: ");
                cell.detailTextLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            break;
        case 1:
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"how_do_i", @"how do I");                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        case 2:
            if (indexPath.row == 0)
            {
                cell.textLabel.textColor = [UIColor redColor];
                cell.textLabel.text = NSLocalizedString(@"delete_account", @"delete account...");
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.textLabel.highlightedTextColor = [UIColor redColor];
                cell.detailTextLabel.textColor = [UIColor redColor];
                cell.detailTextLabel.highlightedTextColor = [UIColor redColor];
                cell.detailTextLabel.text = NSLocalizedString(@"delete_account_subtitle", @"this will delete your albums, files, ...");
                cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
            }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0)
    {        
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"delete_account_alert_title", @"Are you sure") message:NSLocalizedString(@"delete_account_alert_message", @"this will delete all your data") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
        [av show];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        NSLog(@"[SWSettingsViewController#alertview] Delete Account...");
    }
}

@end
