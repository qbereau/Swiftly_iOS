//
//  KTThumbView+SDWebImage.h
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTThumbView.h"
#import "SDWebImageManagerDelegate.h"
#import "SWMedia.h"

@interface  KTThumbView (SDWebImage) <SDWebImageManagerDelegate>

- (void)setImageWithMedia:(SWMedia*)media placeholderImage:(UIImage *)placeholder;

@end
