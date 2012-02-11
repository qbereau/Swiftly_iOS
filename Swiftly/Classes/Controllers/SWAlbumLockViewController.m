//
//  SWAlbumLockViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbumLockViewController.h"

@implementation SWAlbumLockViewController

@synthesize albumLock = _albumLock;

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellID = @"AlbumLockCell";
    
    SWTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    cell.isGrouped = YES;
    cell.isLink = YES;
    
    if (self.albumLock)
        cell.title.text = NSLocalizedString(@"album_lock_change_lock", @"change album lock");
    else
        cell.title.text = NSLocalizedString(@"album_lock_new_lock", @"new album lock");
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        _lockScreenViewController = [[JSLockScreenViewController alloc] initWithDelegate:self];
        
        _lockScreenViewController.isNewPasscode = !self.albumLock;
        
        UIWindow *window = (UIWindow*)[[[UIApplication sharedApplication] delegate] window];
        [_lockScreenViewController showInWindow:window];
    }
}

#pragma mark - JSLockScreenViewController
- (void)lockScreenDidUnlock:(JSLockScreenViewController *)lockScreen
{
    NSLog(@"Success");
}

- (void)lockScreenFailedUnlock:(JSLockScreenViewController *)lockScreen
{
    NSLog(@"Fail");
}

- (void)lockScreenDidCancel:(JSLockScreenViewController *)lockScreen
{
    NSLog(@"Cancel");
}

- (void)lockScreenDidDismiss:(JSLockScreenViewController *)lockScreen
{
    NSLog(@"Dismissed");
}

@end
