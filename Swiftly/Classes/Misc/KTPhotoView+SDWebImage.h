//
//  KTPhotoView+SDWebImage.h
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTPhotoView.h"
#import "SDWebImageManagerDelegate.h"
#import "SWMedia.h"

@interface KTPhotoView (SDWebImage) <SDWebImageManagerDelegate>

+ (NSString*)cacheKeyForIndex:(NSInteger)index;

- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)setMedia:(SWMedia*)media placeholderImage:(UIImage *)placeholder;
//- (void)setImageWithMedia:(SWMedia*)media placeholderImage:(UIImage *)placeholder;

@end