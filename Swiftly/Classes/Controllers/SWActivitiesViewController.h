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

typedef void (^UploadDataBlock)(SWMedia*, NSData*, NSString*);

@interface SWActivitiesViewController : UIViewController
{
    NSArray*                _inProgress;
    NSArray*                _recent;
    
    UploadDataBlock         _uploadDataBlock;
    
    NSTimer*                _refreshTimer;
    NSMutableArray*         _arrExportSessions;
    
    NSInteger               _nbUploadElements;
}

@property (nonatomic, strong) NSArray*                  inProgress;
@property (nonatomic, strong) NSArray*                  recent;
@property (nonatomic, copy) UploadDataBlock             uploadDataBlock;      
@property (nonatomic, weak) IBOutlet UINavigationBar*   navigationBar;
@property (nonatomic, weak) IBOutlet SWTableView*       tableView;
@property (nonatomic, assign) NSInteger                 nbUploadElements;

- (void)launchRefreshTimer;
- (void)stopTimer;
- (void)updateRefresh:(NSTimer*)timer;
- (void)removeMedias:(id)sender;
- (void)reload;
- (void)uploadFiles;

@end
