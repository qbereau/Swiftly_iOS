//
//  SWTableView.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWTableView.h"

@implementation SWTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    
    if (self)
    {
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
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (UIView*)tableHeaderView
{
    UILabel* v = [[UILabel alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableview_header"]];
    v.textColor = [UIColor whiteColor];
    v.font = [UIFont boldSystemFontOfSize:14.0];
    return v;
}

@end
