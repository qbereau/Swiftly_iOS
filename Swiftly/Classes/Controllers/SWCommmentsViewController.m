//
//  SWCommmentsViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWCommmentsViewController.h"


@implementation SWCommmentsViewController

@synthesize textfield = _textField;
@synthesize media = _media;
@synthesize tableView = _tableView;
@synthesize toolbar = _toolbar;
@synthesize scrollView = _scrollView;
@synthesize comments = _comments;

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
    self.textfield.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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
    self.toolbar.frame = CGRectMake(0, 371, 320, 50);
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    UIBarButtonItem *textFieldItem = [[UIBarButtonItem alloc] initWithCustomView:self.textfield];
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btnSend];
    [self.toolbar setItems:[NSArray arrayWithObjects:textFieldItem, btnItem, nil]];
    [self.scrollView addSubview:self.toolbar];

    self.comments = [SWComment findLatestCommentsForMediaID:self.media.serverID];
    [self reload];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];        
        [[SWAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/medias/%d/comments", self.media.serverID]
                                                            parameters:nil 
                                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                   if ([responseObject isKindOfClass:[NSArray class]])
                                                                   {
                                                                       for (id obj in responseObject)
                                                                       {
                                                                           SWComment* comment = [SWComment findObjectWithServerID:[[obj valueForKey:@"id"] intValue]];
                                                                           
                                                                           if (!comment)
                                                                               comment = [SWComment createEntity];
                                                                           
                                                                           comment.media = self.media;                                                                           
                                                                           [comment updateWithObject:obj];
                                                                       }
                                                                       
                                                                       [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
                                                                       self.comments  = [SWComment findLatestCommentsForMediaID:self.media.serverID];
                                                                       
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           [self reload];
                                                                       });
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

- (void)send:(UIButton*)sender
{
    [self.textfield resignFirstResponder];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        NSDictionary* param = [NSDictionary dictionaryWithObject:self.textfield.text forKey:@"content"];
        [[SWAPIClient sharedClient] postPath:[NSString stringWithFormat:@"/medias/%d/comments", self.media.serverID]
                                 parameters:param 
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {

                                        SWComment* comment = [SWComment createEntity];
                                        comment.media = self.media;
                                        [comment updateWithObject:responseObject];

                                        [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
                                        
                                        self.comments  = [SWComment findLatestCommentsForMediaID:self.media.serverID];
                                            
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            self.textfield.text = @"";
                                            [self reload];
                                        });
                                    } 
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        
                                    }
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)reload
{
    [self.tableView reloadData];
    CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
    [self.tableView setContentOffset:bottomOffset animated:NO];    
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
