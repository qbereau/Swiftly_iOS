//
//  SWPeopleListViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPeopleListViewController.h"

#define SCROLL_FACTOR 50

@implementation SWPeopleListViewController

@synthesize selectedContacts    = _selectedContacts;
@synthesize contacts            = _contacts;
@synthesize mode                = _mode;
@synthesize tableView           = _tableView;
@synthesize showOnlyUsers       = _showOnlyUsers;
@synthesize delegate;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.tableView = [[SWTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    
    [self.tableView setAutoresizesSubviews:YES];
    [self.tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    [self.view addSubview:self.tableView];

    if (self.mode == PEOPLE_LIST_MULTI_SELECTION_MODE)
    {
        UIToolbar *toolbar = [UIToolbar new];
        toolbar.barStyle = UIBarStyleDefault;
        [toolbar sizeToFit];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        //Set the frame
        CGFloat toolbarHeight = [toolbar frame].size.height;
        [toolbar setFrame:CGRectMake(0, self.view.frame.size.height - toolbarHeight, self.view.frame.size.width, toolbarHeight)];
        
        UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
        UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done", @"done") style:UIBarButtonItemStyleBordered target:self action:@selector(done:)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, btnCancel, flexibleSpace, btnDone, flexibleSpace, nil]];
        
        self.tableView.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - toolbarHeight - 44);
        
        [self.view addSubview:toolbar];
        
        //--
        UIView* groupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        groupView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        groupView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar"]];
        
        UIButton* btnArrowLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
        [btnArrowLeft setImage:[UIImage imageNamed:@"arrow_left"] forState:UIControlStateNormal];
        [btnArrowLeft addTarget:self action:@selector(scrollLeft:) forControlEvents:UIControlEventTouchDown];
        [groupView addSubview:btnArrowLeft];
        
        UIButton* btnArrowRight = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 30, 0, 30, 44)];
        btnArrowRight.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [btnArrowRight setImage:[UIImage imageNamed:@"arrow_right"] forState:UIControlStateNormal];        
        btnArrowRight.contentMode = UIViewContentModeScaleAspectFit;
        [btnArrowRight addTarget:self action:@selector(scrollRight:) forControlEvents:UIControlEventTouchUpInside];        
        [groupView addSubview:btnArrowRight];

        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(30, 0, self.view.frame.size.width - 60, 44)];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [groupView addSubview:_scrollView];
        
        // Custom Data - Should come from Core Data
        SWPerson* qb = [SWPerson new];
        qb.firstName = @"Quentin";
        qb.lastName = @"Bereau";
        qb.phoneNumber = @"079 629 41 79";
        
        SWPerson* pb = [SWPerson new];
        pb.firstName = @"Patrick";
        pb.lastName = @"Bereau";
        pb.phoneNumber = @"+41 78 842 41 86";
        
        SWPerson* tb = [SWPerson new];
        tb.firstName = @"Tristan";
        tb.lastName = @"Bereau";
        tb.phoneNumber = @"+41 78 744 51 47";
        
        SWPerson* pc = [SWPerson new];
        pc.firstName = @"Paul";
        pc.lastName = @"Carneiro";
        pc.phoneNumber = @"+41 79 439 10 72";
        
        SWGroup* g1 = [SWGroup new];
        g1.name = @"Family";
        g1.contacts = [NSArray arrayWithObjects:qb, pb, tb, nil];
        
        SWGroup* g2 = [SWGroup new];
        g2.name = @"Friends";
        g2.contacts = [NSArray arrayWithObjects:pc, tb, nil];
        
        SWGroup* g3 = [SWGroup new];
        g3.name = @"Colleagues";
        g3.contacts = [NSArray arrayWithObjects:qb, pb, pc, nil];
        
        _groups = [NSArray arrayWithObjects:g1, g2, g3, g1, g2, g3, nil];
        NSInteger xPos = 0;
        NSInteger idx = 0;
        for (SWGroup* g in _groups)
        {            
            SWSwitchButton* btn = [[SWSwitchButton alloc] initWithFrame:CGRectMake(xPos, 7, 100, 28)];
            [btn setTitle:g.name forState:UIControlStateNormal];
            btn.titleLabel.textColor = [UIColor whiteColor];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            [btn setPushed:NO];
            [btn setTag:idx];
            [btn sizeToFit];
            [btn setFrame:CGRectMake(xPos, btn.frame.origin.y, btn.frame.size.width + 20, btn.frame.size.height)];
            [btn addTarget:self action:@selector(pushedButton:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:btn];
            ++idx;
            xPos += (btn.frame.size.width + 20);
        }
        
        _scrollView.contentSize = CGSizeMake(xPos, _scrollView.frame.size.height);
        
        [self.view addSubview:groupView];
    }
}

- (void)pushedButton:(SWSwitchButton*)sender
{
    [sender setPushed:!sender.pushed];
    
    SWGroup* g = [_groups objectAtIndex:sender.tag];
    
    for (SWPerson* p in g.contacts)
    {
        if (sender.pushed && ![self.selectedContacts containsObject:p])
            [self.selectedContacts addObject:p];
        else if (!sender.pushed && [self.selectedContacts containsObject:p])
        {
            // Check if person is not already present in another selected group
            BOOL shouldDeleteObject = YES;
            for (UIView* v in _scrollView.subviews)
            {
                if ([v isKindOfClass:[SWSwitchButton class]])
                {
                    SWSwitchButton* btn = (SWSwitchButton*)btn;
                    if (btn.tag != sender.tag && btn.pushed)
                    {
                        SWGroup* otherGroup = [_groups objectAtIndex:btn.tag];
                        if ([otherGroup.contacts containsObject:p])
                        {
                            shouldDeleteObject = NO;
                        }
                    }
                }
            }
            
            if (shouldDeleteObject)
                [self.selectedContacts removeObject:p];
        }
    }
    
    [self.tableView reloadData];    
}

- (void)scrollLeft:(UIButton*)sender
{
    if (_scrollView.contentOffset.x - SCROLL_FACTOR > 0)
        [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x - SCROLL_FACTOR, _scrollView.contentOffset.y) animated:YES];
    else
        [_scrollView setContentOffset:CGPointMake(0, _scrollView.contentOffset.y) animated:YES];
}

- (void)scrollRight:(UIButton*)sender
{
    if (_scrollView.contentOffset.x + SCROLL_FACTOR < _scrollView.contentSize.width - _scrollView.frame.size.width)
        [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x + SCROLL_FACTOR, _scrollView.contentOffset.y) animated:YES];
    else
        [_scrollView setContentOffset:CGPointMake(_scrollView.contentSize.width - _scrollView.frame.size.width, _scrollView.contentOffset.y) animated:YES];        
}

- (void)cancel:(UIBarButtonItem*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done:(UIBarButtonItem*)sender
{
    if ([self.delegate respondsToSelector:@selector(peopleListViewControllerDidSelectContacts:)])
    {
        NSArray* arr = [[NSSet setWithArray:self.selectedContacts] allObjects];
        arr = [arr sortedArrayUsingComparator:^(id a, id b){
            NSString* o1 = [(SWPerson*)a predicateContactName];
            NSString* o2 = [(SWPerson*)b predicateContactName];
            return [o1 compare:o2];
        }];
        [self.delegate peopleListViewControllerDidSelectContacts:arr];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.mode == PEOPLE_LIST_MULTI_SELECTION_MODE && !self.selectedContacts)
        self.selectedContacts = [NSMutableArray array];
    
    // Data Source
    NSMutableArray* persons = [NSMutableArray array];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        
        SWPerson* p = [SWPerson new];
        p.firstName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        p.lastName = (__bridge NSString*)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        NSString *mobileNumber;
        NSString *mobileLabel;
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++)
        {
            mobileLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
            if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneMobileLabel] || [mobileNumber isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]) 
            {
                p.phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers,i);
                break;
            }
        }
        
        if (ABPersonHasImageData(ref))
        {
            NSData *imageData = (__bridge NSData*)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
            p.thumbnail = [UIImage imageWithData:imageData];
        }
        
        if (p.firstName || p.lastName)        
            [persons addObject:p];
        
        CFRelease(ref);
    }
    
    self.contacts = [persons sortedArrayUsingComparator:^(id a, id b) {
        NSString* o1 = [(SWPerson*)a lastName];
        NSString* o2 = [(SWPerson*)b lastName];
        return [o1 compare:o2];
    }];
    
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (NSPredicate*)predicateForSection:(NSInteger)idx
{
    if (idx < 26)
    {
        char c = 'A' + idx;    
        NSString* s = [NSString stringWithFormat:@"%C", c];
        return [NSPredicate predicateWithFormat:@"predicateContactName BEGINSWITH[cd] %@", s];
    }
    
    return [NSPredicate predicateWithFormat:@"predicateContactName MATCHES '^[0-9].*'"];
}

- (void)setMode:(NSInteger)mode
{
    _mode = mode;
    
    if (self.mode == PEOPLE_LIST_MULTI_SELECTION_MODE)
    {
        //self.view.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - 150);
    }
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 27;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* v = (UILabel*)[tableView tableHeaderView];
    char c = 'A';
    v.text = [NSString stringWithFormat:@"   %C", c + section];
    if (section == 26)
        v.text = @"   #";
    
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* arr = [self.contacts filteredArrayUsingPredicate:[self predicateForSection:section]];
    return [arr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellID = @"ContactCell";
    
    SWTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    NSArray* arr = [self.contacts filteredArrayUsingPredicate:[self predicateForSection:indexPath.section]];
    
    SWPerson* p = [arr objectAtIndex:indexPath.row];
    cell.title.text = [p name];
    cell.subtitle.text = p.phoneNumber;
    cell.imageView.image = [p contactImage];
    
    if (self.mode == PEOPLE_LIST_EDIT_MODE)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else if (self.mode == PEOPLE_LIST_MULTI_SELECTION_MODE)
    {
        if ([self.selectedContacts containsObject:p])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* arr = [self.contacts filteredArrayUsingPredicate:[self predicateForSection:indexPath.section]];
    SWPerson* p = [arr objectAtIndex:indexPath.row];
    
    if (self.mode == PEOPLE_LIST_EDIT_MODE)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        SWContactViewController* contactsViewController = [storyboard instantiateViewControllerWithIdentifier:@"ContactViewController"];
        contactsViewController.contact = p;
        [[self navigationController] pushViewController:contactsViewController animated:YES];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (self.mode == PEOPLE_LIST_MULTI_SELECTION_MODE)
    {
        if (![self.selectedContacts containsObject:p])
            [self.selectedContacts addObject:p];
        else
            [self.selectedContacts removeObject:p];
        
        [self.tableView reloadData];
    }
}

@end
