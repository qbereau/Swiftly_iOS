//
//  SWTableViewCell.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SWTableViewCell : UITableViewCell
{
    BOOL        _isGrouped;
    BOOL        _isSlider;    
    BOOL        _isLink;
    BOOL        _isDestructive;
    
    UILabel*    _lblTitle;
    UILabel*    _lblSubtitle;
}

@property (nonatomic, assign) BOOL      isGrouped;
@property (nonatomic, assign) BOOL      isSlider;
@property (nonatomic, assign) BOOL      isLink;
@property (nonatomic, assign) BOOL      isDestructive;
@property (nonatomic, strong) UILabel*  title;
@property (nonatomic, strong) UILabel*  subtitle;

- (void)setup;

+ (UIColor*)backgroundColor;
+ (UIColor*)highlightedBackgroundColor;
+ (UIView*)backgroundView;
+ (UIView*)backgroundHighlightedView;

@end
