//
//  SWTableViewCell.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWTableViewCell.h"

@implementation SWTableViewCell

@synthesize isGrouped       = _isGrouped;
@synthesize isSlider        = _isSlider;
@synthesize isLink          = _isLink;
@synthesize isDestructive   = _isDestructive;
@synthesize title           = _lblTitle;
@synthesize subtitle        = _lblSubtitle;

+ (UIColor*)backgroundColor
{
    return [UIColor whiteColor];
}

+ (UIColor*)highlightedBackgroundColor
{
    return [UIColor colorWithRed:0.745 green:0.745 blue:0.745 alpha:1];
}

+ (UIView*)backgroundView
{
    UIView *bgView = [UIView new];
    [bgView setBackgroundColor:[SWTableViewCell backgroundColor]];
    bgView.layer.cornerRadius = 10;
    return bgView;
}

+ (UIView*)backgroundHighlightedView
{
    UIView *bgView = [UIView new];
    [bgView setBackgroundColor:[SWTableViewCell highlightedBackgroundColor]];
    bgView.layer.cornerRadius = 10;
    return bgView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.title      = [UILabel new];
    self.subtitle   = [UILabel new];
    
    [self addSubview:self.title];
    [self addSubview:self.subtitle];    
}

- (void)setIsLink:(BOOL)isLink
{
    _isLink = isLink;
    
    if (_isLink)
    {
        _isSlider = NO;
    }
}

- (void)setIsSlider:(BOOL)isSlider
{
    _isSlider = isSlider;
    
    if (_isSlider)
    {
        _isLink = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.title.backgroundColor = [UIColor clearColor];
    self.subtitle.backgroundColor = [UIColor clearColor];
    
    self.title.textColor = [UIColor colorWithRed:0.243 green:0.246 blue:0.267 alpha:1];
    self.subtitle.textColor = [UIColor colorWithRed:0.412 green:0.404 blue:0.447 alpha:1];
    self.title.highlightedTextColor = [UIColor colorWithRed:0.243 green:0.246 blue:0.267 alpha:1];
    self.subtitle.highlightedTextColor = [UIColor colorWithRed:0.412 green:0.404 blue:0.447 alpha:1];
    
    self.title.shadowOffset = CGSizeMake(1, 1);
    self.title.shadowColor = [UIColor whiteColor];
    self.subtitle.shadowOffset = CGSizeMake(1, 1);
    self.subtitle.shadowColor = [UIColor whiteColor];
    
    self.subtitle.font = [UIFont systemFontOfSize:12];
    
    if (self.isGrouped)
    {
        self.title.font = [UIFont systemFontOfSize:14];
        
        self.title.backgroundColor = [UIColor clearColor];
        self.subtitle.backgroundColor = [UIColor clearColor];
        
        self.title.numberOfLines = 2;
        self.title.textAlignment = UITextAlignmentLeft;
        self.subtitle.textAlignment = UITextAlignmentLeft;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.isLink)
        {
            self.accessoryType  = UITableViewCellAccessoryNone;
            self.selectionStyle = UITableViewCellSelectionStyleGray;
            
            self.title.textAlignment    = UITextAlignmentCenter;
            self.subtitle.textAlignment = UITextAlignmentCenter;
            
            self.title.font = [UIFont boldSystemFontOfSize:14];
            
            if (self.isDestructive)
            {
                self.title.textColor = [UIColor redColor];
                self.subtitle.textColor = [UIColor redColor];
            }
            else
            {
                self.title.textColor = [UIColor colorWithRed:0.300 green:0.431 blue:0.486 alpha:1];
            }

            self.title.highlightedTextColor = self.title.textColor;
            self.subtitle.highlightedTextColor = self.subtitle.textColor;
            
            if (selected)
            {
                self.title.shadowOffset = CGSizeMake(0, 0);
                self.title.shadowColor = [UIColor clearColor];                
                self.subtitle.shadowOffset = CGSizeMake(0, 0);
                self.subtitle.shadowColor = [UIColor clearColor];
            }
        }
        else if (self.isSlider)
        {
            self.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
            self.selectionStyle = UITableViewCellSelectionStyleGray;            
        }
    }
    else
    {
        self.subtitle.numberOfLines = 2;
        
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithRed:0.843 green:0.843 blue:0.843 alpha:1]];
        self.selectedBackgroundView = bgColorView;
        
        self.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"table_view_cell_unselected.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] ];
    }    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    [self.title sizeToFit];
    
    NSInteger posX = 10;
    
    if (self.isGrouped)
    {
        posX = 20;
        if (self.imageView.image)
        {
            self.imageView.frame = CGRectMake(5, 5, 40, 35);
            posX += self.imageView.frame.size.width; 
        }
        
        if (self.isLink)
        {
            posX = 0;
        }
    }
    else
    {
        if (self.imageView.image)
        {
            self.imageView.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
            posX += self.imageView.frame.size.width; 
        }        
    }
    
    
    NSInteger cellW = self.frame.size.width - 40;
    NSInteger cellH = self.frame.size.height;    
    
    NSInteger posY = 0;
    NSInteger offsetY = 0;
    NSInteger pointSizeDividerOffset = 1;
    if (self.subtitle.text.length > 0)
    {
        if (self.isGrouped)
        {
            pointSizeDividerOffset = 2;
            offsetY = self.subtitle.font.pointSize / pointSizeDividerOffset;            
            posY -= offsetY;
        }
        else if (cellH > 50)
        {
            offsetY = self.subtitle.font.pointSize / pointSizeDividerOffset;
            posY -= offsetY;
        }
        else
        {
            offsetY = 2;
            posY -= 5;
        }
    }
    
    if (self.imageView.image)
    {
        if (self.isGrouped)
            cellW -= 40;
        else
            cellW -= self.imageView.frame.size.width;;
    }
    
    if (self.title.textAlignment == UITextAlignmentCenter || self.title.textAlignment == UITextAlignmentRight)
        cellW += 40;

    self.title.frame = CGRectMake(posX, posY, cellW, cellH);
    self.subtitle.frame = CGRectMake(posX, posY + self.title.font.pointSize + offsetY, cellW, cellH);
}

@end
