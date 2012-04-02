//
//  PrivacyPolicyViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPrivacyPolicyViewController.h"

@interface SWPrivacyPolicyViewController ()

@end

@implementation SWPrivacyPolicyViewController

@synthesize isModal;
@synthesize navigBar;
@synthesize webView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    if (self.isModal)
    {
        self.navigBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        
        UINavigationItem *currentItem = [[UINavigationItem alloc] init];
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setText:NSLocalizedString(@"privacy_policy", @"Privacy Policy")];
        [label sizeToFit];
        [currentItem setTitleView:label];
        
        currentItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        
        [self.navigBar pushNavigationItem:currentItem animated:NO];
        
        [self.view addSubview:self.navigBar];
        self.webView.frame = CGRectMake(0, self.navigBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigBar.frame.size.height);
    }
    else 
    {
        self.navigationItem.title = NSLocalizedString(@"privacy_policy", @"Privacy Policy");
        self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    
    //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];    
    NSString* policy = [NSString stringWithFormat:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod iaculis tincidunt. Nam molestie sagittis leo ac sagittis. Nam at libero erat. Cras scelerisque consectetur ligula a lacinia. Phasellus placerat, mauris eget blandit faucibus, massa erat ornare nisl, nec viverra massa enim vel libero. Aliquam tempor lobortis quam, id commodo augue aliquet et. Morbi eget dignissim turpis. Nunc aliquam libero magna, a tristique nisi. Nam gravida molestie ligula, nec ultrices elit facilisis nec. Morbi eu quam eu tortor dictum aliquet ut in lorem. Pellentesque molestie adipiscing elit vitae mollis. Donec accumsan velit nec nulla elementum at tincidunt lorem sagittis. Integer vel lobortis nisl. Etiam vulputate aliquam felis non molestie.<p/> \n"
    
    "Phasellus accumsan elementum enim, eget gravida diam accumsan ac. Sed sem massa, sollicitudin at ullamcorper eget, laoreet at eros. Integer laoreet auctor est vehicula rhoncus. Aenean tincidunt erat vel magna porttitor vehicula. Praesent urna erat, accumsan id tincidunt id, ultrices non nulla. In molestie, mi quis convallis egestas, mauris magna dapibus dolor, id gravida elit dui sed lacus. Morbi sapien turpis, suscipit vitae interdum eu, egestas eu odio. Nullam pulvinar lobortis ultricies.<p/>\n"
    
    "Nam at ante magna. Proin elementum eleifend pharetra. Duis non pretium sem. Sed diam justo, tempus sit amet vulputate sit amet, euismod vitae urna. Vestibulum dapibus augue a sapien fringilla non posuere purus volutpat. Sed ac molestie nunc. In porta condimentum sem non ornare. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Phasellus diam ante, cursus a pellentesque vitae, tincidunt non tortor. Sed quam velit, facilisis vel aliquet quis, tempus non dui. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus ultricies, urna sed tristique pretium, eros velit blandit libero, id pharetra enim mauris sed metus. Donec ut purus ante, quis eleifend turpis. Maecenas ac felis mi, ut dictum mi. Fusce pellentesque nisi nec lorem elementum consequat. Curabitur tincidunt ligula at lorem dignissim cursus.<p/>\n"
    
    "Vivamus luctus lacus eu ante ullamcorper vitae adipiscing leo rutrum. Nulla vehicula condimentum elit at dapibus. Sed at rhoncus est. Donec non urna mi. Aenean placerat elit ut magna varius suscipit. Mauris dictum, lacus vitae imperdiet mollis, lectus ipsum feugiat lectus, ut consequat mauris magna eu risus. Aenean imperdiet vulputate lectus, cursus vehicula odio venenatis id. Quisque ac mi mi, quis sagittis velit. Quisque in lacus in ipsum posuere elementum. Quisque ullamcorper sapien mauris.<p/>\n"
    
    "Aliquam egestas feugiat sem, ut dictum lacus varius ut. Sed vitae tincidunt urna. Curabitur felis elit, viverra et gravida eu, tempor a lorem. Proin elementum arcu id neque auctor vitae tristique urna rhoncus. Quisque ornare tellus eu nunc convallis vestibulum. Phasellus varius ullamcorper feugiat. Ut urna arcu, tempor eu pretium tincidunt, luctus sit amet lacus. Quisque nibh eros, volutpat at lacinia nec, convallis porta lacus. Aliquam orci erat, volutpat pharetra luctus euismod, varius ac erat. Sed porttitor lacinia interdum. Maecenas tincidunt lorem lacinia ante sagittis commodo. Donec bibendum augue vitae tortor auctor cursus. Proin cursus metus vitae ipsum vestibulum dictum.\n"];
    [self.webView loadHTMLString:policy baseURL:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
