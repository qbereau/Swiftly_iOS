//
//  SWActivityTableViewCell.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWActivityTableViewCell.h"

#define PROGRESS_VIEW_POS_X 95
#define PROGRESS_VIEW_POS_Y 60

@implementation SWActivityTableViewCell

@synthesize btnClear = _btnClear;
@synthesize progress = _progress;
@synthesize progressView = _progressView;
@synthesize media = _media;

- (id)initWithProgressView:(BOOL)pv style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup:pv];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self setup:YES];
    }
    
    return self;
}

- (void)setup:(BOOL)pv
{
    [super setup];
    
    self.subtitle.text = NSLocalizedString(@"waiting_to_upload", @"Waiting to upload");
    
    if (pv)
    {
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(PROGRESS_VIEW_POS_X, PROGRESS_VIEW_POS_Y, self.frame.size.width - PROGRESS_VIEW_POS_X - 20, 20)];
        self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.progressView];
    }
    
    self.btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnClear setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    //[self.btnClear setBackgroundImage:[UIImage imageNamed:@"cancelPressed"] forState:UIControlStateHighlighted];    
    self.btnClear.frame = CGRectMake(self.frame.size.width - 30, 13, 15, 15);
    [self addSubview:self.btnClear];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.selectedBackgroundView = nil;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;

    self.progressView.progress = _progress;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.title.frame = CGRectMake(PROGRESS_VIEW_POS_X, -20, self.frame.size.width - self.imageView.frame.size.width, self.title.frame.size.height);
    
    self.subtitle.frame = CGRectMake(PROGRESS_VIEW_POS_X, 5, self.frame.size.width - self.imageView.frame.size.width, self.subtitle.frame.size.height);
}

@end
