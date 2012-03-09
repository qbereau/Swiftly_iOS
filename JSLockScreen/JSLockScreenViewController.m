//
//  JSLockScreenController.m
//  JSLockScreen
//
//  Copyright (c) 2011, James Addyman, JamSoft All rights reserved.
//	
//	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//	
//	Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//	Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//	Neither the name of the nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//	STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "JSLockScreenViewController.h"

@interface JSLockScreenViewController ()

- (void)cancel:(UITapGestureRecognizer *)tap;
- (void)dismiss;
- (void)checkPasscode;

@end

@implementation JSLockScreenViewController

@synthesize delegate = _delegate;
@synthesize isNewPasscode = _isNewPasscode;

- (id)initWithDelegate:(id <JSLockScreenDelegate>)delegate
{
	if ((self = [super initWithNibName:nil bundle:nil]))
	{
		self.delegate = delegate;
	}
	
	return self;
}

- (void)dealloc
{
	[_background release], _background = nil;
	
	[_headerView release], _headerView = nil;
	[_statusLabel release], _statusLabel = nil;
	[_tipLabel release], _tipLabel = nil;
	
	[_lockView release], _lockView = nil;
	[_passcodeField release], _passcodeField = nil;
	[_firstField release], _firstField = nil;
	[_secondField release], _firstField = nil;
	[_thirdField release], _thirdField = nil;
	[_fourthField release], _fourthField = nil;
	
	[_tap release], _tap = nil;
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_background = [[UIView alloc] initWithFrame:self.view.frame];
	[_background setBackgroundColor:[UIColor blackColor]];
	[_background setAlpha:0.0];
	[_background setOpaque:NO];
	[self.view addSubview:_background];
	
	_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel:)];
	[self.view addGestureRecognizer:_tap];
	
	_headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"passcodeTopBackground.png"]];
	[_headerView setFrame:CGRectMake(0, 0 - _headerView.frame.size.height, _headerView.frame.size.width, _headerView.frame.size.height)];
	[self.view addSubview:_headerView];
	
	_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(00, 15, 320, 45)];
	[_statusLabel setBackgroundColor:[UIColor clearColor]];
	[_statusLabel setOpaque:NO];
	[_statusLabel setTextAlignment:UITextAlignmentCenter];
	[_statusLabel setFont:[UIFont systemFontOfSize:30]];
	[_statusLabel setTextColor:[UIColor whiteColor]];
	[_statusLabel setShadowColor:[UIColor darkTextColor]];
	[_statusLabel setShadowOffset:CGSizeMake(0, -1)];
    if (self.isNewPasscode)
        [_statusLabel setText:NSLocalizedString(@"enter_new_passcode", @"enter passcode")];
    else
        [_statusLabel setText:NSLocalizedString(@"enter_passcode", @"enter passcode")];
	[_headerView addSubview:_statusLabel];
	
	_tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 320, 36)];
	[_tipLabel setBackgroundColor:[UIColor clearColor]];
	[_tipLabel setOpaque:NO];
	[_tipLabel setTextAlignment:UITextAlignmentCenter];
	[_tipLabel setFont:[UIFont systemFontOfSize:17]];
	[_tipLabel setTextColor:[UIColor whiteColor]];
	[_tipLabel setShadowColor:[UIColor darkTextColor]];
	[_tipLabel setShadowOffset:CGSizeMake(0, -1)];
    [_tipLabel setText:NSLocalizedString(@"tap_to_cancel", @"Tap to cancel")];
	[_headerView addSubview:_tipLabel];
	
	
	_lockView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock_background.png"]];
	[_lockView setFrame:CGRectMake(0, 480, _lockView.frame.size.width, _lockView.frame.size.height)];
	[self.view addSubview:_lockView];
	
	_passcodeField = [[UITextField alloc] initWithFrame:CGRectMake(320, 480, 10, 10)];
	[_passcodeField setDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textDidChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:_passcodeField];
	[_passcodeField setKeyboardType:UIKeyboardTypeNumberPad];
	[_passcodeField setKeyboardAppearance:UIKeyboardAppearanceAlert];
	[self.view addSubview:_passcodeField];
	
	_firstField = [[UITextField alloc] initWithFrame:CGRectMake(23, 23, 61, 52)];
	[_firstField setSecureTextEntry:YES];
	[_firstField setBackground:[UIImage imageNamed:@"passcodeFieldBackground.png"]];
	[_firstField setFont:[UIFont systemFontOfSize:40.0]];
	[_firstField setTextAlignment:UITextAlignmentCenter];
	[_firstField setEnabled:NO];
	
	_secondField = [[UITextField alloc] initWithFrame:CGRectMake(94, 23, 61, 52)];
	[_secondField setSecureTextEntry:YES];
	[_secondField setBackground:[UIImage imageNamed:@"passcodeFieldBackground.png"]];
	[_secondField setFont:[UIFont systemFontOfSize:40.0]];
	[_secondField setTextAlignment:UITextAlignmentCenter];
	[_secondField setEnabled:NO];
	
	_thirdField = [[UITextField alloc] initWithFrame:CGRectMake(165, 23, 61, 52)];
	[_thirdField setSecureTextEntry:YES];
	[_thirdField setBackground:[UIImage imageNamed:@"passcodeFieldBackground.png"]];
	[_thirdField setFont:[UIFont systemFontOfSize:40.0]];
	[_thirdField setTextAlignment:UITextAlignmentCenter];
	[_thirdField setEnabled:NO];
	
	_fourthField = [[UITextField alloc] initWithFrame:CGRectMake(236, 23, 61, 52)];
	[_fourthField setSecureTextEntry:YES];
	[_fourthField setBackground:[UIImage imageNamed:@"passcodeFieldBackground.png"]];
	[_fourthField setFont:[UIFont systemFontOfSize:40.0]];
	[_fourthField setTextAlignment:UITextAlignmentCenter];
	[_fourthField setEnabled:NO];
	
	[_lockView addSubview:_firstField];
	[_lockView addSubview:_secondField];
	[_lockView addSubview:_thirdField];
	[_lockView addSubview:_fourthField];
}

- (void)setIsNewPasscode:(BOOL)isNewPasscode
{
    _isNewPasscode = isNewPasscode;
    
    if (_isNewPasscode)
        [_statusLabel setText:NSLocalizedString(@"enter_new_passcode", @"enter new passcode")];
    else
        [_statusLabel setText:NSLocalizedString(@"enter_passcode", @"enter passcode")];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)showInWindow:(UIWindow *)window
{	
	[window addSubview:self.view];
	
	CGRect lockFrame = [_lockView frame];
	lockFrame.origin.y = 168;
	
	CGRect headerFrame = [_headerView frame];
	if (CGRectIsEmpty([[UIApplication sharedApplication] statusBarFrame]))
	{
		headerFrame.origin.y = 0;
	}
	else
	{
		headerFrame.origin.y = 20;
	}
	
	[_passcodeField becomeFirstResponder];
	_originalStatusStyle = [[UIApplication sharedApplication] statusBarStyle];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	
	[UIView animateWithDuration:0.3 animations:^{
		[_lockView setFrame:lockFrame];
		[_headerView setFrame:headerFrame];
		[_background setAlpha:0.33];
	}];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	BOOL retVal = YES;
	
	if ([[_passcodeField text] length] == 4)
	{
		if ((range.length == 1) && [string isEqualToString:@""])
		{
			retVal = YES;
		}
		else
		{
			retVal = NO;
		}
	}
	
	return retVal;
}

- (void)textDidChange:(NSNotification *)note
{
	NSUInteger length = [[_passcodeField text] length];
	
	if (length == 0)
	{
		[_firstField setText:@""];
		[_secondField setText:@""];
		[_thirdField setText:@""];
		[_fourthField setText:@""];
	}
	else if (length == 1)
	{
		[_firstField setText:[NSString stringWithFormat:@"%@", [[_passcodeField text] substringWithRange:NSMakeRange(0, 1)]]];
		[_secondField setText:@""];
		[_thirdField setText:@""];
		[_fourthField setText:@""];
	}
	else if (length == 2)
	{
		[_firstField setText:[NSString stringWithFormat:@"%@", [[_passcodeField text] substringWithRange:NSMakeRange(0, 1)]]];
		[_secondField setText:[NSString stringWithFormat:@"%@", [[_passcodeField text] substringWithRange:NSMakeRange(1, 1)]]];
		[_thirdField setText:@""];
		[_fourthField setText:@""];
	}
	else if (length == 3)
	{
		[_firstField setText:[NSString stringWithFormat:@"%@", [[_passcodeField text] substringWithRange:NSMakeRange(0, 1)]]];
		[_secondField setText:[NSString stringWithFormat:@"%@", [[_passcodeField text] substringWithRange:NSMakeRange(1, 1)]]];
		[_thirdField setText:[NSString stringWithFormat:@"%@", [[_passcodeField text] substringWithRange:NSMakeRange(2, 1)]]];
		[_fourthField setText:@""];
	}
	else if (length == 4)
	{
		[_firstField setText:[NSString stringWithFormat:@"%@", [[_passcodeField text] substringWithRange:NSMakeRange(0, 1)]]];
		[_secondField setText:[NSString stringWithFormat:@"%@", [[_passcodeField text] substringWithRange:NSMakeRange(1, 1)]]];
		[_thirdField setText:[NSString stringWithFormat:@"%@", [[_passcodeField text] substringWithRange:NSMakeRange(2, 1)]]];
		[_fourthField setText:[NSString stringWithFormat:@"%@", [[_passcodeField text] substringWithRange:NSMakeRange(3, 1)]]];
		
		[self performSelector:@selector(checkPasscode) withObject:nil afterDelay:0.3];
	}
}

- (void)checkPasscode
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:SWIFTLY_LOCK_ID accessGroup:nil];
    NSString* savedPasscode = [keychain objectForKey:(__bridge id)kSecValueData];    
	
	if ([[_passcodeField text] isEqualToString:savedPasscode])
	{		
		if ([self.delegate respondsToSelector:@selector(lockScreenDidUnlock:)])
		{
			[self.delegate lockScreenDidUnlock:self];
			
			[self dismiss];
		}
	}
	else
	{
		if ([self.delegate respondsToSelector:@selector(lockScreenFailedUnlock:)])
		{
			[self.delegate lockScreenFailedUnlock:self];
		}
		
		[_headerView setImage:[UIImage imageNamed:@"passcodeTopBackground_red.png"]];
		[_statusLabel setText:NSLocalizedString(@"wrong_passcode", @"wrong passcode")];
		[_tipLabel setText:NSLocalizedString(@"passcode_info_use", @"try again or tap to cancel")];
		[_passcodeField setText:@""];
	}	
}

- (void)cancel:(UITapGestureRecognizer *)tap
{
	if ([self.delegate respondsToSelector:@selector(lockScreenDidCancel:)])
	{
		[self.delegate lockScreenDidCancel:self];
	}
	
	[self dismiss];
}

- (void)dismiss
{	
	[_passcodeField setText:@""];
	[_passcodeField resignFirstResponder];
	[[UIApplication sharedApplication] setStatusBarStyle:_originalStatusStyle animated:YES];
	
	CGRect frame = [_lockView frame];
	frame.origin.y = 480;
	
	CGRect headerFrame = [_headerView frame];
	headerFrame.origin.y = 0 - headerFrame.size.height;
	
	[UIView animateWithDuration:0.3
					 animations:^{
						 [_lockView setFrame:frame];
						 [_headerView setFrame:headerFrame];
						 [_background setAlpha:0.0];
					 }
					 completion:^(BOOL finished){
						 [self.view removeFromSuperview];
					 }];
	if ([self.delegate respondsToSelector:@selector(lockScreenDidDismiss:)])
	{
		[self.delegate lockScreenDidDismiss:self];
	}
}

@end
