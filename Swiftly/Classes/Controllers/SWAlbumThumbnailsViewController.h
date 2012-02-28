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
}

@property (nonatomic, strong) SWAlbum*                  selectedAlbum;
@property (nonatomic, strong) NSMutableArray*           arrMedias;
@property (nonatomic, strong) NSMutableArray*           arrBeforeSyncMedias;
@property (nonatomic, strong) SWWebImagesDataSource*    mediaDS;
@property (nonatomic, strong) NSOperationQueue*         operationQueue;
@property (nonatomic, assign) BOOL                      allowAlbumEdition;

- (void)updateMediasWithDict:(NSDictionary*)dict;
- (void)updateMedias:(id)reponseObject;
- (void)reload;

@end
