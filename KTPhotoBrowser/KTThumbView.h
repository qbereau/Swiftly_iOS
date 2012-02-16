//
//  KTThumbView.h
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/3/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTThumbVideoView : UIView
{
    int             _duration;
    
    UILabel*        _lblDuration;
    UIImageView*    _camera;
}

@property (nonatomic, assign) int   duration;

@end

@class KTThumbsViewController;

@interface KTThumbView : UIButton <UIGestureRecognizerDelegate> 
{
@private
    KTThumbsViewController *controller_;
    UILongPressGestureRecognizer *longPressGR_;
}

@property (nonatomic, assign) KTThumbsViewController *controller;

- (id)initWithFrame:(CGRect)frame;
- (void)setThumbImage:(UIImage *)newImage;
- (void)setHasBorder:(BOOL)hasBorder;

@end

