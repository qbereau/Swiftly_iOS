//
//  SWLoginViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <Security/Security.h>
#import "SWRoundedRectView.h"
#import "UIAlertView+Blocks.h"
#import "RIButtonItem.h"
#import "SWAPIClient.h"
#import "SWPerson.h"
#import "SWTabBarController.h"
#import "SWPeopleListViewController.h"
#import "SWGroupListViewController.h"
#import "SWPhoneNumber.h"
#import "SWPrivacyPolicyViewController.h"

@interface SWLoginViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSMutableArray*         _countries;
    BOOL                    _alreadySetup;
    
    NSString*               _userPhoneNumber;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblChooseCountry;
@property (weak, nonatomic) IBOutlet UIButton *btnCountry;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblPhonePrefix;
@property (weak, nonatomic) IBOutlet UITextField *inputPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnValidate;
@property (weak, nonatomic) IBOutlet UIView *vLoginContainer;
@property (weak, nonatomic) IBOutlet UIView *vConfirmationCodeContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerCountries;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerLoading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerConfirmation;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnValidateConfirmation;
@property (weak, nonatomic) IBOutlet UILabel *lblValidateCodeDescription;
@property (weak, nonatomic) IBOutlet UITextField *inputValidationCode;

@property (strong, nonatomic) NSMutableArray *countries;
@property (assign, nonatomic) BOOL alreadySetup;

- (IBAction)changeCountries:(UIButton*)sender;
- (IBAction)validateLogin:(UIButton*)sender;
- (IBAction)back:(id)sender;
- (IBAction)validateCode:(id)sender;

- (void)setup;
- (void)accountValidated;
- (void)registerServiceWithUserID:(int)userID;
- (void)codeValidatedWithUserID:(int)userID serviceID:(int)serviceID;
- (void)codeNotValidated;
- (void)gotoApp;
- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;

@end
