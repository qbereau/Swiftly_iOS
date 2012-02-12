//
//  Asset.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

@interface ELCAssetVideoView : UIView
{
    int             _duration;
    
    UILabel*        _lblDuration;
    UIImageView*    _camera;
}

@property (nonatomic, assign) int   duration;

@end

@interface ELCAsset : UIView {
	ALAsset *asset;
	UIImageView *overlayView;
	BOOL selected;
	id parent;
    ELCAssetVideoView* videoOverlayView;
}

@property (nonatomic, retain) ALAsset *asset;
@property (nonatomic, assign) id parent;

-(id)initWithAsset:(ALAsset*)_asset;
-(BOOL)selected;
-(void)setSelected:(BOOL)_selected;

@end