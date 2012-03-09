//
//  SWUploadQualityViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWUploadQualityViewController.h"

#define UPLOAD_QUALITY_KEY_IMAGE        @"image_quality_settings"
#define UPLOAD_QUALITY_KEY_VIDEO        @"video_quality_settings"

@implementation SWUploadQualityViewController

+ (NSInteger)imageQuality
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:UPLOAD_QUALITY_KEY_IMAGE])
        return [[defaults objectForKey:UPLOAD_QUALITY_KEY_IMAGE] intValue];
    else 
        return UPLOAD_QUALITY_KEY_MEDIUM;
}

+ (NSInteger)videoQuality
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:UPLOAD_QUALITY_KEY_VIDEO])
        return [[defaults objectForKey:UPLOAD_QUALITY_KEY_VIDEO] intValue];
    else
        return UPLOAD_QUALITY_KEY_MEDIUM;
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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];    
    
    _imageSettings = [SWUploadQualityViewController imageQuality];
    _videoSettings = [SWUploadQualityViewController videoQuality];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* v = [[UILabel alloc] initWithFrame:CGRectZero];
    v.textColor = [UIColor whiteColor];
    v.font = [UIFont boldSystemFontOfSize:14.0];
    v.backgroundColor = [UIColor clearColor];   
    
    if (section == 0)
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"image_quality", @"image quality")];
    else
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"video_quality", @"video quality")];
    
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    
    SWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.isGrouped = YES;
    cell.isSlider = NO;
    
    switch (indexPath.row)
    {
        case 0:
            cell.title.text = NSLocalizedString(@"high_quality", @"high quality");
            break;
        case 1:
            cell.title.text = NSLocalizedString(@"medium_quality", @"medium quality");
            break;
        case 2:
            cell.title.text = NSLocalizedString(@"low_quality", @"low quality");
            break;
    }
    
    if ( (indexPath.section == 0 && _imageSettings == indexPath.row) || 
         (indexPath.section == 1 && _videoSettings == indexPath.row)
        )
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;             
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (indexPath.section == 0)
    {
        _imageSettings = indexPath.row;
        [defaults setInteger:indexPath.row forKey:UPLOAD_QUALITY_KEY_IMAGE];
    }
    else
    {
        _videoSettings = indexPath.row;
        [defaults setInteger:indexPath.row forKey:UPLOAD_QUALITY_KEY_VIDEO];
    }
    [defaults synchronize];    
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:YES];    
}


@end
