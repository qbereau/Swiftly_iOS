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
#import "SWComment.h"
#import "SWPerson.h"
#import "SWMedia.h"
#import "SWAPIClient.h"

@interface SWCommmentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    UIScrollView*           _scrollView;
    UITableView*            _tableView;
    UIToolbar*              _toolbar;
    NSArray*                _comments;
    SWMedia*                _media;
    UITextField*            _textField;
    NSInteger               _opReq;    
    BOOL                    _shouldUpdate;    
}

@property (nonatomic, strong) SWMedia*          media;
@property (nonatomic, strong) UITextField*      textfield;
@property (nonatomic, strong) UIScrollView*     scrollView;
@property (nonatomic, strong) NSArray*          comments;
@property (nonatomic, strong) UIToolbar*        toolbar;
@property (nonatomic, strong) UITableView*      tableView;
@property (nonatomic, assign) NSInteger         opReq;

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;
- (void)reload;
- (void)addCommentObject:(id)obj inContext:(NSManagedObjectContext*)context;
- (void)updateComments:(id)responseObject;

@end
