//
//  SWTableViewCell.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWTableViewCell.h"

@implementation SWTableViewCell

@synthesize isGrouped   = _isGrouped;
@synthesize isSingle    = _isSingle;
@synthesize isTop       = _isTop;
@synthesize isMiddle    = _isMiddle;
@synthesize isBottom    = _isBottom;
@synthesize isLink      = _isLink;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setIsSingle:(BOOL)isSingle
{
    _isSingle = isSingle;
    
    if (_isSingle)
    {
        _isTop      = NO;
        _isMiddle   = NO;
        _isBottom   = NO;
    }
}

- (void)setIsTop:(BOOL)isTop
{
    _isTop = isTop;
    
    if (_isTop)
    {
        _isSingle = NO;
        _isMiddle = NO;
        _isBottom = NO;
    }
}

- (void)setIsMiddle:(BOOL)isMiddle
{
    _isMiddle = isMiddle;
    
    if (_isMiddle)
    {
        _isSingle   = NO;
        _isTop      = NO;
        _isBottom   = NO;
    }
}

- (void)setIsBottom:(BOOL)isBottom
{
    _isBottom = isBottom;
    
    if (_isBottom)
    {
        _isSingle   = NO;
        _isTop      = NO;
        _isMiddle   = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    self.textLabel.textColor = [UIColor colorWithRed:0.243 green:0.246 blue:0.267 alpha:1];
    self.detailTextLabel.textColor = [UIColor colorWithRed:0.412 green:0.404 blue:0.447 alpha:1];
    self.textLabel.highlightedTextColor = [UIColor colorWithRed:0.243 green:0.246 blue:0.267 alpha:1];
    self.detailTextLabel.highlightedTextColor = [UIColor colorWithRed:0.412 green:0.404 blue:0.447 alpha:1];

    self.textLabel.shadowOffset = CGSizeMake(1, 1);
    self.textLabel.shadowColor = [UIColor whiteColor];
    self.detailTextLabel.shadowOffset = CGSizeMake(1, 1);
    self.detailTextLabel.shadowColor = [UIColor whiteColor];
    
    self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.detailTextLabel.numberOfLines = 2;
    
    if (self.isGrouped)
    {
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.font = [UIFont systemFontOfSize:12];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.numberOfLines = 2;
        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, 150, self.textLabel.frame.size.height);  
        
        if (self.isLink)
        {
            self.accessoryType = UITableViewCellAccessoryNone;
            self.textLabel.font = [UIFont boldSystemFontOfSize:14];
            self.textLabel.textColor = [UIColor colorWithRed:0.300 green:0.431 blue:0.486 alpha:1];
        }
        
        if (self.isSingle)
            self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_view_cell_grouped_single"]];
        else if (self.isTop)
            self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_view_cell_grouped_top"]];
        else if (self.isMiddle)
            self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_view_cell_grouped_middle"]];
        else if (self.isBottom)
            self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_view_cell_grouped_bottom"]];        
    }
    else
    {
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithRed:0.843 green:0.843 blue:0.843 alpha:1]];
        self.selectedBackgroundView = bgColorView;

        self.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"table_view_cell_unselected.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] ];
    }

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isLink)
    {
        self.textLabel.frame = CGRectMake(self.frame.size.width / 2 - self.textLabel.frame.size.width / 2, self.textLabel.frame.origin.y, self.frame.size.width, self.textLabel.frame.size.height);
    }
}

@end
