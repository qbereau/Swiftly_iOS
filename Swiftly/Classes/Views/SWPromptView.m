//
//  SWPromptView.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPromptView.h"

@implementation SWPromptView

@synthesize textField = _textField;
@synthesize enteredText;

- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    
    if (self = [super initWithTitle:title message:@" " delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
    {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 30.0)]; 
        theTextField.keyboardType = UIKeyboardTypeNumberPad;
        theTextField.secureTextEntry = YES;
        [theTextField setTextAlignment:UITextAlignmentCenter];
        theTextField.font = [UIFont systemFontOfSize:24];
        [theTextField setBackgroundColor:[UIColor whiteColor]]; 
        [self addSubview:theTextField];
        self.textField = theTextField;
    }
    return self;
}
- (void)show
{
    [self.textField becomeFirstResponder];
    [super show];
}
- (NSString *)enteredText
{
    return self.textField.text;
}

@end
