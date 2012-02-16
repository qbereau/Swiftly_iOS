//
//  SWPhotoScrollViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPhotoScrollViewController.h"

#define BUTTON_UNLINKPHOTO 0
#define BUTTON_DELETEPHOTO 1
#define BUTTON_CANCEL 2

#define ACTIONSHEET_TRASH 0
#define ACTIONSHEET_EXPORT 1

#define BUTTON_EXPORT_SAVE_PHOTO 0
#define BUTTON_EXPORT_FORWARD_PHOTO 1
#define BUTTON_EXPORT_CANCEL 2

@implementation SWPhotoScrollViewController

@synthesize comments = _comments;

- (id)initWithDataSource:(id<KTPhotoBrowserDataSource>)dataSource andStartWithPhotoAtIndex:(NSUInteger)index
{
    return [super initWithDataSource:dataSource andStartWithPhotoAtIndex:index];
}

- (void)loadView
{
    [super loadView];
    
    UIBarButtonItem* btnComments = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"menu_comments", @"comments"), 0] style:UIBarButtonItemStylePlain target:self action:@selector(comments:)];
    self.navigationItem.rightBarButtonItem = btnComments;
    
    [self updateExportPhotoButtonState];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self downloadComments];
}

- (void)downloadComments
{
    SWMedia* m = [((SWWebImagesDataSource*)dataSource_) mediaAtIndex:currentIndex_];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/medias/%d/comments", m.serverID]
                                 parameters:nil 
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       
                                        NSLog(@"%@", responseObject);
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error!");
                                    }
         ];   
    });    
}

- (void)comments:(UIBarButtonItem*)button
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self setStartWithIndex:self.currentIndex];
    
    SWCommmentsViewController* newController = [[SWCommmentsViewController alloc] init];
    newController.navigationItem.hidesBackButton = NO;
    newController.comments = self.comments;
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

    [actionSheet_ setTag:ACTIONSHEET_TRASH];
    [actionSheet showInView:[self view]];
}

- (void)update 
{
    [super update];

    [self updateExportPhotoButtonState];
}

- (void)updateExportPhotoButtonState
{
    // Check if the button exportPhoto should be here or not
    for (UIBarButtonItem* bbi in toolbar_.items)
    {
        if (bbi.action == @selector(exportPhoto))
        {
            [bbi setEnabled:[((SWWebImagesDataSource*)dataSource_) isMediaOpenAtIndex:currentIndex_]];
        }
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    SWMedia* m = [((SWWebImagesDataSource*)dataSource_) mediaAtIndex:currentIndex_];
    
    if ([actionSheet_ tag] == ACTIONSHEET_TRASH)
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
            [[SWAPIClient sharedClient] deletePath:[NSString stringWithFormat:@"/medias/%d%@", m.serverID, strUnlink]
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
    else if ([actionSheet_ tag] == ACTIONSHEET_EXPORT)
    {
        if (buttonIndex == BUTTON_EXPORT_SAVE_PHOTO)
        {
            if ([dataSource_ respondsToSelector:@selector(saveImageAtIndex:)])
                [dataSource_ saveImageAtIndex:currentIndex_];
        }
        else if (buttonIndex == BUTTON_EXPORT_FORWARD_PHOTO)
        {
            if ([dataSource_ respondsToSelector:@selector(forwardImageAtIndex:)])
                [dataSource_ forwardImageAtIndex:currentIndex_];        
        }
        
        [self startChromeDisplayTimer];
    }
    
}

@end
