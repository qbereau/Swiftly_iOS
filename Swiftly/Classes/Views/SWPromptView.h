//
//  SWPromptView.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPromptView : UIAlertView
{
    UITextField *_textField;
}
@property (nonatomic, strong) UITextField *textField;
@property (readonly, weak) NSString *enteredText;

- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;

@end
