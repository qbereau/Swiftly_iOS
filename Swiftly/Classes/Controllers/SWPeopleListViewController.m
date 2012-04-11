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

static NSInteger nbUploadPeoplePages = 0;

@synthesize spinner                 = _spinner;
@synthesize selectedContacts        = _selectedContacts;
@synthesize contacts                = _contacts;
@synthesize mode                    = _mode;
@synthesize tableView               = _tableView;
@synthesize showOnlyUsers           = _showOnlyUsers;
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
        
        _groups = [SWGroup MR_findAllInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        
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
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.spinner.frame = self.view.frame;
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
}

- (NSArray*)findPeople
{
    NSLog(@"people AB");
    if (self.mode == PEOPLE_LIST_MULTI_SELECTION_MODE)
        return [SWPerson findValidObjectsInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    else
        return [SWPerson findAllObjectsInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
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
}

- (void)reloadData
{
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        
    } completion:^{
        self.contacts = [self findPeople];
        [self.tableView reloadData];
        [self.spinner stopAnimating];
    }];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:@"SWABProcessDone"
                                               object:nil
     ];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"SWABProcessDone" 
                                                  object:nil
     ];    
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

- (NSArray*)sortedContactsAtSection:(NSInteger)section
{
    NSArray* arr = [[self.contacts filteredArrayUsingPredicate:[self predicateForSection:section]] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* n1 = [obj1 predicateContactName];
        NSString* n2 = [obj2 predicateContactName];
        return [n1 compare:n2];
    }];
    return arr;
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
        
        CALayer * l = [cell.imageView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:2.0];
    }
    
    NSArray* arr = [self sortedContactsAtSection:indexPath.section];
    
    SWPerson* p = [arr objectAtIndex:indexPath.row];
    cell.title.text = [p name];

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
    NSArray* arr = [self sortedContactsAtSection:indexPath.section];
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

static NSInteger opReq = 0;
static NSInteger itemsPerPage = 0;

+ (void)synchronize
{
    NSLog(@"---->[synch]");     
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // Step 2: We download the user accounts list for update
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Step 1: We get an array of all the people present in AddressBook
    
        NSManagedObjectContext* context = [NSManagedObjectContext MR_context];

            NSArray* peopleAB = [SWPerson getPeopleABInContext:context];        

            [[SWAPIClient sharedClient] getPath:@"/users"
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            if ([responseObject isKindOfClass:[NSArray class]])
                                            {
                                                int iTotalPages = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-total-pages"] intValue];
                                                itemsPerPage = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-per-page"] intValue];
                                                
                                                if (iTotalPages > 1)
                                                {   
                                                    [SWPeopleListViewController processAddressBook:peopleAB results:responseObject];
                                                    
                                                    @synchronized(self){
                                                        opReq = iTotalPages - 1;
                                                    };

                                                    for (int i = 2; i <= iTotalPages; ++i)
                                                    {
                                                        [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/users?page=%d", i]
                                                                                 parameters:nil
                                                                                    success:^(AFHTTPRequestOperation *op2, id respObj2) {

                                                                                        [SWPeopleListViewController processAddressBook:peopleAB results:respObj2];
                                                                                    }
                                                                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                        NSLog(@"error");
                                                                                    }
                                                         ];
                                                    }
                                                }
                                                else
                                                {
                                                    @synchronized(self){
                                                        opReq = 1;
                                                    }
                                                    [SWPeopleListViewController processAddressBook:peopleAB results:responseObject];
                                                }
                                            }
                                        }
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"error");
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"SWABProcessFailed" object:nil];                                        
                                        }
             ];
        
    //}];
        
    });  
}

+ (void)processAddressBook:(NSArray*)peopleAB results:(NSArray*)results
{
    NSLog(@"---->[processAddressBook]");    
	//dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{    
    
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        
        for (id obj in results)
        {
            SWPerson* existingObj = [SWPerson MR_findFirstByAttribute:@"serverID" withValue:[obj valueForKey:@"id"] inContext:localContext];
            
            if (!existingObj)
            {
                existingObj = [SWPerson MR_createInContext:localContext];
            }
            
            [existingObj updateWithObject:obj inContext:localContext];
            
            // Update infos from AddressBook
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY %@ IN phoneNumbers.phoneNumber", [existingObj arrStrPhoneNumbers]];
            NSArray* arr = [peopleAB filteredArrayUsingPredicate:predicate];
            if (arr && [arr count] > 0)
            {
                SWPerson* p = [arr objectAtIndex:0];
                existingObj.firstName = p.firstName;
                existingObj.lastName  = p.lastName;
                existingObj.thumbnail = p.thumbnail;
            }        
        }
    } completion:^{
        @synchronized(self) {
            --opReq;
        }
        
        if (opReq == 0)
            [SWPeopleListViewController checkNewNumbers:peopleAB];  
    }];
    
    //});
}

+ (void)uploadPeople:(NSDictionary*)dict newContacts:(NSArray*)newContacts peopleAB:(NSArray *)peopleAB
{
    NSLog(@"---->[uploadPeople]");
	//dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            [[SWAPIClient sharedClient] putPath:@"/users/link" 
                                     parameters:dict 
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            if ([responseObject isKindOfClass:[NSArray class]])
                                            {
                                                
                                                [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
                                                    
                                                    NSMutableArray* arrAddedOrigPhoneNumbers = [NSMutableArray array];

                                                    for (id newObj in responseObject)
                                                    {
                                                        SWPerson* abPerson = [SWPerson findObjectWithPhoneNumber:[newObj valueForKey:@"original_phone_number"] inContext:localContext people:peopleAB];
                                                        SWPerson* newPerson = [SWPerson MR_findFirstByAttribute:@"serverID" withValue:[newObj valueForKey:@"id"] inContext:localContext];
                                                        if (!newPerson)
                                                            newPerson   = [SWPerson MR_createInContext:localContext];
                                                        
                                                        [newPerson updateWithObject:newObj inContext:localContext];
                                                        
                                                        newPerson.isSelf = NO;
                                                        newPerson.firstName = abPerson.firstName;
                                                        newPerson.lastName  = abPerson.lastName;
                                                        newPerson.thumbnail = abPerson.thumbnail;
                                                    }
                                                    
                                                    for (NSString* link_pn in [dict objectForKey:@"phone_numbers"])
                                                    {    
                                                        BOOL bFound = NO;
                                                        for (NSString* opn in arrAddedOrigPhoneNumbers)
                                                        {
                                                            if ([opn isEqualToString:link_pn])
                                                            {
                                                                bFound = YES;
                                                                break;
                                                            }
                                                        }
                                                        
                                                        if (!bFound)
                                                        {
                                                            SWPhoneNumber* pn = [SWPhoneNumber MR_findFirstByAttribute:@"phoneNumber" withValue:link_pn inContext:localContext];
                                                            if (pn)
                                                            {
                                                                pn.invalid = YES;                                                        
                                                            }                                                    
                                                        }
                                                    }                                                           
                                                    
                                                } completion:^{
                                                    @synchronized(self){
                                                        --nbUploadPeoplePages;
                                                    }
                                                    if (nbUploadPeoplePages <= 0)
                                                    {
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"SWABProcessDone" object:nil];
                                                    }                                                    
                                                }];                                                 
                                            }                                                                            
                                        }
                                        failure:^(AFHTTPRequestOperation *operation2, NSError *error2) {
                                            NSLog(@"error");
                                        }
             ];
    //});
}

+ (void)checkNewNumbers:(NSArray*)peopleAB
{
	//dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{    
        // Step 3:  We still need to check if there are new users to the                                            
        //          AddressBook and sync them with server
        //          A user might also have changed a friend's phone number
        //          In that case, we need to relink the new phone number
        //          In the end we'll only display contacts coming from AddressBook
        //          With phone numbers matching the ones that the app have               

    NSMutableArray* newPhoneNumbers = [NSMutableArray array];
    NSMutableArray* newContacts = [NSMutableArray array];    
    
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        
        for (SWPerson* p in peopleAB)
        {
            BOOL addNewPN = NO;
            for (SWPhoneNumber* pn in [p.phoneNumbers allObjects])
            {
                SWPhoneNumber* localPN = [SWPhoneNumber MR_findFirstByAttribute:@"phoneNumber" withValue:pn.phoneNumber inContext:localContext];
                if (!localPN)
                {
                    addNewPN                = YES;
                    localPN                 = [SWPhoneNumber MR_createInContext:localContext];
                    localPN.phoneNumber     = pn.phoneNumber;
                    localPN.normalized      = NO;
                    localPN.invalid         = NO;
                    
                    [newPhoneNumbers addObject:pn.phoneNumber];
                }
            }
            if (addNewPN)
                [newContacts addObject:p];
        }            
        
    } completion:^{

        // Create new link with this contact
        if ([newPhoneNumbers count] > 0)
        {
            if ([newPhoneNumbers count] > itemsPerPage)
            {
                int totalItems = [newPhoneNumbers count];
                int steps = (int)floor(totalItems/itemsPerPage);
                nbUploadPeoplePages = steps + 1;
                for (int i = 0; i <= steps; ++i)
                {
                    NSRange range = NSMakeRange(i * itemsPerPage, itemsPerPage);
                    if (i == steps)
                        range = NSMakeRange(i * itemsPerPage, totalItems - (i * itemsPerPage));
                    NSArray* sub = [newPhoneNumbers subarrayWithRange:range];
                    NSDictionary* dict = [NSDictionary dictionaryWithObject:sub forKey:@"phone_numbers"];
                    [SWPeopleListViewController uploadPeople:dict newContacts:newContacts peopleAB:peopleAB];
                }
            }
            else
            {
                nbUploadPeoplePages = 1;
                NSDictionary* dict = [NSDictionary dictionaryWithObject:newPhoneNumbers forKey:@"phone_numbers"];
                [SWPeopleListViewController uploadPeople:dict newContacts:newContacts peopleAB:peopleAB];
            }
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SWABProcessDone" object:nil];
        } 

    }];
            
    //});
}

@end
