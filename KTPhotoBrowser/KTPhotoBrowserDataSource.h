//
//  KTPhotoBrowserDataSource.h
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/7/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KTPhotoView;
@class KTThumbView;

@protocol KTPhotoBrowserDataSource <NSObject>
@required
- (NSInteger)numberOfPhotos;

@optional

// Implement either these, for synchronous images…
- (UIImage *)imageAtIndex:(NSInteger)index;
- (UIImage *)thumbImageAtIndex:(NSInteger)index;

// …or these, for asynchronous images.
- (void)mediaAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView;
- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView;
- (void)videoAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView;
- (void)thumbImageAtIndex:(NSInteger)index thumbView:(KTThumbView *)thumbView;

- (void)deleteImageAtIndex:(NSInteger)index;
- (void)forwardImageAtIndex:(NSInteger)index;
- (void)saveImageAtIndex:(NSInteger)index;

- (CGSize)thumbSize;
- (NSInteger)thumbsPerRow;
- (BOOL)thumbsHaveBorder;
- (UIColor *)imageBackgroundColor;

- (BOOL)isDirty;
- (void)isDirty:(BOOL)dirty;

@end
