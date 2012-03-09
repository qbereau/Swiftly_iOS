//
//  SWCommentTableViewCell.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWCommentTableViewCell.h"

#define THUMB_POS_X 10
#define THUMB_POS_Y 10
#define THUMB_WIDTH 48
#define THUMB_HEIGHT 42

#define COMMENTER_POS_X 68
#define COMMENTER_POS_Y 18

#define COMMENT_MARGIN_Y 20
#define COMMENT_FONT_SIZE 14

@implementation SWCommentTableViewCell

@synthesize comment         = _comment;
@synthesize commenter       = _commenter;
@synthesize commented       = _commented;
@synthesize thumbCommenter  = _thumbCommenter;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.thumbCommenter = [[UIImageView alloc] init];
        [self addSubview:self.thumbCommenter];
        
        self.commenter = [[UILabel alloc] init];
        [self addSubview:self.commenter];
        
        self.commented = [[UILabel alloc] init];
        [self addSubview:self.commented];
        
        self.comment = [[UITextView alloc] init];
        [self addSubview:self.comment];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.commenter.backgroundColor = [UIColor clearColor];
    self.commenter.textColor = [UIColor colorWithRed:0.243 green:0.246 blue:0.267 alpha:1];
    self.commenter.shadowOffset = CGSizeMake(1, 1);
    self.commenter.shadowColor = [UIColor whiteColor];
    
    self.commented.backgroundColor = [UIColor clearColor];
    self.commented.font = [UIFont systemFontOfSize:12];
    self.commented.textColor = [UIColor colorWithRed:0.412 green:0.404 blue:0.447 alpha:1];
    self.commented.shadowOffset = CGSizeMake(1, 1);
    self.commented.shadowColor = [UIColor whiteColor];
    
    self.comment.backgroundColor = [UIColor clearColor];
    self.comment.textColor = [UIColor colorWithRed:0.243 green:0.246 blue:0.267 alpha:1];
    self.comment.contentInset = UIEdgeInsetsMake(-10, -8, 0, 0);
    self.comment.font = [UIFont systemFontOfSize:COMMENT_FONT_SIZE];
    self.comment.editable = NO;
    self.comment.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.comment.layer.shadowOffset = CGSizeMake(1, 1);
    self.comment.layer.shadowOpacity = 1.0;
    self.comment.layer.shadowRadius = 0.0;

    self.selectedBackgroundView = nil;
    self.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"table_view_cell_unselected.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] ];
}

+ (float)cellHeightWithText:(NSString*)txt
{
    return THUMB_POS_Y + THUMB_HEIGHT + COMMENT_MARGIN_Y + [txt sizeWithFont:[UIFont systemFontOfSize:COMMENT_FONT_SIZE] constrainedToSize:CGSizeMake(240, 9999) lineBreakMode:UILineBreakModeWordWrap].height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.thumbCommenter.frame = CGRectMake(THUMB_POS_X, THUMB_POS_Y, THUMB_WIDTH, THUMB_HEIGHT);
    self.commenter.frame = CGRectMake(COMMENTER_POS_X, COMMENTER_POS_Y, self.frame.size.width - 80, 20);
    self.commented.frame = CGRectMake(self.commenter.frame.origin.x, self.commenter.frame.origin.y + self.commenter.frame.size.height - 2, self.frame.size.width - 80, 20);
    self.comment.frame = CGRectMake(self.commenter.frame.origin.x, self.commented.frame.origin.y + self.commented.frame.size.height + 10, self.frame.size.width - 80, self.comment.contentSize.height);
}

@end
