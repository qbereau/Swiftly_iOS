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
@synthesize uploadPeopleBlock   = _uploadPeopleBlock;
@synthesize processAddressBook  = _processAddressBook;
@synthesize getPeopleAB         = _getPeopleAB;
@synthesize genericFailureBlock = _genericFailureBlock;
@synthesize checkNewNumbers     = _checkNewNumbers;
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
    
    __block SWPeopleListViewController* selfBlock = self;
    self.uploadPeopleBlock = ^(NSDictionary* dict, NSArray* newContacts){
        [[SWAPIClient sharedClient] putPath:@"/accounts/link" 
                                 parameters:dict 
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[NSArray class]])
                                        {
                                            for (id newObj in responseObject)
                                            {
                                                SWPerson* newPerson   = [SWPerson createEntity];
                                                newPerson.isSelf = NO;
                                                [newPerson updateWithObject:newObj];

                                                // Add additional infos from AddressBook
                                                for (SWPerson* p in newContacts)
                                                {
                                                    if ([p.phoneNumber isEqualToString:newPerson.originalPhoneNumber])
                                                    {
                                                        newPerson.firstName = p.firstName;
                                                        newPerson.lastName  = p.lastName;
                                                        newPerson.thumbnail = p.thumbnail;
                                                        break;
                                                    }
                                                }
                                                
                                            }

                                            [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
                                            
                                            selfBlock.contacts = [selfBlock findPeople];
                                            [selfBlock.tableView reloadData];
                                            
                                            // Hide the HUD in the main tread 
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [MBProgressHUD hideHUDForView:selfBlock.navigationController.view animated:YES];
                                            });
                                            
                                        }                                                                            
                                    }
                                    failure:^(AFHTTPRequestOperation *operation2, NSError *error2) {
                                        NSLog(@"error");
                                    }
         ];            
    };
    
    self.getPeopleAB = ^{
        NSMutableArray* peopleAB = [NSMutableArray array];
        NSMutableArray* phones = [NSMutableArray array];
        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        for ( int i = 0; i < nPeople; i++ )
        {
            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
            
            SWPerson* p = [SWPerson newEntity];
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
            else
                p.thumbnail = [SWPerson defaultImage];
            
            if (p.firstName || p.lastName)
                [peopleAB addObject:p];
            
            if (p.phoneNumber && [p.phoneNumber class] != [NSNull class])
                [phones addObject:p.phoneNumber];
            
            CFRelease(ref);
        }

        return peopleAB;
    };
    
    self.genericFailureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        // Hide the HUD in the main tread 
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:selfBlock.navigationController.view animated:YES];
            UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
            [av show];                                                
        });
    };
    
    self.processAddressBook = ^(NSArray* peopleAB, NSArray* results) {
        for (id obj in results)
        {
            SWPerson* existingObj = [SWPerson findObjectWithServerID:[[obj valueForKey:@"id"] intValue]];
            
            if (existingObj)
            {
                [existingObj updateWithObject:obj];

                // Update infos from AddressBook
                for (SWPerson* p in peopleAB)
                {
                    if ([p.phoneNumber isEqualToString:existingObj.originalPhoneNumber])
                    {
                        existingObj.firstName = p.firstName;
                        existingObj.lastName  = p.lastName;
                        existingObj.thumbnail = p.thumbnail;
                        break;
                    }
                }                                                    
                
            }
        }
    };
    
    self.checkNewNumbers = ^(NSArray* peopleAB, BOOL modal, int itemsPerPage){
        // Step 3:  We still need to check if there are new users to the                                            
        //          AddressBook and sync them with server
        //          A user might also have changed a friend's phone number
        //          In that case, we need to relink the new phone number
        //          In the end we'll only display contacts coming from AddressBook
        //          With phone numbers matching the ones that the app have
        
        NSMutableArray* newPhoneNumbers = [NSMutableArray array];
        NSMutableArray* newContacts = [NSMutableArray array];
        for (SWPerson* p in peopleAB)
        {
            SWPerson* existingContact = [SWPerson findObjectWithOriginalPhoneNumber:p.phoneNumber];
            
            if (!existingContact && p.phoneNumber && [p.phoneNumber class] != [NSNull class])
            {
                [newPhoneNumbers addObject:p.phoneNumber];
                [newContacts addObject:p];
            }
        }
        
        // Create new link with this contact
        if ([newPhoneNumbers count] > 0)
        {
            if ([newPhoneNumbers count] > itemsPerPage)
            {
                int totalItems = [newPhoneNumbers count];
                int steps = (int)floor(totalItems/itemsPerPage);
                for (int i = 0; i <= steps; ++i)
                {
                    NSRange range = NSMakeRange(i * itemsPerPage, itemsPerPage);
                    if (i == steps)
                        range = NSMakeRange(i * itemsPerPage, totalItems - (i * itemsPerPage));
                    NSArray* sub = [newPhoneNumbers subarrayWithRange:range];
                    NSDictionary* dict = [NSDictionary dictionaryWithObject:sub forKey:@"phone_numbers"];
                    selfBlock.uploadPeopleBlock(dict, newContacts);                    
                }
            }
            else
            {
                NSDictionary* dict = [NSDictionary dictionaryWithObject:newPhoneNumbers forKey:@"phone_numbers"];
                selfBlock.uploadPeopleBlock(dict, newContacts);                
            }
        }
        else
        {
            [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
            
            selfBlock.contacts = [selfBlock findPeople];
            [selfBlock.tableView reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:selfBlock.navigationController.view animated:YES];
            });
        }        
    };
    
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
        
        _groups = [SWGroup findAllObjects];
        
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

- (NSArray*)findPeople
{
    if (self.mode == PEOPLE_LIST_MULTI_SELECTION_MODE)
        return [SWPerson findValidObjects];
    else
        return [SWPerson findAllObjects];
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
    
    // Sync with server
    self.contacts = [self findPeople];

    if ([self.contacts count] == 0)
    {
        [self synchronize:YES];
    }
    else
    {
        [self synchronize:NO];
        [self.tableView reloadData];
    }   
}

- (void)synchronize:(BOOL)modal
{
    if (modal)
    {
        MBProgressHUD *hud;
        if (self.navigationController.view)
            hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        else
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"loading", @"loading");
    }
    
    // Step 1: We get an array of all the people present in AddressBook
    NSArray* peopleAB = self.getPeopleAB();
    
    // Step 2: We download the user accounts list for update
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SWAPIClient sharedClient] getPath:@"/accounts"
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[NSArray class]])
                                        {
                                            int iTotalPages = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-total-pages"] intValue];
                                            //int iReturnedObjects = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-returned-objects"] intValue];
                                            int iItemsPerPage = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-per-page"] intValue];
                                            
                                            if (iTotalPages > 1)
                                            {   
                                                self.processAddressBook(peopleAB, responseObject);
                                                __block int opReq = iTotalPages - 2;
                                                for (int i = 2; i <= iTotalPages; ++i)
                                                {
                                                    [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/accounts?page=%d", i]
                                                                             parameters:nil
                                                                                success:^(AFHTTPRequestOperation *op2, id respObj2) {                                                        
                                                                                    
                                                                                    //int iCurrentPage = [[[[op2 response] allHeaderFields] valueForKey:@"x-pagination-current-page"] intValue];
                                                                                    //int iNbObj = [[[[op2 response] allHeaderFields] valueForKey:@"x-pagination-returned-objects"] intValue];

                                                                                    self.processAddressBook(peopleAB, respObj2);
                                                                                    
                                                                                    --opReq;
                                                                                    if (opReq == 0)
                                                                                        self.checkNewNumbers(peopleAB, modal, iItemsPerPage);
                                                                                }
                                                                                failure:self.genericFailureBlock
                                                     ];
                                                }
                                            }
                                            else
                                            {
                                                self.processAddressBook(peopleAB, responseObject);
                                                self.checkNewNumbers(peopleAB, modal, iItemsPerPage);
                                            }
                                        }
                                    }
                                    failure:self.genericFailureBlock
         ];
    });    
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
    cell.subtitle.text = p.originalPhoneNumber;
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
