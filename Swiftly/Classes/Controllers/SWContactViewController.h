//
//  SWContactViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SWAlbumThumbnailsViewController.h"
#import "SWPerson.h"

@interface SWContactViewController : UIViewController <MFMessageComposeViewControllerDelegate>
{
    SWPerson*               _contact;
}

@property (nonatomic, strong) SWPerson*         contact;

@property (weak, nonatomic) IBOutlet UILabel        *lblName;
@property (weak, nonatomic) IBOutlet UILabel        *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UIImageView    *thumbnail;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellViewFiles;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellShareApp;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellBlock;

- (void)setupCells;
- (void)updateBlockContactIndicator;

@end
