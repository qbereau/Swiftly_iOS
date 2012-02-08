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

@synthesize images = _images;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.images = [[NSArray alloc] initWithObjects:
                       [NSArray arrayWithObjects:@"http://farm3.static.flickr.com/2735/4430131154_95212b8e88_o.jpg", @"http://farm3.static.flickr.com/2735/4430131154_17d8a02b8c_s.jpg", [NSNumber numberWithInt:0], nil],
                       [NSArray arrayWithObjects:@"http://farm5.static.flickr.com/4001/4439826859_19ba9a6cfa_o.jpg", @"http://farm5.static.flickr.com/4001/4439826859_4215c01a16_s.jpg", [NSNumber numberWithInt:0], nil],
                       [NSArray arrayWithObjects:@"http://farm4.static.flickr.com/3427/3192205971_0f494a3da2_o.jpg", @"http://farm4.static.flickr.com/3427/3192205971_b7b18558db_s.jpg", [NSNumber numberWithInt:0], nil],
                       [NSArray arrayWithObjects:@"http://farm2.static.flickr.com/1316/4722532733_6b73d00787_z.jpg", @"http://farm2.static.flickr.com/1316/4722532733_6b73d00787_s.jpg", [NSNumber numberWithInt:0], nil],
                       [NSArray arrayWithObjects:@"http://farm2.static.flickr.com/1200/591574815_8a4a732d00_o.jpg", @"http://farm2.static.flickr.com/1200/591574815_29db79a63a_s.jpg", [NSNumber numberWithInt:0], nil],
                       [NSArray arrayWithObjects:@"http://farm4.static.flickr.com/3610/3439180743_21b8799d82_o.jpg", @"http://farm4.static.flickr.com/3610/3439180743_b7b07df9d4_s.jpg", [NSNumber numberWithInt:0], nil],
                       [NSArray arrayWithObjects:@"http://smp.gatemedia.ch/screengate.mp4", @"http://farm3.static.flickr.com/2721/4441122896_eec9285a67_s.jpg", [NSNumber numberWithInt:1], nil], 
                       nil];
    }
    return self;
}

- (BOOL)isMediaOpenAtIndex:(NSInteger)index
{
    if (index % 2 == 0)
        return YES;
    return NO;
}

#pragma mark - KTPhotoBrowserDataSource

- (NSInteger)numberOfPhotos {
    NSInteger count = [self.images count];
    return count;
}

- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView {
    NSArray *imageUrls = [self.images objectAtIndex:index];
    NSString *url = [imageUrls objectAtIndex:0];
    [photoView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
}

- (void)mediaAtIndex:(NSInteger)index photoView:(KTPhotoView*)photoView 
{
    NSArray *imageUrls = [self.images objectAtIndex:index];
    if ([[imageUrls objectAtIndex:2] intValue] == MEDIA_TYPE_IMAGE)
    {
        [self imageAtIndex:index photoView:photoView];
    }
    else
    {
        [self videoAtIndex:index photoView:photoView];        
    }
}

- (void)videoAtIndex:(NSInteger)index photoView:(KTPhotoView*)photoView
{
    NSArray *imageUrls = [self.images objectAtIndex:index];
    NSString *url = [imageUrls objectAtIndex:0];
    [photoView setVideoURL:[NSURL URLWithString:url]];
}

- (void)thumbImageAtIndex:(NSInteger)index thumbView:(KTThumbView *)thumbView {
    NSArray *imageUrls = [self.images objectAtIndex:index];
    NSString *url = [imageUrls objectAtIndex:1];
    [thumbView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
}

- (void)deleteImageAtIndex:(NSInteger)index
{
    NSLog(@"delete");
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

@end
