//
//  SWRoundedRectView.m
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWRoundedRectView.h"

@implementation SWRoundedRectView

@synthesize strokeColor     = _strokeColor;
@synthesize rectColor       = _rectColor;
@synthesize strokeWidth     = _strokeWidth;
@synthesize cornerRadius    = _cornerRadius;

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
    {
        self.strokeColor = kDefaultStrokeColor;
        self.backgroundColor = [UIColor clearColor];
        self.strokeWidth = kDefaultStrokeWidth;
        self.rectColor = kDefaultRectColor;
        self.cornerRadius = kDefaultCornerRadius;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        // Initialization code
        self.opaque = NO;
        self.strokeColor = kDefaultStrokeColor;
        self.backgroundColor = [UIColor clearColor];
        self.rectColor = kDefaultRectColor;
        self.strokeWidth = kDefaultStrokeWidth;
        self.cornerRadius = kDefaultCornerRadius;
    }
    return self;
}
- (void)setBackgroundColor:(UIColor *)newBGColor
{
    // Ignore any attempt to set background color - backgroundColor must stay set to clearColor
    // We could throw an exception here, but that would cause problems with IB, since backgroundColor
    // is a palletized property, IB will attempt to set backgroundColor for any view that is loaded
    // from a nib, so instead, we just quietly ignore this.
    //
    // Alternatively, we could put an NSLog statement here to tell the programmer to set rectColor...
}
- (void)setOpaque:(BOOL)newIsOpaque
{
    // Ignore attempt to set opaque to YES.
}
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.strokeWidth);
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, self.rectColor.CGColor);
    
    CGRect rrect = self.bounds;
    
    CGFloat radius = self.cornerRadius;
    CGFloat width = CGRectGetWidth(rrect);
    CGFloat height = CGRectGetHeight(rrect);
    
    // Make sure corner radius isn't larger than half the shorter side
    if (radius > width/2.0)
        radius = width/2.0;
    if (radius > height/2.0)
        radius = height/2.0;    
    
    CGFloat minx = CGRectGetMinX(rrect);
    CGFloat midx = CGRectGetMidX(rrect);
    CGFloat maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect);
    CGFloat midy = CGRectGetMidY(rrect);
    CGFloat maxy = CGRectGetMaxY(rrect);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
