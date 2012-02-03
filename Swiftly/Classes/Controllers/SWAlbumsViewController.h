//
//  SWFirstViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWAlbum.h"
#import "SWAlbumThumbnailsViewController.h"
#import "SWTableViewController.h"
#import "SWTableViewCell.h"

@interface SWAlbumsViewController : SWTableViewController
{
    NSMutableArray*                 _albums;
}

@property (nonatomic, strong) NSMutableArray*           albums;

@end
