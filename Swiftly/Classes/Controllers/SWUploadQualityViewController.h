//
//  SWUploadQualityViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWTableView.h"
#import "SWTableViewCell.h"

#define UPLOAD_QUALITY_KEY_HIGH         0
#define UPLOAD_QUALITY_KEY_MEDIUM       1
#define UPLOAD_QUALITY_KEY_LOW          2

@interface SWUploadQualityViewController : UITableViewController
{
    NSInteger           _imageSettings;
    NSInteger           _videoSettings;    
}

+ (NSInteger)imageQuality;
+ (NSInteger)videoQuality;

@end
