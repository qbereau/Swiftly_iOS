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
    
    self.lblName.text = [self.contact name];
    //self.lblPhoneNumber.text = self.contact.phoneNumber;
    self.lblPhoneNumber.text = @"";
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
    self.cellShareApp.backgroundView = [SWTableViewCell backgroundView];
    self.cellShareApp.isGrouped = YES;
    self.cellShareApp.isLink = YES;
    self.cellShareApp.selectedBackgroundView = [SWTableViewCell backgroundHighlightedView];
    
    UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = self.cellShareApp.bounds;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button addTarget:self action:@selector(highlightShareAppCell:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
    [self.cellShareApp.contentView addSubview:button];
    
    
    self.cellViewFiles.backgroundView = [SWTableViewCell backgroundView];
    self.cellViewFiles.isGrouped = YES;
    self.cellViewFiles.selectedBackgroundView = [SWTableViewCell backgroundHighlightedView];
    
    button    = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = self.cellViewFiles.bounds;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;    
    [button addTarget:self action:@selector(highlightViewFilesCell:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(viewFiles:) forControlEvents:UIControlEventTouchUpInside];
    [self.cellViewFiles.contentView addSubview:button];
    

    self.cellBlock.backgroundView   = [SWTableViewCell backgroundView];
    self.cellBlock.isGrouped        = YES;
    self.cellBlock.isLink           = YES;
    self.cellBlock.isDestructive    = YES;
    self.cellBlock.selectedBackgroundView = [SWTableViewCell backgroundHighlightedView];
    
    button    = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = self.cellBlock.bounds;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;    
    [button addTarget:self action:@selector(highlightBlockCell:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(blockContact:) forControlEvents:UIControlEventTouchUpInside];
    [self.cellBlock.contentView addSubview:button];

    self.cellViewFiles.title.text = NSLocalizedString(@"view_shared_files", @"view shared files");
    self.cellShareApp.title.text = NSLocalizedString(@"share_app", @"share this app");
    self.cellBlock.title.text = NSLocalizedString(@"block_person", @"block this person");
    
    if (self.contact.isUser)
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

    [self.cellViewFiles setSelected:NO animated:NO];
    [self.cellShareApp setSelected:NO animated:NO];
    [self.cellBlock setSelected:NO animated:NO];
    
    [self updateBlockContactIndicator];
}

- (void)highlightShareAppCell:(UIButton*)sender
{
    self.cellShareApp.backgroundView = [SWTableViewCell backgroundHighlightedView];
}

- (void)highlightViewFilesCell:(UIButton*)sender
{
    self.cellViewFiles.backgroundView = [SWTableViewCell backgroundHighlightedView];
}

- (void)highlightBlockCell:(UIButton*)sender
{
    self.cellBlock.backgroundView = [SWTableViewCell backgroundHighlightedView];
}

- (void)shareApp:(UIButton*)sender
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        picker.body = NSLocalizedString(@"share_sms", @"Get swiftly now....");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY phoneNumbers.normalized == YES AND serverID = %d", self.contact.serverID];
        SWPhoneNumber* pn = (SWPhoneNumber*)[SWPerson MR_findAllWithPredicate:predicate];
        picker.recipients = [NSArray arrayWithObjects:pn.phoneNumber, nil];
        [self presentModalViewController:picker animated:YES];
    }
    
    self.cellShareApp.backgroundView = [SWTableViewCell backgroundView];    
}

- (void)blockContact:(UIButton*)sender
{
    RIButtonItem* btnCancel = [RIButtonItem item];
    btnCancel.label = NSLocalizedString(@"cancel", @"cancel");
    btnCancel.action = ^{
        self.cellBlock.backgroundView = [SWTableViewCell backgroundView];
    };
    
    RIButtonItem* btnYES = [RIButtonItem item];
    btnYES.label = [NSLocalizedString(@"yes", @"yes") uppercaseString];
    btnYES.action = ^{
        self.cellBlock.backgroundView = [SWTableViewCell backgroundView];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = NSLocalizedString(@"loading", @"loading");
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            NSString* uri = @"/accounts/block";
            if (self.contact.isBlocked)
                uri = @"/accounts/unblock";
            
            NSArray* arr_ids = [NSArray arrayWithObject:[NSNumber numberWithInt:self.contact.serverID]];
            NSDictionary* params = [NSDictionary dictionaryWithObject:arr_ids forKey:@"ids"];
            [[SWAPIClient sharedClient] putPath:uri
                                     parameters:params
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            self.contact.isBlocked = !self.contact.isBlocked;
                                            [self updateBlockContactIndicator];
                                        }
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];                                            
                                                UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                                                [av show];
                                            });
                                        }
             ];
        });

    };
    
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirmation", @"confirmation") message:NSLocalizedString(@"block_person_alert", @"he/she will not be able to....") cancelButtonItem:btnCancel otherButtonItems:btnYES, nil];
    [av show];
}

- (void)viewFiles:(UIButton*)sender
{
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         self.cellViewFiles.backgroundView.backgroundColor = [SWTableViewCell backgroundColor];
                     } 
                     completion:^(BOOL finished){
                        
                     }];
    
    SWAlbumThumbnailsViewController* newController = [[SWAlbumThumbnailsViewController alloc] init];
    newController.navigationItem.hidesBackButton = NO;
    newController.displayMode = ALBUM_THUMBNAIL_DISPLAY_MODE_CONTACT;
    newController.contact = self.contact;
    newController.allowAlbumEdition = NO;
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
