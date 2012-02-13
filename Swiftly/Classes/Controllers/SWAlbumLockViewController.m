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
    self.navigationItem.title = NSLocalizedString(@"album_lock", @"album lock");
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
    if (self.albumLock)
        return 2;
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
    cell.isDestructive = NO;    
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        if (self.albumLock)
            cell.title.text = NSLocalizedString(@"album_lock_change_lock", @"change album lock");
        else
            cell.title.text = NSLocalizedString(@"album_lock_new_lock", @"new album lock");
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell.isDestructive = YES;
        cell.title.text = NSLocalizedString(@"album_lock_delete_album_lock", @"delete album lock");    
        cell.subtitle.text = NSLocalizedString(@"album_lock_delete_album_lock_subtitle", @"all your locked albums will be visible");
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _wantToDeleteAlbumLock = (indexPath.section == 1 && indexPath.row == 0);
    
    _passcodeController = [[KVPasscodeViewController alloc] init];
    _passcodeController.delegate = self;        
    
    UINavigationController *passcodeNavigationController = [[UINavigationController alloc] initWithRootViewController:_passcodeController];        
    [self.navigationController presentModalViewController:passcodeNavigationController animated:YES];
    
    if (!self.albumLock)
    {
        _passcodeController.titleLabel.text = NSLocalizedString(@"album_lock_define_new_lock", @"define a new album lock");
    }      
}

- (void)resetCodesProcess
{
    _newAlbumLock = nil;
    _confirmingLock = NO;
}

- (void)updateTitleAfterAnimation:(NSTimer*)timer
{
    NSString* title = (NSString*)[timer.userInfo objectForKey:@"title"];
    _passcodeController.titleLabel.text = title;
}

- (void)launchWrongSequence:(KVPasscodeViewController*)controller
{
    [controller resetWithAnimation:KVPasscodeAnimationStyleInvalid];
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(dismissController:)
                                   userInfo:nil
                                    repeats:NO];    
}

- (void)dismissController:(NSNotification*)notif
{
    [_passcodeController dismissModalViewControllerAnimated:YES];    
}

#pragma mark - KVPasscodeViewControllerDelegate 
- (void)didCancelPasscodeController:(KVPasscodeViewController *)controller
{
    [self resetCodesProcess];    
}

- (void)passcodeController:(KVPasscodeViewController *)controller passcodeEntered:(NSString *)passCode 
{
    if (_wantToDeleteAlbumLock)
    {
        // *******************
        // Delete Code Process
        // *******************        
        if ([passCode intValue] != [self.albumLock intValue])
        {
            // Impossible to delete code because 
            // entered code and album lock don't match
            [self resetCodesProcess];
            [self launchWrongSequence:controller];
        }
        else
        {
            // OK - Entered code and album lock DO match
            
            // Should delete album lock!!
            self.albumLock = nil;
            [self resetCodesProcess];
      
            [self.tableView reloadData];
            [controller dismissModalViewControllerAnimated:YES];            
        }
    }
    else if (!self.albumLock)
    {
        // *************************  
        // New Code Creation Process
        // *************************        
        if (!_newAlbumLock)
        {
            // First code entered, we need a confirmation step
            
            _newAlbumLock = [NSNumber numberWithInt:[passCode intValue]];
            [controller resetWithAnimation:KVPasscodeAnimationStyleConfirm];
            NSDictionary* dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"album_lock_repeat_new_lock", @"confirm your album lock") forKey:@"title"];
            [NSTimer scheduledTimerWithTimeInterval:0.3
                                             target:self
                                           selector:@selector(updateTitleAfterAnimation:)
                                           userInfo:dict
                                            repeats:NO];            
        }
        else if ([passCode intValue] != [_newAlbumLock intValue])
        {
            // Confirmation code and old code don't match
            
            [self resetCodesProcess];
            [self launchWrongSequence:controller];
        }
        else
        {
            // OK - New Code Created

            self.albumLock = [NSNumber numberWithInt:[passCode intValue]];
            [self resetCodesProcess];
            [self.tableView reloadData];
            [controller dismissModalViewControllerAnimated:YES];            
        }
    }
    else
    {
        // *******************        
        // Update Code Process
        // *******************        
        if ([passCode intValue] != [self.albumLock intValue] && !_confirmingLock)
        {
            // Impossible to update code process because 
            // entered code and album lock don't match
            
            [self launchWrongSequence:controller];
        }
        else
        {
            if (!_newAlbumLock)
            {
                if (!_confirmingLock)
                {
                    // First step of entering a new Album Lock
                    
                    _confirmingLock = YES;
                    [controller resetWithAnimation:KVPasscodeAnimationStyleConfirm];
                    
                    NSDictionary* dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"album_lock_define_new_lock", @"define a new album lock") forKey:@"title"];
                    [NSTimer scheduledTimerWithTimeInterval:0.3
                                                     target:self
                                                   selector:@selector(updateTitleAfterAnimation:)
                                                   userInfo:dict
                                                    repeats:NO];                      
                }
                else
                {
                    // Second Step of entering (confirming) new Album Lock
                    
                    _newAlbumLock = [NSNumber numberWithInt:[passCode intValue]];
                    [controller resetWithAnimation:KVPasscodeAnimationStyleConfirm];

                    NSDictionary* dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"album_lock_repeat_new_lock", @"confirm your album lock") forKey:@"title"];
                    [NSTimer scheduledTimerWithTimeInterval:0.3
                                                     target:self
                                                   selector:@selector(updateTitleAfterAnimation:)
                                                   userInfo:dict
                                                    repeats:NO];                     
                }
            }
            else if ([passCode intValue] != [_newAlbumLock intValue])
            {
                // New Album Lock and Confirmation don't match
                
                [self resetCodesProcess];
                [self launchWrongSequence:controller];
            }
            else
            {
                // OK - Album Lock Updated
                
                self.albumLock = [NSNumber numberWithInt:[passCode intValue]];
                [self resetCodesProcess];

                [self.tableView reloadData];
                [controller dismissModalViewControllerAnimated:YES];
            }
        }
    }
}

@end
