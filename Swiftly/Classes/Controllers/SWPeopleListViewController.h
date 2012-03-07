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

#define PEOPLE_LIST_EDIT_MODE 0
#define PEOPLE_LIST_MULTI_SELECTION_MODE 1

@interface SWPeopleListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray*            _contacts;
    NSMutableArray*     _selectedContacts;
    NSInteger           _mode;
    UITableView*        _tableView;
    
    BOOL                _showOnlyUsers;
    
    NSArray*            _groups;
    UIScrollView*       _scrollView;
}

@property (nonatomic, assign) id <SWPeopleListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray*          contacts;
@property (nonatomic, strong) NSMutableArray*   selectedContacts;
@property (nonatomic, assign) NSInteger         mode;
@property (nonatomic, strong) UITableView*      tableView;
@property (nonatomic, assign) BOOL              showOnlyUsers;

- (NSPredicate*)predicateForSection:(NSInteger)idx;
- (void)pushedButton:(SWSwitchButton*)sender;
- (void)scrollLeft:(UIButton*)sender;
- (void)scrollRight:(UIButton*)sender;
- (NSArray*)findPeople;
- (void)reloadData;
- (NSArray*)sortedContactsAtSection:(NSInteger)section;


+ (void)synchronize;
+ (void)processAddressBook:(NSArray*)peopleAB results:(NSArray*)results;
+ (void)uploadPeople:(NSDictionary*)dict newContacts:(NSArray*)newContacts peopleAB:(NSArray*)peopleAB;
+ (void)checkNewNumbers:(NSArray*)peopleAB;

//+ (void)contextDidSave:(NSNotification*)notif;

@end
