//
//  KTThumbView+SDWebImage.m
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTThumbView+SDWebImage.h"
#import "SDWebImageManager.h"

@implementation KTThumbView (SDWebImage)

+ (NSString*)cacheKeyForIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"medias/%d_thumbnail", index];
}

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
            //[self setThumbImage:placeholder];
        }
        
        if (url) {
            [manager downloadWithURL:url delegate:self];
        }
    }
}

- (void)setMedia:(SWMedia*)media placeholderImage:(UIImage *)placeholder
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString* cacheKey = [KTThumbView cacheKeyForIndex:media.serverID];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    UIImage *cachedImage = nil;
    if (media.thumbnailURL) {
        cachedImage = [manager imageWithCacheKey:cacheKey];
    }
    
    if (cachedImage) {
        [self setThumbImage:cachedImage];
    }
    else {
        if (placeholder) {
            //[self setThumbImage:placeholder];
        }
        
        if (media.thumbnailURL) {
            [manager downloadWithURL:[NSURL URLWithString:media.thumbnailURL] delegate:self cacheKey:cacheKey];
        }
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    [self setThumbImage:image];
}

@end
