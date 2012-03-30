//
//  SWActivityTableViewCell.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "SWMedia.h"

@interface SWActivityTableViewCell : SWTableViewCell
{
    CGFloat             _progress;
    UIProgressView*     _progressView;
    UIButton*           _btnClear;
    SWMedia*            _media;
}

@property (nonatomic, assign) CGFloat           progress;
@property (nonatomic, strong) UIProgressView*   progressView;
@property (nonatomic, strong) UIButton*         btnClear;
@property (nonatomic, strong) SWMedia*          media;

- (id)initWithProgressView:(BOOL)pv style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setup:(BOOL)pv;

@end
