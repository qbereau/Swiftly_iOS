//
//  KTThumbView.h
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/3/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class KTThumbsViewController;

@interface KTThumbVideoView : UIView
{
    int             _duration;
    
    UILabel*        _lblDuration;
    UIImageView*    _camera;
}

@property (nonatomic, assign) int   duration;

@end

@interface KTThumbView : UIButton <UIGestureRecognizerDelegate> 
{
@private
    KTThumbsViewController *controller_;
    UILongPressGestureRecognizer *longPressGR_;
    KTThumbVideoView*               _videoOverlayView;
        UIActivityIndicatorView*        spinner_;
}

@property (nonatomic, assign) KTThumbsViewController *controller;
@property (nonatomic, assign) KTThumbVideoView *videoOverlayView;

- (id)initWithFrame:(CGRect)frame;
- (void)setThumbImage:(UIImage *)newImage;
- (void)setHasBorder:(BOOL)hasBorder;

@end