//
//  KTThumbView.m
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/3/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "KTThumbView.h"
#import "KTThumbsViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation KTThumbVideoView

@synthesize duration = _duration;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _lblDuration = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 12, frame.size.width - 5, 10)];
        _lblDuration.text = @"";
        _lblDuration.backgroundColor = [UIColor clearColor];
        _lblDuration.textColor = [UIColor whiteColor];
        _lblDuration.textAlignment = UITextAlignmentRight;
        _lblDuration.font = [UIFont boldSystemFontOfSize:12];
        [self addSubview:_lblDuration];
        
        _camera = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera.png"]];
        _camera.frame = CGRectMake(6, frame.size.height - 12, 16, 8);
        _camera.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_camera];

        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setDuration:(int)duration
{
    _duration = duration;
    
    long min = (long)duration / 60;
    long sec = (long)duration % 60;    
    _lblDuration.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rectangle = CGRectMake(0, self.bounds.size.height - 15, self.bounds.size.width, 15);
    CGContextAddRect(ctx, rectangle);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor);
    CGContextFillRect(ctx, rectangle);
}

@end

@implementation KTThumbView

@synthesize controller = controller_;
@synthesize videoOverlayView = _videoOverlayView;

- (void)dealloc 
{
   [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame]) {

      [self addTarget:self
               action:@selector(didTouch:)
     forControlEvents:UIControlEventTouchUpInside];
      
      [self setClipsToBounds:YES];
       
       longPressGR_ = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
       longPressGR_.minimumPressDuration = 1.0;
       [self addGestureRecognizer:longPressGR_];

      // If the thumbnail needs to be scaled, it should mantain its aspect
      // ratio.
      [[self imageView] setContentMode:UIViewContentModeScaleAspectFill];
       
       _videoOverlayView = [[KTThumbVideoView alloc] initWithFrame:CGRectMake(0, 60, 75, 15)];
       _videoOverlayView.duration = 0;
       _videoOverlayView.hidden = YES;
       [self insertSubview:_videoOverlayView aboveSubview:self.imageView];       
       
       spinner_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
       [spinner_ startAnimating];
       [self addSubview:spinner_];
   }
   return self;
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)gesture
{
    if (controller_)
    {
        [controller_ didLongPressThumbAtIndex:[self tag]];
    }
}

- (void)didTouch:(id)sender 
{
   if (controller_) {
      [controller_ didSelectThumbAtIndex:[self tag]];
   }
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    [spinner_ setFrame:[self bounds]];
}

- (void)setThumbImage:(UIImage *)newImage 
{
    [spinner_ stopAnimating];
    [self setImage:newImage forState:UIControlStateNormal];
}

- (void)setHasBorder:(BOOL)hasBorder
{
   if (hasBorder) {
      self.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
      self.layer.borderWidth = 1;
   } else {
      self.layer.borderColor = nil;
   }
}

@end
