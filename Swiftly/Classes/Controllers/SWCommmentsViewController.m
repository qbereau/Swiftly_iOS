//
//  SWCommmentsViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWCommmentsViewController.h"

#define MAX_COMMENT_PAGES   3
#define TOOLBAR_Y_PORTRAIT  371
#define TOOLBAR_Y_LANDSCAPE 223
#define TOOLBAR_X           0

@implementation SWCommmentsViewController

@synthesize textfield = _textField;
@synthesize media = _media;
@synthesize tableView = _tableView;
@synthesize toolbar = _toolbar;
@synthesize scrollView = _scrollView;
@synthesize comments = _comments;
@synthesize opReq = _opReq;

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
    
    self.navigationItem.title = NSLocalizedString(@"comments", @"Comments");
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    
    self.view.autoresizesSubviews = YES;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;    
    [self.view addSubview:self.scrollView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height - 45) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundView = nil;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.scrollView addSubview:self.tableView];

    // --
    
    self.textfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 210, 30)];
    self.textfield.borderStyle = UITextBorderStyleRoundedRect;
    self.textfield.textColor = [UIColor whiteColor];
    self.textfield.font = [UIFont systemFontOfSize:17.0];
    self.textfield.placeholder = NSLocalizedString(@"enter_comment", @"<enter your comment>");
    self.textfield.backgroundColor = [UIColor blackColor];
    self.textfield.keyboardType = UIKeyboardTypeDefault;
    self.textfield.returnKeyType = UIReturnKeyDone;
    self.textfield.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.textfield.delegate = self;

    UIButton* btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSend setTitle:NSLocalizedString(@"send", @"send") forState:UIControlStateNormal];
    btnSend.titleLabel.shadowColor = [UIColor blackColor];
    btnSend.titleLabel.shadowOffset = CGSizeMake(1, 1);
    [btnSend setFrame:CGRectMake(230, 30, 80, 30)];
    [btnSend setBackgroundImage:[[UIImage imageNamed:@"rounded_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4] forState:UIControlStateNormal];
    [btnSend addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    btnSend.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    self.toolbar = [UIToolbar new];
    self.toolbar.barStyle = UIBarStyleDefault;
    [self.toolbar sizeToFit];
    self.toolbar.frame = CGRectMake(TOOLBAR_X, TOOLBAR_Y_PORTRAIT, 320, 50);
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;

    UIBarButtonItem *textFieldItem = [[UIBarButtonItem alloc] initWithCustomView:self.textfield];
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btnSend];
    [self.toolbar setItems:[NSArray arrayWithObjects:textFieldItem, btnItem, nil]];
    [self.scrollView addSubview:self.toolbar];

    
    [self reload];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];        
        [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/nodes/%d/comments", self.media.serverID]
                                                            parameters:nil 
                                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                   if ([responseObject isKindOfClass:[NSArray class]])
                                                                   {
                                                                       
                                                                       int iTotalPages = [[[[operation response] allHeaderFields] valueForKey:@"x-pagination-total-pages"] intValue];
                                                                       
                                                                       if (iTotalPages > 1)
                                                                       {                                      
                                                                           @synchronized(self) {
                                                                               _shouldUpdate = NO;
                                                                               self.opReq = iTotalPages - 1;
                                                                           }
                                                                           
                                                                           [self updateComments:responseObject];
                                                                           
                                                                           // Limit amount of data to be download
                                                                           iTotalPages = MIN(iTotalPages, MAX_COMMENT_PAGES);
                                                                           
                                                                           for (int i = 2; i <= iTotalPages; ++i)
                                                                           {
                                                                               [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/nodes/%d/comments?page=%d", self.media.serverID, i]
                                                                                                        parameters:nil
                                                                                                           success:^(AFHTTPRequestOperation *op2, id respObj2) {
                                                                                                               
                                                                                                               @synchronized(self){
                                                                                                                   --self.opReq;
                                                                                                                   _shouldUpdate = (self.opReq == 0) ? YES : NO;
                                                                                                               }
                                                                                                               
                                                                                                               [self updateComments:respObj2];
                                                                                                           }
                                                                                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                               NSLog(@"error");
                                                                                                           }
                                                                                ];
                                                                           }
                                                                       }
                                                                       else
                                                                       {
                                                                           @synchronized(self) {
                                                                               _shouldUpdate = YES;
                                                                           }
                                                                           [self updateComments:responseObject];
                                                                       }                                                                           
                                                                                                                                        
                                                                   }
                                                               } 
                                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                   
                                                               }
         ];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)updateComments:(id)responseObject
{
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        
        for (id obj in responseObject)
        {
            [self addCommentObject:obj inContext:localContext];
        }                                                                           
        
    } completion:^{
        if (_shouldUpdate)
            [self reload];
    }];    
}

- (void)addCommentObject:(id)obj inContext:(NSManagedObjectContext*)context
{
    SWComment* comment = [SWComment MR_findFirstByAttribute:@"serverID" withValue:[obj valueForKey:@"id"] inContext:context];
    
    if (!comment)
        comment = [SWComment MR_createInContext:context];
    
    SWMedia* m = [SWMedia MR_findFirstByAttribute:@"serverID" withValue:[NSNumber numberWithInt:self.media.serverID] inContext:context];
    comment.media = m;
    [m addCommentsObject:comment];
    [comment updateWithObject:obj inContext:context]; 
}

- (void)send:(UIButton*)sender
{
    [self.textfield resignFirstResponder];
    
    if (self.textfield.text)
    {
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];    
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if ([SWAPIClient isNetworkReachable])
            {         
                NSDictionary* param = [NSDictionary dictionaryWithObject:self.textfield.text forKey:@"content"];
                
                [[SWAPIClient sharedClient] postPath:[NSString stringWithFormat:@"/nodes/%d/comments", self.media.serverID]
                                         parameters:param 
                                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                
                                                [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
                                                    
                                                    [self addCommentObject:responseObject inContext:localContext];                                          
                                                    
                                                } completion:^{
                                                    self.textfield.text = @"";
                                                    [self reload];
                                                }];
                                            } 
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                NSLog(@"ERROR: %@", [error description]);
                                            }
                 ];
            }
            else 
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"not_connected", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                    [av show];                                                
                });
            }
        });
    }
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
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        self.toolbar.frame = CGRectMake(TOOLBAR_X, TOOLBAR_Y_PORTRAIT, self.view.frame.size.width, 50);
    }
    else 
    {
        self.toolbar.frame = CGRectMake(TOOLBAR_X, TOOLBAR_Y_LANDSCAPE, self.view.frame.size.width, 50);        
    }    
    
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        self.toolbar.frame = CGRectMake(TOOLBAR_X, TOOLBAR_Y_PORTRAIT, self.view.frame.size.width, 50);
    }
    else 
    {
        self.toolbar.frame = CGRectMake(TOOLBAR_X, TOOLBAR_Y_LANDSCAPE, self.view.frame.size.width, 50);        
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.tableView.contentSize.height > self.view.frame.size.height)
    {
        CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
        [self.tableView setContentOffset:bottomOffset animated:NO];
    } 
}

- (void)reload
{
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        
    } completion:^{
        self.comments = [SWComment findLatestCommentsForMediaID:self.media.serverID inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        
        [self.tableView reloadData];    
        
        if (self.tableView.contentSize.height > self.view.frame.size.height)
        {
            CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
            [self.tableView setContentOffset:bottomOffset animated:NO];
        }        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWComment* comment = [self.comments objectAtIndex:indexPath.row];
    CGFloat h = [SWCommentTableViewCell cellHeightWithText:comment.content];
    if (indexPath.row == [self.comments count])
        self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height + 500);
    return h;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWCommentTableViewCell* cell = [tv dequeueReusableCellWithIdentifier:@"CommentCell"];
    if (!cell)
    {
        cell = [[SWCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CommentCell"];
        cell.opaque = NO;
    }

    SWComment* comment = [self.comments objectAtIndex:indexPath.row];
    
    cell.thumbCommenter.image = [UIImage imageNamed:@"user@2x.png"];
    cell.commenter.text = [comment.author name];
    cell.commented.text = comment.createdDT;
    cell.comment.text = comment.content;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - UITextView Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Notifications
- (void)keyboardWillShow:(NSNotification *)aNotification {
    [self moveTextViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    [self moveTextViewForKeyboard:aNotification up:NO]; 
}

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up
{
    NSDictionary* userInfo = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    [self.scrollView setContentOffset:CGPointMake(0, (up ? keyboardFrame.size.height : 0)) animated:YES];
    
    [UIView commitAnimations];
}

@end
