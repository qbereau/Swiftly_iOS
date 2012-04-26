//
//  SWAppDelegate.m
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAppDelegate.h"
#import "SWLoginViewController.h"

@implementation SWAppDelegate

@synthesize window = _window;

static int sID = -1;
+ (int)serviceID
{
    if (sID != -1)
        return sID;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    sID = [defaults integerForKey:@"sid"];        
    return sID;
}

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
    
    UIImage *segmentSelectedLandscape    = [[UIImage imageNamed:@"segcontrol_sel_landscape"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImage *segmentUnselectedLandscape  = [[UIImage imageNamed:@"segcontrol_unsel_landscape"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    UIImage *segmentSelectedUnselected   = [UIImage imageNamed:@"segcontrol_left_sel_right_unsel"];
    UIImage *segUnselectedSelected       = [UIImage imageNamed:@"segcontrol_left_unsel_right_sel"];
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segcontrol_left_unsel_right_unsel"];
    
    UIImage *segmentSelectedUnselectedLandscape   = [UIImage imageNamed:@"segcontrol_left_sel_right_unsel_landscape"];
    UIImage *segUnselectedSelectedLandscape       = [UIImage imageNamed:@"segcontrol_left_unsel_right_sel_landscape"];
    UIImage *segmentUnselectedUnselectedLandscape = [UIImage imageNamed:@"segcontrol_left_unsel_right_unsel_landscape"];
    
    [[UISegmentedControl appearance] setBackgroundImage:segmentUnselected 
                                               forState:UIControlStateNormal 
                                             barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:segmentSelected 
                                               forState:UIControlStateSelected 
                                             barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setBackgroundImage:segmentUnselectedLandscape 
                                               forState:UIControlStateNormal 
                                             barMetrics:UIBarMetricsLandscapePhone];
    [[UISegmentedControl appearance] setBackgroundImage:segmentSelectedLandscape 
                                               forState:UIControlStateSelected 
                                             barMetrics:UIBarMetricsLandscapePhone];
    
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
    
    [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselectedLandscape 
                                 forLeftSegmentState:UIControlStateNormal 
                                   rightSegmentState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsLandscapePhone];
    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselectedLandscape 
                                 forLeftSegmentState:UIControlStateSelected 
                                   rightSegmentState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsLandscapePhone];
    [[UISegmentedControl appearance] setDividerImage:segUnselectedSelectedLandscape 
                                 forLeftSegmentState:UIControlStateNormal 
                                   rightSegmentState:UIControlStateSelected 
                                          barMetrics:UIBarMetricsLandscapePhone];
}

- (void)dealloc
{
    [MagicalRecordHelpers cleanUp];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [SWAPIClient sharedClient];
    
    [self customizeUI];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    [MagicalRecordHelpers setupCoreDataStackWithStoreNamed:@"SwiftlyCD.sqlite"];  
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    [application beginBackgroundTaskWithExpirationHandler:^(void) {
        [[SWAPIClient sharedClient] cancelAllHTTPOperationsWithMethod:nil path:nil];
    }];    
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
    
    
    // should deal with notification type (comments, albums, medias, ...)
    application.applicationIconBadgeNumber = 0;     
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Received Data: %@", userInfo);
    
    if (application.applicationState != UIApplicationStateActive)
        application.applicationIconBadgeNumber += 1;
    
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        SWAlbum* album = [SWAlbum MR_findFirstByAttribute:@"serverID" withValue:[userInfo valueForKey:@"album_id"] inContext:localContext];
        album.updated = YES;
    } completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SWReceivedNewMedias" object:nil];        
    }];    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:token forKey:@"device_token"];
    [defaults synchronize];
} 

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error 
{
	NSLog(@"Error in registration. Error: %@", error); 
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
