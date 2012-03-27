//
//  SWContactViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "UIAlertView+Blocks.h"
#import "SWTableViewCell.h"
#import "SWAlbumThumbnailsViewController.h"
#import "SWPerson.h"

@interface SWContactViewController : UIViewController <MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) SWPerson *        contact;



@property (weak, nonatomic) IBOutlet UILabel        *lblName;
@property (weak, nonatomic) IBOutlet UILabel        *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UIImageView    *thumbnail;

@property (weak, nonatomic) IBOutlet SWTableViewCell *cellViewFiles;
@property (weak, nonatomic) IBOutlet SWTableViewCell *cellShareApp;
@property (weak, nonatomic) IBOutlet SWTableViewCell *cellBlock;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

- (void)setupCells;
- (void)updateBlockContactIndicator;

@end
