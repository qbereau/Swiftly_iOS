//
//  SWWebImagesDataSource.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWWebImagesDataSource.h"
#import "KTPhotoView+SDWebImage.h"
#import "KTThumbView+SDWebImage.h"

#define MEDIA_TYPE_ALL      0
#define MEDIA_TYPE_IMAGE    1
#define MEDIA_TYPE_VIDEO    2


@implementation SWWebImagesDataSource

@synthesize mode = _mode;
@synthesize isDirty = _isDirty;
@synthesize allMedias = _allMedias;

- (void)resetFilter
{
    _mode = MEDIA_TYPE_ALL;
    if (self.allMedias)
    {
        _filteredMedias = self.allMedias;
    }
}

- (void)imageFilter
{
    _mode = MEDIA_TYPE_IMAGE;    
    if (self.allMedias)
    {
        NSMutableArray* arr = [NSMutableArray array];
        for (SWMedia* m in self.allMedias)
        {
            if (m.isImage)
                [arr addObject:m];
        }
        _filteredMedias = arr;
    }
}

- (void)videoFilter
{
    _mode = MEDIA_TYPE_VIDEO;
    if (self.allMedias)
    {
        NSMutableArray* arr = [NSMutableArray array];
        for (SWMedia* m in self.allMedias)
        {
            if (m.isVideo)
                [arr addObject:m];
        }
        _filteredMedias = arr;
    }
}

- (void)filterByCreatorID:(NSInteger)creator_id
{
    NSMutableArray* arr = [NSMutableArray array];
    for (SWMedia* m in self.allMedias)
    {
        if (m.creatorID == creator_id)
        {
            if (_mode == MEDIA_TYPE_ALL || 
                (_mode == MEDIA_TYPE_IMAGE && m.isImage) ||
                (_mode == MEDIA_TYPE_VIDEO && m.isVideo))
            {
                [arr addObject:m];
            }
        }
        
    }
    _filteredMedias = arr;
}

- (SWMedia*)mediaAtIndex:(NSInteger)index
{
    SWMedia* m = [_filteredMedias objectAtIndex:index];
    return m;
}

- (BOOL)isMediaOpenAtIndex:(NSInteger)index
{
    SWMedia* m = [_filteredMedias objectAtIndex:index];
    return m.isOpen;
}

- (BOOL)isOwner:(NSInteger)index
{
    SWMedia* m = [_filteredMedias objectAtIndex:index];
    return m.isOwner;
}

#pragma mark - KTPhotoBrowserDataSource

- (NSInteger)numberOfPhotos {
    NSInteger count = [_filteredMedias count];
    return count;
}

- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView {
    SWMedia* m = [_filteredMedias objectAtIndex:index];
    [photoView setMedia:m placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
}

- (BOOL)isVideoAtIndex:(NSInteger)index
{
    SWMedia* m = [_filteredMedias objectAtIndex:index];
    return m.isVideo;
}

- (void)mediaAtIndex:(NSInteger)index photoView:(KTPhotoView*)photoView 
{
    SWMedia* m = [_filteredMedias objectAtIndex:index];
    if (m.isImage)
        [self imageAtIndex:index photoView:photoView];
    else if (m.isVideo)
        [self videoAtIndex:index photoView:photoView];
}

- (void)videoAtIndex:(NSInteger)index photoView:(KTPhotoView*)photoView
{
    SWMedia* m = [_filteredMedias objectAtIndex:index];
    [photoView setVideoURL:[NSURL URLWithString:m.resourceURL]];
}

- (void)thumbImageAtIndex:(NSInteger)index thumbView:(KTThumbView *)thumbView {
    SWMedia* m = [_filteredMedias objectAtIndex:index];
    [thumbView setMedia:m placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];    
}

- (void)deleteImageAtIndex:(NSInteger)index
{
    SWMedia* m = [_filteredMedias objectAtIndex:index];
    
    self.isDirty = YES;
    [self.allMedias removeObjectAtIndex:index];
    _filteredMedias = self.allMedias;
    
    [m MR_deleteEntity];
}

- (void)saveImageAtIndex:(NSInteger)index
{
    SWMedia* m = [_filteredMedias objectAtIndex:index];
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:[NSURL URLWithString:m.assetURL] resultBlock:^(ALAsset *asset) {
        if (m.isImage)
        {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];

            UIImage *img = [manager imageWithCacheKey:[KTPhotoView cacheKeyForIndex:m.serverID]];
            
            [library writeImageToSavedPhotosAlbum:img.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {

            }];
        }
        else if (m.isVideo)
        {
            [library writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:m.resourceURL] completionBlock:^(NSURL *assetURL, NSError *error) {
                NSLog(@"Video Saved!");
                NSLog(@"Eror: %@", [error description]);
            }];
        }

    } failureBlock:^(NSError *error) {
        NSLog(@"Error: %@", [error description]);
    }];
}

- (void)showCommentsAtIndex:(NSInteger)index
{
    NSLog(@"comments");
}

- (void)isDirty:(BOOL)dirty
{
    self.isDirty = dirty;
}

@end
