//
//  SWSecondViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableView.h"
#import "SWActivityTableViewCell.h"
#import "SWMedia.h"
#import "SWMedia+Details.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AVFoundation/AVFoundation.h>
#import "AFNetworking.h"
#import "SWAPIClient.h"

typedef void (^UploadDataBlock)(SWMedia*, NSData*);

@interface SWActivitiesViewController : UIViewController
{
    NSArray*                _inProgress;
    NSArray*                _recent;
    
    UploadDataBlock         _uploadDataBlock;
    NSMutableArray*         _arrUploadState;
}

@property (nonatomic, strong) NSArray*                  inProgress;
@property (nonatomic, strong) NSArray*                  recent;
@property (nonatomic, strong) NSMutableArray*           arrUploadState;
@property (nonatomic, copy) UploadDataBlock             uploadDataBlock;      
@property (nonatomic, weak) IBOutlet UINavigationBar*   navigationBar;
@property (nonatomic, weak) IBOutlet SWTableView*       tableView;

- (void)reload;
- (void)uploadFiles;

@end
