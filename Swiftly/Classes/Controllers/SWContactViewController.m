//
//  SWContactViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWContactViewController.h"

@implementation SWContactViewController

@synthesize contact = _contact;
@synthesize lblName = _lblName;
@synthesize lblPhoneNumber = _lblPhoneNumber;
@synthesize thumbnail = _thumbnail;
@synthesize cellViewFiles = _cellViewFiles;
@synthesize cellShareApp = _cellShareApp;
@synthesize cellBlock = _cellBlock;
@synthesize scroller = _scroller;

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
    
    self.navigationItem.title = [self.contact name];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    
    self.scroller.alwaysBounceVertical = YES;
    self.scroller.contentSize = CGSizeMake(self.view.frame.size.width, self.cellBlock.frame.origin.y + self.cellBlock.frame.size.height + 10);
    
    if (self.contact.isUser)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(editContact:)];
    }
    
    self.lblName.text = [self.contact name];
    self.lblPhoneNumber.text = self.contact.phoneNumber;
    self.thumbnail.image = self.contact.thumbnail;
    CALayer * l = [self.thumbnail layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    
    [self setupCells];
}

- (void)editContact:(UIBarButtonItem*)sender
{
    NSLog(@"[SWContactViewController#editContact] Sync with server");
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setLblName:nil];
    [self setThumbnail:nil];
    [self setCellViewFiles:nil];
    [self setCellShareApp:nil];
    [self setCellBlock:nil];
    [self setLblPhoneNumber:nil];
    [self setScroller:nil];
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

- (void)setupCells
{
    UIView *bgSelColorView = [UIView new];
    [bgSelColorView setBackgroundColor:[UIColor colorWithRed:0.843 green:0.843 blue:0.843 alpha:1]];
    bgSelColorView.layer.cornerRadius = 10;
    
    self.cellShareApp.backgroundView = [self bgCellView];
    self.cellShareApp.accessoryType = UITableViewCellAccessoryNone;
    self.cellShareApp.textLabel.font = [UIFont boldSystemFontOfSize:16];
    self.cellShareApp.textLabel.textColor = [UIColor colorWithRed:0.300 green:0.431 blue:0.486 alpha:1];
    self.cellShareApp.textLabel.textAlignment = UITextAlignmentCenter;
    self.cellShareApp.textLabel.highlightedTextColor = [UIColor blackColor];
    self.cellShareApp.selectedBackgroundView = bgSelColorView;
    
    UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = self.cellShareApp.bounds;
    [button addTarget:self action:@selector(highlightShareAppCell:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
    [self.cellShareApp.contentView addSubview:button];
    
    
    self.cellViewFiles.backgroundView = [self bgCellView];
    self.cellViewFiles.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.cellViewFiles.textLabel.font = [UIFont boldSystemFontOfSize:16];
    self.cellViewFiles.textLabel.textColor = [UIColor colorWithRed:0.243 green:0.246 blue:0.267 alpha:1];
    self.cellViewFiles.textLabel.highlightedTextColor = [UIColor blackColor];
    self.cellViewFiles.selectedBackgroundView = bgSelColorView;
    
    button    = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = self.cellViewFiles.bounds;
    [button addTarget:self action:@selector(highlightViewFilesCell:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(viewFiles:) forControlEvents:UIControlEventTouchUpInside];
    [self.cellViewFiles.contentView addSubview:button];
    

    self.cellBlock.backgroundView = [self bgCellView];
    self.cellBlock.accessoryType = UITableViewCellAccessoryNone;
    self.cellBlock.textLabel.numberOfLines = 2;
    self.cellBlock.textLabel.font = [UIFont boldSystemFontOfSize:14];
    self.cellBlock.textLabel.textColor = [UIColor redColor];
    self.cellBlock.textLabel.highlightedTextColor = [UIColor blackColor];
    self.cellBlock.selectedBackgroundView = bgSelColorView;
    
    button    = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = self.cellBlock.bounds;
    [button addTarget:self action:@selector(highlightBlockCell:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(blockContact:) forControlEvents:UIControlEventTouchUpInside];
    [self.cellBlock.contentView addSubview:button];

    self.cellViewFiles.textLabel.text = NSLocalizedString(@"view_shared_files", @"view shared files");
    self.cellShareApp.textLabel.text = NSLocalizedString(@"share_app", @"share this app");
    self.cellBlock.textLabel.text = NSLocalizedString(@"block_person", @"block this person");
    
    if (!self.contact.isUser)
    {
        self.cellShareApp.hidden    = YES;
        self.cellViewFiles.hidden   = NO;
        self.cellBlock.hidden       = NO;
    }
    else
    {
        self.cellShareApp.hidden    = NO;
        self.cellViewFiles.hidden   = YES;
        self.cellBlock.hidden       = YES;        
    }
    
    [self updateBlockContactIndicator];
}

- (UIView*)bgCellView
{
    UIView *bgColorView = [UIView new];
    [bgColorView setBackgroundColor:[UIColor whiteColor]];
    bgColorView.layer.cornerRadius = 10;
    return bgColorView;
}

- (void)highlightShareAppCell:(UIButton*)sender
{
    self.cellShareApp.selected = YES;
}

- (void)highlightBlockCell:(UIButton*)sender
{
    self.cellBlock.selected = YES;
}

- (void)highlightViewFilesCell:(UIButton*)sender
{
    self.cellViewFiles.selected = YES;
}

- (void)shareApp:(UIButton*)sender
{
    self.cellShareApp.selected = NO;
    
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        picker.body = NSLocalizedString(@"share_sms", @"Get swiftly now....");
        picker.recipients = [NSArray arrayWithObjects:@"0796294179", nil];
        [self presentModalViewController:picker animated:YES];
    }
}

- (void)blockContact:(UIButton*)sender
{
    self.cellBlock.selected = NO;

    self.contact.isBlocked = !self.contact.isBlocked;
    [self updateBlockContactIndicator];
}

- (void)viewFiles:(UIButton*)sender
{
    self.cellViewFiles.selected = NO;

    SWAlbumThumbnailsViewController* newController = [[SWAlbumThumbnailsViewController alloc] init];
    newController.navigationItem.hidesBackButton = NO;
    [[self navigationController] pushViewController:newController animated:YES];
}

- (void)updateBlockContactIndicator
{
    self.cellBlock.accessoryType = (self.contact.isBlocked) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MessageComposeResultFailed:
            NSLog(@"Error");
			break;
		case MessageComposeResultSent:
            NSLog(@"OK");
			break;
		default:
			break;
	}
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
