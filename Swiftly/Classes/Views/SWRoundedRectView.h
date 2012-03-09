//
//  SWRoundedRectView.h
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDefaultStrokeColor         [UIColor whiteColor]
#define kDefaultRectColor           [UIColor whiteColor]
#define kDefaultStrokeWidth         1.0
#define kDefaultCornerRadius        30.0

@interface SWRoundedRectView : UIView
{
    UIColor     *_strokeColor;
    UIColor     *_rectColor;
    CGFloat     _strokeWidth;
    CGFloat     _cornerRadius;
}

@property (strong, nonatomic) UIColor *strokeColor;
@property (strong, nonatomic) UIColor *rectColor;
@property CGFloat strokeWidth;
@property CGFloat cornerRadius;

@end
