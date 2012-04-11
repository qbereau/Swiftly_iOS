//
//  SWPhotoScrollViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPhotoScrollViewController.h"

#import "SWAlbumEditViewController.h"

#define BUTTON_DELETEPHOTO 0
#define BUTTON_UNLINKPHOTO 1
#define BUTTON_CANCEL 2

#define ACTIONSHEET_TRASH 0
#define ACTIONSHEET_EXPORT 1

#define BUTTON_EXPORT_FORWARD_PHOTO 0
#define BUTTON_EXPORT_SAVE_PHOTO 1
#define BUTTON_EXPORT_CANCEL 2

@implementation SWPhotoScrollViewController

- (id)initWithDataSource:(id<KTPhotoBrowserDataSource>)dataSource andStartWithPhotoAtIndex:(NSUInteger)index
{
    return [super initWithDataSource:dataSource andStartWithPhotoAtIndex:index];
}

- (void)loadView
{
    [super loadView];
    
    [self updateExportPhotoButtonState];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateExportPhotoButtonState];    
}

- (void)comments:(UIBarButtonItem*)button
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self setStartWithIndex:self.currentIndex];
    
    SWCommmentsViewController* newController = [[SWCommmentsViewController alloc] init];
    newController.navigationItem.hidesBackButton = NO;
    newController.media = [((SWWebImagesDataSource*)dataSource_) mediaAtIndex:currentIndex_];
    [[self navigationController] pushViewController:newController animated:YES];
}

- (void)trashPhoto 
{
    SWMedia* m = [((SWWebImagesDataSource*)dataSource_) mediaAtIndex:currentIndex_];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel button text.")
                                               destructiveButtonTitle:(m.isOwner ? NSLocalizedString(@"delete_file", @"Delete file button text.") : nil)
                                                    otherButtonTitles:NSLocalizedString(@"unlink_file", @"Unlink file"), nil];

    [actionSheet setTag:ACTIONSHEET_TRASH];
    [actionSheet showInView:[self view]];
}

- (void)update 
{
    [super update];

    [self updateExportPhotoButtonState];
}

- (void)updateExportPhotoButtonState
{
    SWMedia* m = [((SWWebImagesDataSource*)dataSource_) mediaAtIndex:currentIndex_];    
    UIBarButtonItem* btnComments = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"menu_comments", @"comments"), m.nbComments] style:UIBarButtonItemStylePlain target:self action:@selector(comments:)];
    self.navigationItem.rightBarButtonItem = btnComments;
    
    
    // Check if the button exportPhoto should be here or not
    for (UIBarButtonItem* bbi in toolbar_.items)
    {
        if (bbi.action == @selector(exportPhoto))
        {
            BOOL enabled = [((SWWebImagesDataSource*)dataSource_) isMediaOpenAtIndex:currentIndex_] || [((SWWebImagesDataSource*)dataSource_) isOwner:currentIndex_];
            [bbi setEnabled:enabled];
        }
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    SWMedia* m = [((SWWebImagesDataSource*)dataSource_) mediaAtIndex:currentIndex_];
    
    if ([actionSheet tag] == ACTIONSHEET_TRASH)
    {
        NSString* strUnlink = @"";
        BOOL shouldRemove = NO;
        if (buttonIndex == BUTTON_DELETEPHOTO) 
        {
            shouldRemove = YES;
        }
        else if (buttonIndex == BUTTON_UNLINKPHOTO)
        {
            shouldRemove = YES;            
            strUnlink = @"?unlink";
        }
        
        if (shouldRemove)
        {
            [[SWAPIClient sharedClient] deletePath:[NSString stringWithFormat:@"/nodes/%d%@", m.serverID, strUnlink]
                                        parameters:nil 
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               [super deleteCurrentPhoto];
                                           }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                                               [av show];
                                           }
             ];
        }
        
        [self startChromeDisplayTimer];
    }
    else if ([actionSheet tag] == ACTIONSHEET_EXPORT)
    {
        if (buttonIndex == BUTTON_EXPORT_SAVE_PHOTO)
        {
            if ([dataSource_ respondsToSelector:@selector(saveImageAtIndex:)])
                [dataSource_ saveImageAtIndex:currentIndex_];
        }
        else if (buttonIndex == BUTTON_EXPORT_FORWARD_PHOTO)
        {     
            SWMedia* m = [((SWWebImagesDataSource*)dataSource_) mediaAtIndex:currentIndex_];
            
            SWAlbumEditViewController* vc = [[SWAlbumEditViewController alloc] initWithStyle:UITableViewStyleGrouped];
            vc.filesToUpload = [NSArray arrayWithObject:m];
            vc.mode = SW_ALBUM_MODE_QUICK_SHARE;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        [self startChromeDisplayTimer];
    }
    
}

@end
