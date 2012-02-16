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

#define MEDIA_TYPE_IMAGE 0
#define MEDIA_TYPE_VIDEO 1

@implementation SWWebImagesDataSource

@synthesize isDirty = _isDirty;
@synthesize allMedias = _allMedias;

- (void)resetFilter
{
    if (self.allMedias)
    {
        _filteredMedias = self.allMedias;
    }
}

- (void)imageFilter
{
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

#pragma mark - KTPhotoBrowserDataSource

- (NSInteger)numberOfPhotos {
    NSInteger count = [_filteredMedias count];
    return count;
}

- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView {
    SWMedia* m = [_filteredMedias objectAtIndex:index];
    [photoView setImageWithURL:[NSURL URLWithString:m.resourceURL] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
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
    [thumbView setImageWithURL:[NSURL URLWithString:m.thumbnailURL] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
}

- (void)deleteImageAtIndex:(NSInteger)index
{
    self.isDirty = YES;
    [self.allMedias removeObjectAtIndex:index];
    _filteredMedias = self.allMedias;
}

- (void)forwardImageAtIndex:(NSInteger)index
{
    NSLog(@"forward");
}

- (void)saveImageAtIndex:(NSInteger)index
{
    NSLog(@"save");
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
