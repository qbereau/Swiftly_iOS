//
//  SWTableViewCell.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWTableViewCell.h"

@implementation SWTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.detailTextLabel.numberOfLines = 2;
    self.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"table_view_cell_unselected.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] ];
}

@end
