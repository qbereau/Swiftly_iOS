//
//  SWGroupListViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWGroupListViewController.h"

static NSMutableArray* syncedGroupsID;
static NSUInteger opReq;

@implementation SWGroupListViewController

@synthesize groups = _groups;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tableView = [[SWTableView alloc] initWithFrame:self.view.frame style:style];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setAutoresizesSubviews:YES];
    [self.tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];    
}

- (void)reload
{
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        
    } completion:^{
        self.groups = [SWGroup MR_findAllSortedBy:@"name" ascending:YES];
        [self.tableView reloadData];
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

    [self reload];
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

+ (void)synchronize
{
    NSLog(@"--->Group Sync");
    syncedGroupsID = [NSMutableArray array];    
    
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SWAPIClient sharedClient] getPath:@"/groups"
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[NSArray class]])
                                        {   
                                            int iTotalPages = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-total-pages"] intValue];
                                            if (iTotalPages > 1)
                                            {   
                                                [self updateGroups:responseObject];
                                                
                                                @synchronized(self) {
                                                    opReq = iTotalPages - 1;
                                                }
                                                
                                                for (int i = 2; i <= iTotalPages; ++i)
                                                {
                                                    [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/groups?page=%d", i]
                                                                             parameters:nil
                                                                                success:^(AFHTTPRequestOperation *op2, id respObj2) {
                                                                                    
                                                                                    @synchronized(self){
                                                                                        --opReq;
                                                                                    }
                                                                                    
                                                                                    [self updateGroups:respObj2];
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
                                                    opReq = 0;
                                                }
                                                [self updateGroups:responseObject];
                                            }                                           
                                            
                                        }
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                                        [av show];
                                    }
         ];
    });
}

+ (void)updateGroups:(id)responseObject
{
    NSLog(@"--->Update Groups");
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        
        for (id obj in responseObject)
        {        
            SWGroup* groupObj = [SWGroup MR_findFirstByAttribute:@"serverID" withValue:[obj valueForKey:@"id"] inContext:localContext];
            
            if (!groupObj)
                groupObj = [SWGroup MR_createInContext:localContext];
            
            [groupObj updateWithObject:obj inContext:localContext];
        }   
    } completion:^{
        for (id obj in responseObject)
        {
            [syncedGroupsID addObject:[obj valueForKey:@"id"]];
        }
        
        if (opReq == 0)
            [self finishedUpdateGroups];
    }];
}

+ (void)finishedUpdateGroups
{
    NSLog(@"--->Finished Update Group");    
    if ([syncedGroupsID count] > 0)
    {
        [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"NOT (serverID in %@)", syncedGroupsID];
            [SWGroup MR_deleteAllMatchingPredicate:predicate inContext:localContext];
            
        } completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SWGroupSyncDone" object:nil];
        }];   
    }
    else 
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SWGroupSyncDone" object:nil];
    }
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groups count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellID = @"GroupCell";
    
    SWTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    SWGroup* group = [self.groups objectAtIndex:indexPath.row];
    cell.title.text = group.name;
    cell.subtitle.text = [group contacts_str];
    cell.imageView.image = nil;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWGroup* group = [self.groups objectAtIndex:indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    SWGroupEditViewController* groupEditViewController = [storyboard instantiateViewControllerWithIdentifier:@"GroupEditViewController"];
    groupEditViewController.group = group;
    [[self navigationController] pushViewController:groupEditViewController animated:YES];
}

@end
