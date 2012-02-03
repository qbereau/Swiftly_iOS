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

@interface SWAlbumThumbnailsViewController : KTThumbsViewController
{
    SWAlbum*                    _selectedAlbum;
    
    SWWebImagesDataSource*      _medias;
}

@property (nonatomic, strong) SWAlbum*                  selectedAlbum;
@property (nonatomic, strong) SWWebImagesDataSource*    medias;

@end
