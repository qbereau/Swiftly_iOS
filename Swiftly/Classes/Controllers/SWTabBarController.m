//
//  SWTabBarController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWTabBarController.h"

@implementation SWTabBarController

- (void)viewDidLoad
{
    for (UITabBarItem* item in self.tabBar.items)
    {
        switch (item.tag)
        {
            case 0:
                item.title = NSLocalizedString(@"menu_albums", @"albums");
                break;
            case 1:
                item.title = NSLocalizedString(@"menu_activities", @"activities");
                break;
            case 2:
                item.title = NSLocalizedString(@"menu_share", @"share");
                break;
            case 3:
                item.title = NSLocalizedString(@"menu_people", @"people");
                break;
            case 4:
                item.title = NSLocalizedString(@"menu_settings", @"settings");
                break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNewMedias:)
                                                 name:@"SWReceivedNewMedias"
                                               object:nil
     ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetAlbumsBadgeValue:)
                                                 name:@"SWResetAlbumsBadgeValue"
                                               object:nil
     ];
}

- (void)receivedNewMedias:(NSNotification*)notification
{
    [[self.tabBar.items objectAtIndex:0] setBadgeValue:@"1"];
}

- (void)resetAlbumsBadgeValue:(NSNotification*)notification
{
    [[self.tabBar.items objectAtIndex:0] setBadgeValue:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
