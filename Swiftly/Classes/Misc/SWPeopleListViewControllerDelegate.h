//
//  SWPeopleListViewControllerDelegate.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SWPeopleListViewControllerDelegate <NSObject>

- (void)peopleListViewControllerDidSelectContacts:(NSArray*)selectedContacts;

@end