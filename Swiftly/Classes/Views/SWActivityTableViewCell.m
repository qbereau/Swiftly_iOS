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

@synthesize progress = _progress;
@synthesize progressView = _progressView;

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
    [super setup];
    
    self.subtitle.text = NSLocalizedString(@"waiting_to_upload", @"Waiting to upload");
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(PROGRESS_VIEW_POS_X, PROGRESS_VIEW_POS_Y, self.frame.size.width - PROGRESS_VIEW_POS_X - 10, 20)];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.progressView];
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
    
    if (_progress > 0)
    {
        self.subtitle.hidden = YES;
        self.progressView.hidden = NO;
    }
    else
    {
        self.subtitle.hidden = NO;
        self.progressView.hidden = YES;
        
        if (_progress >= 1.0f)
        {
            NSLog(@"[SWActivityTableViewCell#setProgress] Should give infos from server (timestamp and uploaded filesize)");
            self.subtitle.text = @"Uploaded just now";
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.title.frame = CGRectMake(PROGRESS_VIEW_POS_X, -20, self.frame.size.width - self.imageView.frame.size.width, self.title.frame.size.height);
    self.subtitle.frame = CGRectMake(PROGRESS_VIEW_POS_X, 10, self.frame.size.width - self.imageView.frame.size.width, self.subtitle.frame.size.height);
}

@end
