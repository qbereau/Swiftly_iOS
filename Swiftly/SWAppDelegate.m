//
//  SWAppDelegate.m
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAppDelegate.h"

@implementation SWAppDelegate

@synthesize window = _window;

- (void)customizeUI
{
    [[UITabBar appearance] setBackgroundImage:[[UIImage imageNamed:@"bottom_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
    //[[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"topbar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"topbar_landscape"] forBarMetrics:UIBarMetricsLandscapePhone];
    
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"topbar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"topbar_landscape"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsLandscapePhone];
    
    // Bar - Normal Button
    UIImage *button30 = [[UIImage imageNamed:@"rounded_button"] 
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    UIImage *button24 = [[UIImage imageNamed:@"rounded_button_landscape"] 
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [[UIBarButtonItem appearance] setBackgroundImage:button30 forState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:button24 forState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsLandscapePhone];
    
    // Bar - Back Button
    UIImage *buttonBack30 = [[UIImage imageNamed:@"back_button"] 
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
    UIImage *buttonBack24 = [[UIImage imageNamed:@"back_button_landscape"] 
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 4)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack30 
                                                      forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack24 
                                                      forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    // Segmented Control
    UIImage *segmentSelected    = [[UIImage imageNamed:@"segcontrol_sel"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImage *segmentUnselected  = [[UIImage imageNamed:@"segcontrol_unsel"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    UIImage *segmentSelectedUnselected   = [UIImage imageNamed:@"segcontrol_left_sel_right_unsel"];
    UIImage *segUnselectedSelected       = [UIImage imageNamed:@"segcontrol_left_unsel_right_sel"];
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segcontrol_left_unsel_right_unsel"];
    
    [[UISegmentedControl appearance] setBackgroundImage:segmentUnselected 
                                               forState:UIControlStateNormal 
                                             barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:segmentSelected 
                                               forState:UIControlStateSelected 
                                             barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected 
                                 forLeftSegmentState:UIControlStateNormal 
                                   rightSegmentState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected 
                                 forLeftSegmentState:UIControlStateSelected 
                                   rightSegmentState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segUnselectedSelected 
                                 forLeftSegmentState:UIControlStateNormal 
                                   rightSegmentState:UIControlStateSelected 
                                          barMetrics:UIBarMetricsDefault];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self customizeUI];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
