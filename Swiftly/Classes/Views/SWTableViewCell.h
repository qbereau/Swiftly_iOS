//
//  SWTableViewCell.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWTableViewCell : UITableViewCell
{
    BOOL        _isGrouped;
    BOOL        _isSingle;
    BOOL        _isTop;
    BOOL        _isMiddle;
    BOOL        _isBottom;
    
    BOOL        _isLink;
}

@property (nonatomic, assign) BOOL      isGrouped;
@property (nonatomic, assign) BOOL      isSingle;
@property (nonatomic, assign) BOOL      isTop;
@property (nonatomic, assign) BOOL      isMiddle;
@property (nonatomic, assign) BOOL      isBottom;
@property (nonatomic, assign) BOOL      isLink;

@end
