//
//  Asset.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetTablePicker.h"

@implementation ELCAssetVideoView

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
    CGRect rectangle = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    CGContextAddRect(ctx, rectangle);
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetAlpha(ctx, 0.9);
    CGContextFillRect(ctx, rectangle);         
}

@end

@implementation ELCAsset

@synthesize asset;
@synthesize parent;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(id)initWithAsset:(ALAsset*)_asset {
	
	if (self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]) {
		
		self.asset = _asset;
		
		CGRect viewFrames = CGRectMake(0, 0, 75, 75);
		
		UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:viewFrames];
		[assetImageView setContentMode:UIViewContentModeScaleToFill];
		[assetImageView setImage:[UIImage imageWithCGImage:[self.asset thumbnail]]];
		[self addSubview:assetImageView];
		[assetImageView release];
        
        if ([[self.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo])
        {
            videoOverlayView = [[ELCAssetVideoView alloc] initWithFrame:CGRectMake(0, viewFrames.size.height - 15, viewFrames.size.width, 15)];
            videoOverlayView.duration = [[self.asset valueForProperty:ALAssetPropertyDuration] intValue];
            [self addSubview:videoOverlayView];
        }
		
		overlayView = [[UIImageView alloc] initWithFrame:viewFrames];
		[overlayView setImage:[UIImage imageNamed:@"Overlay.png"]];
		[overlayView setHidden:YES];
		[self addSubview:overlayView];
    }
    
	return self;	
}

-(void)toggleSelection {
    
	overlayView.hidden = !overlayView.hidden;
    
//    if([(ELCAssetTablePicker*)self.parent totalSelectedAssets] >= 10) {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maximum Reached" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//		[alert show];
//		[alert release];	
//
//        [(ELCAssetTablePicker*)self.parent doneAction:nil];
//    }
}

-(BOOL)selected {
	
	return !overlayView.hidden;
}

-(void)setSelected:(BOOL)_selected {
    
	[overlayView setHidden:!_selected];
}

- (void)dealloc 
{    
    self.asset = nil;
	[overlayView release];
    [videoOverlayView release];
    [super dealloc];
}

@end

