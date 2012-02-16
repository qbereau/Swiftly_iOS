//
//  SWPhotoScrollViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KTPhotoScrollViewController.h"
#import "SWWebImagesDataSource.h"
#import "SWCommmentsViewController.h"
#import "SWAPIClient.h"
#import "SWMedia.h"

@interface SWPhotoScrollViewController : KTPhotoScrollViewController
{
    NSArray*        _comments;
}

@property (nonatomic, strong) NSArray*         comments;

- (void)downloadComments;
- (void)updateExportPhotoButtonState;

@end
