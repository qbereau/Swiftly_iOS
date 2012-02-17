//
//  SWLoginViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWLoginViewController.h"

#define PICKER_DEFAULT_POS_Y 460
#define PICKER_EXPANDED_POS_Y 244
#define SCROLLVIEW_OFFSET 213
#define LOGO_DEFAULT_POS_X 36
#define LOGO_DEFAULT_POS_Y 120
#define LOGO_FINAL_POS_Y 10
#define VIEW_CONTAINER_RIGHT_POS_X 320
#define VIEW_CONTAINER_CENTER_POS_X 14
#define VIEW_CONTAINER_LEFT_POS_X -320

@implementation SWLoginViewController

@synthesize imgViewLogo;
@synthesize lblDescription;
@synthesize lblChooseCountry;
@synthesize btnCountry;
@synthesize lblPhoneNumber;
@synthesize lblPhonePrefix;
@synthesize inputPhoneNumber;
@synthesize btnValidate;
@synthesize vLoginContainer;
@synthesize vConfirmationCodeContainer;
@synthesize scrollView;
@synthesize pickerCountries;
@synthesize spinnerLoading;
@synthesize spinnerConfirmation;
@synthesize btnBack;
@synthesize btnValidateConfirmation;
@synthesize lblValidateCodeDescription;
@synthesize inputValidationCode;

@synthesize countries = _countries;
@synthesize alreadySetup = _alreadySetup;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{  
    [super viewDidAppear:animated];
    
    // For Dev, instead of having to resubscribe....
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:SWIFTLY_APP_ID accessGroup:nil];
    [keychain setObject:@"230f968cc82b07512dbd4fbca171ecfc" forKey:(__bridge id)kSecAttrAccount];
    [keychain setObject:@"050C8E67053DD789D5641D198BC08757" forKey:(__bridge id)kSecValueData];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"account_activated"];
    [defaults synchronize];
    
    //---------
    
    NSDictionary* dict              = [SWAPIClient userCredentials];
    NSString* key                   = (NSString*)[dict objectForKey:@"key"];
    NSString* token                 = (NSString*)[dict objectForKey:@"token"];
    NSNumber* account_validated     = (NSNumber*)[dict objectForKey:@"account_activated"];

    if (key && token && key.length > 0 && token.length > 0 && [account_validated boolValue])
    {
        [self gotoApp];
    }
    else if (!self.alreadySetup)
    {
        [self setup];
    }
}

- (void)viewDidLoad
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Countries" ofType:@"plist"];
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    self.countries = [plistDict objectForKey:@"countries"];    
    
    self.view.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setImgViewLogo:nil];
    [self setLblDescription:nil];
    [self setLblChooseCountry:nil];
    [self setBtnCountry:nil];
    [self setLblPhoneNumber:nil];
    [self setLblPhonePrefix:nil];
    [self setInputPhoneNumber:nil];
    [self setBtnValidate:nil];
    [self setVLoginContainer:nil];
    [self setScrollView:nil];
    [self setPickerCountries:nil];
    [self setSpinnerLoading:nil];
    [self setVConfirmationCodeContainer:nil];
    [self setSpinnerConfirmation:nil];
    [self setBtnBack:nil];
    [self setBtnValidateConfirmation:nil];
    [self setLblValidateCodeDescription:nil];
    [self setInputValidationCode:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setup
{
    self.alreadySetup = YES;
    self.view.hidden = NO;
    self.lblPhonePrefix.text = @"";
    self.spinnerLoading.hidden = YES;
    
    // Try to get country 
    CTTelephonyNetworkInfo *info = [CTTelephonyNetworkInfo new];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSString* countryCode = carrier.isoCountryCode;
    if (!countryCode)
    {
        // Set default to US
        countryCode = @"US";
    }
    
    for (NSDictionary *dict in self.countries)
    {
        if ([[[dict objectForKey:@"country_code"] lowercaseString] isEqualToString:[countryCode lowercaseString]])
        {
            [self.btnCountry setTitle:[dict objectForKey:@"country_name"] forState:UIControlStateNormal];
            [self.lblPhonePrefix setText:[NSString stringWithFormat:@"+%@", [dict objectForKey:@"phone_prefix"]]];
            break;
        }
    }
    
    // ----
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.lblDescription.text = NSLocalizedString(@"login_description", @"please enter phone number...");
    self.lblChooseCountry.text = NSLocalizedString(@"login_choose_country", @"choose your country");
    self.lblPhoneNumber.text = NSLocalizedString(@"login_enter_phone", @"enter your phone number");
    self.lblValidateCodeDescription.text = NSLocalizedString(@"login_sms_instruction", @"You'll receive a code via SMS in a few seconds.");
    
    self.vLoginContainer.frame = CGRectMake(VIEW_CONTAINER_RIGHT_POS_X, self.vLoginContainer.frame.origin.y, self.vLoginContainer.frame.size.width, self.vLoginContainer.frame.size.height);
    [self.vLoginContainer.layer setCornerRadius:10.0f];
    [self.vLoginContainer.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.vLoginContainer.layer setBorderWidth:0.5f];
    [self.vLoginContainer.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.vLoginContainer.layer setShadowOpacity:0.8];
    [self.vLoginContainer.layer setShadowRadius:1.0];
    [self.vLoginContainer.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    
    self.vConfirmationCodeContainer.frame = CGRectMake(VIEW_CONTAINER_RIGHT_POS_X, self.vConfirmationCodeContainer.frame.origin.y, self.vConfirmationCodeContainer.frame.size.width, self.vLoginContainer.frame.size.height);
    [self.vConfirmationCodeContainer.layer setCornerRadius:10.0f];
    [self.vConfirmationCodeContainer.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.vConfirmationCodeContainer.layer setBorderWidth:0.5f];
    [self.vConfirmationCodeContainer.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.vConfirmationCodeContainer.layer setShadowOpacity:0.8];
    [self.vConfirmationCodeContainer.layer setShadowRadius:1.0];
    [self.vConfirmationCodeContainer.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    self.imgViewLogo.frame = CGRectMake(LOGO_DEFAULT_POS_X, LOGO_DEFAULT_POS_Y, imgViewLogo.frame.size.width, imgViewLogo.frame.size.height);
    
    [UIView animateWithDuration:1.0
                          delay:0.5
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.imgViewLogo.alpha = 1.0;
                     } 
                     completion:^(BOOL f1){
                         [UIView animateWithDuration:1.0
                                               delay:0.0
                                             options: UIViewAnimationCurveEaseIn
                                          animations:^{
                                              self.imgViewLogo.frame = CGRectMake(imgViewLogo.frame.origin.x, LOGO_FINAL_POS_Y, imgViewLogo.frame.size.width, imgViewLogo.frame.size.height);
                                          } 
                                          completion:^(BOOL f2){
                                              [UIView animateWithDuration:0.25
                                                                    delay:0.5
                                                                  options: UIViewAnimationCurveEaseInOut
                                                               animations:^{
                                                                   self.vLoginContainer.frame    = CGRectMake(VIEW_CONTAINER_CENTER_POS_X, self.vLoginContainer.frame.origin.y, self.vLoginContainer.frame.size.width, self.vLoginContainer.frame.size.height);
                                                               }
                                                               completion:^(BOOL f3) {
                                                                   
                                                               }];
                                          }];
                     }];
}

- (void)accountValidated
{
    self.btnBack.hidden = NO;
    self.btnValidateConfirmation.hidden = NO;
    self.spinnerConfirmation.hidden = YES;
    
    // Simply go to ConfirmationCodeViewContainer
    [UIView animateWithDuration:0.25
                          delay:0.5
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.vLoginContainer.frame = CGRectMake(VIEW_CONTAINER_LEFT_POS_X, self.vLoginContainer.frame.origin.y, self.vLoginContainer.frame.size.width, self.vLoginContainer.frame.size.height);
                        self.vConfirmationCodeContainer.frame = CGRectMake(VIEW_CONTAINER_CENTER_POS_X, self.vConfirmationCodeContainer.frame.origin.y, self.vLoginContainer.frame.size.width, self.vConfirmationCodeContainer.frame.size.height);
                     }
                     completion:^(BOOL f3) {
                         [self.spinnerLoading stopAnimating];
                         self.spinnerLoading.hidden = YES;
                         self.btnValidate.hidden = NO;
                     }];
}

- (void)codeValidatedWithKey:(NSString*)key token:(NSString*)token userID:(int)userID
{
    // Save to Keychain
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:SWIFTLY_APP_ID accessGroup:nil];
    [keychain setObject:key forKey:(__bridge id)kSecAttrAccount];
    [keychain setObject:token forKey:(__bridge id)kSecValueData];
    
    // Also save a dummy BOOL that will be erased if the deletes the app
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"account_activated"];
    [defaults synchronize];
    
    // Still needs to push device token
    NSString* deviceToken = [defaults valueForKey:@"device_token"];
    if (deviceToken.length > 0)
    {
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    deviceToken, @"uuid",
                                    [NSNumber numberWithBool:YES], @"enabled",
                                nil];
        NSDictionary* registerDevice = [NSDictionary dictionaryWithObject:params forKey:@"register_device"];
        [[SWAPIClient sharedClient] putPath:[NSString stringWithFormat:@"/accounts/%d", userID] 
                                  parameters:registerDevice 
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         [self gotoApp];
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [self gotoApp];
                                         NSLog(@"error");
                                     }
         ];         
    }
    else
    {
        [self gotoApp];
    }
}

- (void)codeNotValidated
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedString(@"login_code_not_validated", @"the code you entered was not correct")
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self.spinnerConfirmation stopAnimating];
    self.spinnerConfirmation.hidden = YES;
    self.btnValidateConfirmation.hidden = NO;
}

- (void)gotoApp
{    
    [self performSegueWithIdentifier:@"goto_app" sender:self];
}

#pragma mark - Actions
- (IBAction)changeCountries:(UIButton*)sender
{
    [self.inputPhoneNumber resignFirstResponder];
    
    if (self.pickerCountries.frame.origin.y >= PICKER_DEFAULT_POS_Y)
    {
        self.pickerCountries.hidden = NO;
        self.pickerCountries.frame = CGRectMake(0, PICKER_DEFAULT_POS_Y, self.pickerCountries.frame.size.width, self.pickerCountries.frame.size.height);
        [UIView animateWithDuration:0.25
                            delay:0.0
                            options: UIViewAnimationCurveEaseIn
                            animations:^{
                                self.pickerCountries.frame = CGRectMake(0, PICKER_EXPANDED_POS_Y, self.pickerCountries.frame.size.width, self.pickerCountries.frame.size.height);
                                self.scrollView.frame = CGRectMake(0, self.scrollView.frame.origin.y - SCROLLVIEW_OFFSET, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                            }
                            completion:^(BOOL f1){

                            }];
    }
}

- (IBAction)validateLogin:(UIButton*)sender
{
    if ([self.inputPhoneNumber.text length] > 0)
    {
        [self.inputPhoneNumber resignFirstResponder];
        
        self.btnValidate.hidden     = YES;
        self.spinnerLoading.hidden  = NO;
        [self.spinnerLoading startAnimating];
        
        // Check API
        _userPhoneNumber = [NSString stringWithFormat:@"%@%@", self.lblPhonePrefix.text, self.inputPhoneNumber.text];
        NSDictionary* dict = [NSDictionary dictionaryWithObject:_userPhoneNumber forKey:@"phone_number"];
        [[SWAPIClient sharedClient] postPath:@"/accounts" 
                                  parameters:dict 
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) 
                                     {
                                         [self accountValidated];
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) 
                                     {
                                         UIAlertView* alert = [[UIAlertView alloc] 
                                                               initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"login_error_login", @"maybe you tried too many times")
                                                               delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                                         [alert show];
                                         
                                         self.btnValidate.hidden = NO;
                                         self.spinnerLoading.hidden  = YES;
                                         [self.spinnerLoading stopAnimating];
                                     }
         ];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"login_error_phone", @"please enter a phone number")
                                                        delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)back:(UIButton*)sender
{
    [self.inputValidationCode resignFirstResponder];
    
    // Simply go to LoginViewContainer
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.vLoginContainer.frame = CGRectMake(VIEW_CONTAINER_CENTER_POS_X, self.vLoginContainer.frame.origin.y, self.vLoginContainer.frame.size.width, self.vLoginContainer.frame.size.height);
                         self.vConfirmationCodeContainer.frame = CGRectMake(VIEW_CONTAINER_RIGHT_POS_X, self.vConfirmationCodeContainer.frame.origin.y, self.vLoginContainer.frame.size.width, self.vConfirmationCodeContainer.frame.size.height);
                     }
                     completion:^(BOOL f3) {
                         
                     }];
}

- (IBAction)validateCode:(UIButton*)sender
{
    [self.inputPhoneNumber resignFirstResponder];
    [self.inputValidationCode resignFirstResponder];    
    
    self.btnValidateConfirmation.hidden = YES;
    self.btnBack.hidden = NO;

    self.spinnerConfirmation.hidden = NO;
    self.spinnerConfirmation.center = sender.center;
    [self.spinnerConfirmation startAnimating];
    
    // API Call
    NSString* code = self.inputValidationCode.text;
    NSDictionary* dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_userPhoneNumber, code, nil] forKeys:[NSArray arrayWithObjects:@"phone_number", @"activation_code", nil]];
    [[SWAPIClient sharedClient] postPath:@"/accounts/activate" 
                              parameters:dict 
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) 
                                        {
                                            NSString* key = (NSString*)[responseObject valueForKey:@"key"];
                                            NSString* token = (NSString*)[responseObject valueForKey:@"token"];
                                            int userID = [[responseObject valueForKey:@"id"] intValue];
                                            
                                            SWPerson* user = [SWPerson createEntity];
                                            user.serverID       = userID;
                                            user.phoneNumber    = _userPhoneNumber;
                                            user.isSelf         = YES;
                                            [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
                                            
                                            [self codeValidatedWithKey:key token:token userID:userID];
                                        }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) 
                                        {
                                            [self codeNotValidated];
                                        }
     ];    
}

#pragma mark - Notifications
- (void)keyboardWillShow:(NSNotification *)aNotification {
    
    if (self.pickerCountries.frame.origin.y >= PICKER_DEFAULT_POS_Y)
        [self moveTextViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification *)aNotification 
{
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

#pragma mark - UITextView Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIPickerView Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView 
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{    
    return [self.countries count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component 
{
    return [[self.countries objectAtIndex:row] objectForKey:@"country_name"];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component 
{
    self.pickerCountries.hidden = NO;
    self.pickerCountries.frame = CGRectMake(0, PICKER_EXPANDED_POS_Y, self.pickerCountries.frame.size.width, self.pickerCountries.frame.size.height);
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.pickerCountries.frame = CGRectMake(0, PICKER_DEFAULT_POS_Y, self.pickerCountries.frame.size.width, self.pickerCountries.frame.size.height);
                         self.scrollView.frame = CGRectMake(0, self.scrollView.frame.origin.y + SCROLLVIEW_OFFSET, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                     }
                     completion:^(BOOL f1){
                         [self.btnCountry setTitle:[[self.countries objectAtIndex:row] objectForKey:@"country_name"] forState:UIControlStateNormal];
                         [self.lblPhonePrefix setText:[NSString stringWithFormat:@"+%@", [[self.countries objectAtIndex:row] objectForKey:@"phone_prefix"]]];
                     }];
}

@end
