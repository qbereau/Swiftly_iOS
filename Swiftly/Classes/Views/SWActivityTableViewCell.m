//
//  SWActivityTableViewCell.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWActivityTableViewCell.h"

#define PROGRESS_VIEW_POS_X 95
#define PROGRESS_VIEW_POS_Y 50

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
    self.detailTextLabel.text = NSLocalizedString(@"waiting_to_upload", @"Waiting to upload");
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(PROGRESS_VIEW_POS_X, PROGRESS_VIEW_POS_Y, self.frame.size.width - PROGRESS_VIEW_POS_X - 10, 20)];
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
        self.detailTextLabel.hidden = YES;
        self.progressView.hidden = NO;
    }
    else
    {
        self.detailTextLabel.hidden = NO;
        self.progressView.hidden = YES;
        
        if (_progress >= 1.0f)
        {
            NSLog(@"[SWActivityTableViewCell#setProgress] Should give infos from server (timestamp and uploaded filesize)");
            self.detailTextLabel.text = @"Uploaded just now";
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, PROGRESS_VIEW_POS_Y - 5, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
}

@end
