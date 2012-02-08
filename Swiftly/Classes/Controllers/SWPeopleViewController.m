//
//  SWPeopleViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPeopleViewController.h"

#define MODE_CONTACTS 0
#define MODE_GROUPS 1

@implementation SWPeopleViewController

@synthesize groups = _groups;
@synthesize currentMode = _currentMode;
@synthesize contacts = _contacts;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentMode = MODE_CONTACTS;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:NSLocalizedString(@"contacts", @"contacts"), NSLocalizedString(@"groups", @"groups"), nil]];
    [segmentedControl addTarget:self
	                     action:@selector(changeMode:)
	           forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 170, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segmentedControl;

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
    
    self.groups = [NSArray arrayWithObjects:@"Family", @"Friends", @"Colleagues", nil];
}

- (void)addGroup:(id)sender
{
    NSLog(@"push group view controller");
}

- (void)changeMode:(UISegmentedControl*)sender
{
    self.currentMode = !self.currentMode;
    
    if (self.currentMode == MODE_GROUPS)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(addGroup:)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
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
    char c = 'A' + idx;
    NSString* s = [NSString stringWithFormat:@"%C", c];
    return [NSPredicate predicateWithFormat:@"predicateContactName BEGINSWITH[cd] %@", s];
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.currentMode == MODE_GROUPS)    
        return 1;
    
    return 26;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.currentMode == MODE_CONTACTS)
    {
        UILabel* v = (UILabel*)[tableView tableHeaderView];
        char c = 'A';
        v.text = [NSString stringWithFormat:@"   %C", c + section];
        
        return v;
    }
    
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.currentMode == MODE_GROUPS)
        return 0;
    
    return 22;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.currentMode == MODE_GROUPS)
        return [self.groups count];
    
    NSArray* arr = [self.contacts filteredArrayUsingPredicate:[self predicateForSection:section]];
    return [arr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentMode == MODE_GROUPS)    
        return 78;
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellID = @"ContactCell";
    if (self.currentMode == MODE_GROUPS)
        cellID = @"GroupCell";
    
    SWTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (self.currentMode == MODE_GROUPS)
    {
        cell.textLabel.text = [self.groups objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = @"";
        cell.imageView.image = nil;
    }
    else
    {
        NSArray* arr = [self.contacts filteredArrayUsingPredicate:[self predicateForSection:indexPath.section]];
        
        SWPerson* p = [arr objectAtIndex:indexPath.row];
        cell.textLabel.text = [p name];
        cell.detailTextLabel.text = p.phoneNumber;
        cell.imageView.image = p.thumbnail;
    }
    
    return cell;
}

@end
