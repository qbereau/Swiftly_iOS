//
//  SWPeopleListViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "SWPeopleListViewControllerDelegate.h"
#import "SWContactViewController.h"
#import "SWTableView.h"
#import "SWTableViewCell.h"
#import "SWPerson.h"
#import "SWGroup.h"
#import "SWSwitchButton.h"
#import "SWAPIClient.h"
#import "MBProgressHUD.h"
#import "SWGroup+Details.h"

#define PEOPLE_LIST_EDIT_MODE 0
#define PEOPLE_LIST_MULTI_SELECTION_MODE 1

typedef NSArray* (^GetPeopleAB)(void);
typedef void (^ProcessAddressBook)(NSArray*, NSArray*);
typedef void (^UploadPeopleBlock)(NSDictionary*, NSArray*);
typedef void (^CheckNewNumbers)(NSArray*, BOOL, int);

@interface SWPeopleListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray*            _contacts;
    NSMutableArray*     _selectedContacts;
    NSInteger           _mode;
    UITableView*        _tableView;
    
    BOOL                _showOnlyUsers;
    
    
    NSArray*            _groups;
    UIScrollView*       _scrollView;
    
    GenericFailureBlock _genericFailureBlock;
    UploadPeopleBlock   _uploadPeopleBlock;
    GetPeopleAB         _getPeopleAB;
    ProcessAddressBook  _processAddressBook;
    CheckNewNumbers     _checkNewNumbers;
}

@property (nonatomic, assign) id <SWPeopleListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray*          contacts;
@property (nonatomic, strong) NSMutableArray*   selectedContacts;
@property (nonatomic, assign) NSInteger         mode;

@property (nonatomic, copy)   GenericFailureBlock   genericFailureBlock;
@property (nonatomic, copy)   GetPeopleAB           getPeopleAB;
@property (nonatomic, copy)   ProcessAddressBook    processAddressBook;
@property (nonatomic, copy)   UploadPeopleBlock     uploadPeopleBlock;
@property (nonatomic, copy)   CheckNewNumbers       checkNewNumbers;

@property (nonatomic, strong) UITableView*      tableView;
@property (nonatomic, assign) BOOL              showOnlyUsers;

- (NSPredicate*)predicateForSection:(NSInteger)idx;
- (void)synchronize:(BOOL)modal;
- (void)pushedButton:(SWSwitchButton*)sender;
- (void)scrollLeft:(UIButton*)sender;
- (void)scrollRight:(UIButton*)sender;
- (NSArray*)findPeople;

@end
