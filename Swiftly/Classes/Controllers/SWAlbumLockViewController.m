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

#pragma mark - KVPasscodeViewControllerDelegate 
- (void)didCancelPasscodeController:(KVPasscodeViewController *)controller
{
    _newAlbumLock = nil;
}

- (void)passcodeController:(KVPasscodeViewController *)controller passcodeEntered:(NSString *)passCode 
{
    if (_wantToDeleteAlbumLock)
    {
        if ([passCode intValue] != [self.albumLock intValue])
        {
            NSLog(@"delete impossible, code don't match");
            [controller dismissModalViewControllerAnimated:YES];
        }
        else
        {
            // Should delete album lock!!
            self.albumLock = nil;
            _newAlbumLock = nil;
            _confirmingLock = NO;
            NSLog(@"album lock deleted!!");            
            [self.tableView reloadData];
            [controller dismissModalViewControllerAnimated:YES];            
        }
    }
    else if (!self.albumLock)
    {
        if (!_newAlbumLock)
        {
            _newAlbumLock = [NSNumber numberWithInt:[passCode intValue]];
            [controller resetWithAnimation:KVPasscodeAnimationStyleConfirm];
            controller.titleLabel.text = NSLocalizedString(@"album_lock_repeat_new_lock", @"confirm your album lock");
        }
        else if ([passCode intValue] != [_newAlbumLock intValue])
        {
            _newAlbumLock = nil;
            [controller dismissModalViewControllerAnimated:YES];
            NSLog(@"two code don't match!!");
        }
        else
        {
            self.albumLock = [NSNumber numberWithInt:[passCode intValue]];
            _newAlbumLock = nil;
            _confirmingLock = NO;
            NSLog(@"OK! New code defined!");
            [self.tableView reloadData];
            [controller dismissModalViewControllerAnimated:YES];            
        }
    }
    else
    {
        if ([passCode intValue] != [self.albumLock intValue] && !_confirmingLock)
        {
            NSLog(@"update impossible, code don't match");
            [controller dismissModalViewControllerAnimated:YES];
        }
        else
        {
            if (!_newAlbumLock)
            {
                if (!_confirmingLock)
                {
                    _confirmingLock = YES;
                    [controller resetWithAnimation:KVPasscodeAnimationStyleConfirm];
                    controller.titleLabel.text = NSLocalizedString(@"album_lock_define_new_lock", @"define a new album lock");
                }
                else
                {
                    _newAlbumLock = [NSNumber numberWithInt:[passCode intValue]];
                    [controller resetWithAnimation:KVPasscodeAnimationStyleConfirm];
                    controller.titleLabel.text = NSLocalizedString(@"album_lock_repeat_new_lock", @"confirm your album lock");
                }
            }
            else if ([passCode intValue] != [_newAlbumLock intValue])
            {
                _newAlbumLock = nil;     
                _confirmingLock = NO;
                [controller dismissModalViewControllerAnimated:YES];
                NSLog(@"two code don't match!!");
            }
            else
            {
                self.albumLock = [NSNumber numberWithInt:[passCode intValue]];
                _newAlbumLock = nil;
                _confirmingLock = NO;
                NSLog(@"OK! New code defined!");
                [self.tableView reloadData];
                [controller dismissModalViewControllerAnimated:YES];                
            }
        }
    }
}

@end
