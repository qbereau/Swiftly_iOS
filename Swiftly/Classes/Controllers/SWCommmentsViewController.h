//
//  SWCommmentsViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "SWCommentTableViewCell.h"

@interface SWCommmentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    UIScrollView*           _scrollView;
    UITableView*            _tableView;
    UIToolbar*              _toolbar;
    NSArray*                _comments;
}

@property (nonatomic, strong) UIScrollView*     scrollView;
@property (nonatomic, strong) NSArray*          comments;
@property (nonatomic, strong) UIToolbar*        toolbar;
@property (nonatomic, strong) UITableView*      tableView;

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;

@end
