//
//  SWAlbumThumbnailsViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWAlbum.h"
#import "KTThumbsViewController.h"
#import "SWWebImagesDataSource.h"
#import "SWPhotoScrollViewController.h"
#import "SWAlbumEditViewController.h"

#define ALBUM_THUMBNAIL_DISPLAY_MODE_ALBUM      0
#define ALBUM_THUMBNAIL_DISPLAY_MODE_CONTACT    1

@interface SWAlbumThumbnailsViewController : KTThumbsViewController
{
    SWAlbum*                    _selectedAlbum;
    
    NSMutableArray*             _arrMedias;
    NSMutableArray*             _arrBeforeSyncMedias;
    
    SWWebImagesDataSource*      _mediaDS;
    
    BOOL                        _allowAlbumEditition;
    UIActionSheet*              _actionSheet;
    
    SWMedia*                    _longPressMedia;
    
    NSOperationQueue*           _operationQueue;
    BOOL                        _shouldUpdate;
    
    NSInteger                   _displayMode;
    SWPerson*                   _contact;
    
    NSInteger                   _opReq;
}

@property (nonatomic, strong) SWPerson*                 contact;
@property (nonatomic, strong) SWAlbum*                  selectedAlbum;
@property (nonatomic, strong) NSMutableArray*           arrMedias;
@property (nonatomic, strong) NSMutableArray*           arrBeforeSyncMedias;
@property (nonatomic, strong) SWWebImagesDataSource*    mediaDS;
@property (nonatomic, strong) NSOperationQueue*         operationQueue;
@property (nonatomic, assign) BOOL                      allowAlbumEdition;
@property (nonatomic, assign) NSInteger                 displayMode;
@property (nonatomic, assign) NSInteger                 opReq;

- (void)updateMediasWithDict:(NSDictionary*)dict;
- (void)reload;
- (void)cleanup;

@end
