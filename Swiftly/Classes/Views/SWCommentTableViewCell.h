//
//  SWCommentTableViewCell.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SWCommentTableViewCell : UITableViewCell
{
    UITextView*             _comment;
    UILabel*                _commenter;
    UILabel*                _commented;
    UIImageView*            _thumbCommenter;
}

@property (nonatomic, strong) UITextView*       comment;
@property (nonatomic, strong) UILabel*          commenter;
@property (nonatomic, strong) UILabel*          commented;
@property (nonatomic, strong) UIImageView*      thumbCommenter;

+ (float)cellHeightWithText:(NSString*)txt;

@end
