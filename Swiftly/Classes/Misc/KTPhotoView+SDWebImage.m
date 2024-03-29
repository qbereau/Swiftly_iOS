//
//  KTPhotoView+SDWebImage.m
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTPhotoView+SDWebImage.h"
#import "SDWebImageManager.h"

@implementation KTPhotoView (SDWebImage)

+ (NSString*)cacheKeyForIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"medias/%d", index];
}

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder 
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    UIImage *cachedImage = nil;
    if (url) {
        cachedImage = [manager imageWithURL:url];
    }
    
    if (cachedImage) {
        [self setImage:cachedImage];
    }
    else {
        if (placeholder) {
            //[self setImage:placeholder];
        }
        
        if (url) {
            [manager downloadWithURL:url delegate:self];
        }
    }
}

- (void)setMedia:(SWMedia*)media placeholderImage:(UIImage *)placeholder
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString* cacheKey = [KTPhotoView cacheKeyForIndex:media.serverID];
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    UIImage *cachedImage = nil;
    if (media.resourceURL) {
        cachedImage = [manager imageWithCacheKey:cacheKey];
    }
    
    if (cachedImage) {
        [self setImage:cachedImage];
    }
    else {
        if (placeholder) {
            //[self setImage:placeholder];
        }
        
        if (media.resourceURL) {
            [manager downloadWithURL:[NSURL URLWithString:media.resourceURL] delegate:self cacheKey:cacheKey];
        }
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    [self setImage:image];
}

@end