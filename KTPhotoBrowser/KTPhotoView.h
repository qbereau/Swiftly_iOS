//
//  KTPhotoView.h
//  Sample
//
//  Created by Kirby Turner on 2/24/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class KTPhotoScrollViewController;


@interface KTPhotoView : UIScrollView <UIScrollViewDelegate>
{
   UIImageView *imageView_;
   KTPhotoScrollViewController *scroller_;
   NSInteger index_;
    
    
    MPMoviePlayerController*        moviePlayer_;
}

@property (nonatomic, assign) KTPhotoScrollViewController *scroller;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) MPMoviePlayerController* moviePlayer;

- (void)setImage:(UIImage *)newImage;
- (void)setVideoURL:(NSURL*)url;
- (void)turnOffZoom;
- (void)launch;

- (CGPoint)pointToCenterAfterRotation;
- (CGFloat)scaleToRestoreAfterRotation;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;


@end
