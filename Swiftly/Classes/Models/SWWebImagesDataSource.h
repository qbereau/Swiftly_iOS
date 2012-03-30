//
//  SWWebImagesDataSource.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "SDWebImageManager.h"
#import "SDWebImageManagerDelegate.h"
#import "KTPhotoBrowserDataSource.h"
#import "SWPhotoScrollViewController.h"
#import "SWMedia.h"
#import "SWAPIClient.h"

@interface SWWebImagesDataSource : NSObject <KTPhotoBrowserDataSource, SDWebImageManagerDelegate>
{
    NSMutableArray*             _allMedias;
    NSArray*                    _filteredMedias;
    
    BOOL                        _isDirty;
    NSInteger                   _mode;
}

@property (nonatomic, strong) NSMutableArray*   allMedias;
@property (nonatomic, assign) BOOL              isDirty;
@property (nonatomic, assign) NSInteger         mode;

- (void)resetFilter;
- (void)imageFilter;
- (void)videoFilter;

- (void)filterByCreatorID:(NSInteger)creator_id;
- (SWMedia*)mediaAtIndex:(NSInteger)index;
- (BOOL)isMediaOpenAtIndex:(NSInteger)index;
- (BOOL)isOwner:(NSInteger)index;

@end
