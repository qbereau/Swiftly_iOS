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
    
    SWWebImagesDataSource*      _mediaDS;
    
    BOOL                        _allowAlbumEditition;
    UIActionSheet*              _actionSheet;
    
    SWMedia*                    _longPressMedia;
    
    NSOperationQueue*           _operationQueue;
}

@property (nonatomic, strong) SWAlbum*                  selectedAlbum;
@property (nonatomic, strong) NSMutableArray*           arrMedias;
@property (nonatomic, strong) SWWebImagesDataSource*    mediaDS;
@property (nonatomic, strong) NSOperationQueue*         operationQueue;
@property (nonatomic, assign) BOOL                      allowAlbumEdition;

- (void)updateMedias:(NSDictionary*)dict;
- (void)finishedUpdateMedias;
- (void)reload;

@end
