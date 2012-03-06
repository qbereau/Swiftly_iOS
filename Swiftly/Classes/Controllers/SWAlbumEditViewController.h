//
//  SWAlbumEditViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAlertView+Blocks.h"
#import "SWPeopleListViewController.h"
#import "SWActivitiesViewController.h"
#import "SWAlbum.h"
#import "SWAlbum+Details.h"
#import "SWPerson.h"
#import "SWPerson+Details.h"
#import "SWTableView.h"
#import "SWTableViewCell.h"

#import "KVPasscodeViewController.h"

#define SW_ALBUM_MODE_EDIT          0
#define SW_ALBUM_MODE_CREATE        1
#define SW_ALBUM_MODE_LINK          2
#define SW_ALBUM_MODE_QUICK_SHARE   3

typedef void (^UploadMediasBlock)(SWAlbum*, BOOL);

@interface SWAlbumEditViewController : UITableViewController <UITextFieldDelegate, SWPeopleListViewControllerDelegate, KVPasscodeViewControllerDelegate>
{
    SWAlbum*            _album;
    NSInteger           _mode;
    
    // Create, Link, Quick Share Modes
    NSArray*            _filesToUpload;
    
    // Link Mode
    SWAlbum*            _selectedLinkedAlbum;
    BOOL                _canExportMediasForLinkedAlbum;
    
    // Quick Share
    NSArray*            _quickSharePeople;
    
    // Datasource
    NSArray*            _linkableAlbums;
    
    
    UploadMediasBlock   _uploadMediasBlock;
    GenericFailureBlock _genericFailureBlock;
    
    
    NSNumber*           _newAlbumLock;
    BOOL                _shouldLockAlbumBeingEditedOrCreated;
    
    UITextField*        _inputAlbumName;
}

@property (strong, nonatomic) UITextField*          inputAlbumName;
@property (nonatomic, strong) SWAlbum*              album;
@property (nonatomic, strong) NSArray*              filesToUpload;
@property (nonatomic, assign) NSInteger             mode;
@property (nonatomic, strong) NSArray*              linkableAlbums;
@property (nonatomic, copy)   UploadMediasBlock     uploadMediasBlock;
@property (nonatomic, copy)   GenericFailureBlock   genericFailureBlock;

- (void)updateTitleAfterAnimation:(NSTimer*)timer;
- (void)dismissController:(NSTimer*)timer;
- (void)cleanupAlbum:(BOOL)shouldUnlink;
- (void)deleteAlbum:(BOOL)shouldUnlink;

@end
