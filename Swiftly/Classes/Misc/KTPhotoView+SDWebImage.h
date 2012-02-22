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

- (void)setImageWithMedia:(SWMedia*)media placeholderImage:(UIImage *)placeholder;

@end