//
//  SWPeopleListViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPeopleListViewController.h"

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
        
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - toolbarHeight);
        
        [self.view addSubview:toolbar];        
    }
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
