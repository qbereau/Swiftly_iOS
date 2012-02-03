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
}

@end
