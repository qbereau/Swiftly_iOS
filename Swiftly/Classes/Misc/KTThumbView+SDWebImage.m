//
//  KTThumbView+SDWebImage.m
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTThumbView+SDWebImage.h"
#import "SDWebImageManager.h"

@implementation KTThumbView (SDWebImage)

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    UIImage *cachedImage = nil;
    if (url) {
        cachedImage = [manager imageWithURL:url];
    }
    
    if (cachedImage) {
        [self setThumbImage:cachedImage];
    }
    else {
        if (placeholder) {
            [self setThumbImage:placeholder];
        }
        
        if (url) {
            [manager downloadWithURL:url delegate:self];
        }
    }
}

- (void)setMedia:(SWMedia*)media placeholderImage:(UIImage *)placeholder
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    UIImage *cachedImage = nil;
    if (media.thumbnailURL) {
        cachedImage = [manager imageWithURL:[NSURL URLWithString:media.thumbnailURL]];
    }
    
    if (cachedImage) {
        [self setThumbImage:cachedImage];
    }
    else {
        if (placeholder) {
            [self setThumbImage:placeholder];
        }
        
        if (media.thumbnailURL) {
            [manager downloadWithURL:[NSURL URLWithString:media.thumbnailURL] delegate:self cacheKey:[NSString stringWithFormat:@"medias/%d_thumbnail", media.serverID]];
        }
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    [self setThumbImage:image];
}

@end
