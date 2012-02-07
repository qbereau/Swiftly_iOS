//
//  SWPhotoScrollViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPhotoScrollViewController.h"

@implementation SWPhotoScrollViewController

- (id)initWithDataSource:(id<KTPhotoBrowserDataSource>)dataSource andStartWithPhotoAtIndex:(NSUInteger)index
{
    return [super initWithDataSource:dataSource andStartWithPhotoAtIndex:index];
}

- (void)loadView
{
    [super loadView];
    
    UIBarButtonItem* btnComments = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"menu_comments", @"comments"), 5] style:UIBarButtonItemStylePlain target:self action:@selector(comments:)];
    self.navigationItem.rightBarButtonItem = btnComments;
    
    [self updateExportPhotoButtonState];
}

- (void)comments:(UIBarButtonItem*)button
{
    SWCommmentsViewController* newController = [[SWCommmentsViewController alloc] init];
    newController.navigationItem.hidesBackButton = NO;
    [[self navigationController] pushViewController:newController animated:YES];
}

- (void)trashPhoto 
{
    NSLog(@"[SWPhotoScrollViewController#trashPhoto] Should add 'Delete file' button only if user is owner of file");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel button text.")
                                               destructiveButtonTitle:NSLocalizedString(@"delete_file", @"Delete file button text.")
                                                    otherButtonTitles:NSLocalizedString(@"unlink_file", @"Unlink file"), nil];
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

@end
