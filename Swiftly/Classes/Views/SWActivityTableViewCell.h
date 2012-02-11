//
//  SWActivityTableViewCell.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface SWActivityTableViewCell : SWTableViewCell
{
    CGFloat             _progress;
    UIProgressView*     _progressView;
}

@property (nonatomic, assign) CGFloat           progress;
@property (nonatomic, strong) UIProgressView*   progressView;

@end
