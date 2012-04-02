//
//  PrivacyPolicyViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPrivacyPolicyViewController : UIViewController

@property (assign, nonatomic) BOOL                      isModal;
@property (weak, nonatomic) IBOutlet UIWebView*         webView;
@property (strong, nonatomic) UINavigationBar*          navigBar;

- (IBAction)done:(id)sender;

@end
