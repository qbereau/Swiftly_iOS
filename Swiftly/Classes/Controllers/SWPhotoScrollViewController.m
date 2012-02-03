//
//  SWPhotoScrollViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWPhotoScrollViewController.h"

@implementation SWPhotoScrollViewController

- (id)initWithDataSource:(id<KTPhotoBrowserDataSource>)dataSource andStartWithPhotoAtIndex:(NSUInteger)index
{
    return [super initWithDataSource:dataSource andStartWithPhotoAtIndex:index];
}

- (void)loadView
{
    [super loadView];
    
    UIBarButtonItem* btnComments = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comments"] style:UIBarButtonItemStylePlain target:self action:@selector(comments:)];
    self.navigationItem.rightBarButtonItem = btnComments;
}

- (void)comments:(UIBarButtonItem*)button
{
    NSLog(@"..");
}

@end
