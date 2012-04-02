//
//  SWSecondViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWActivitiesViewController.h"

@implementation SWActivitiesViewController

@synthesize navigationBar;
@synthesize tableView;
@synthesize inProgress = _inProgress;
@synthesize recent = _recent;
@synthesize uploadDataBlock = _uploadDataBlock;
@synthesize nbUploadElements = _nbUploadElements;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _arrExportSessions = [NSMutableArray array];
      
    self.navigationBar.topItem.title = NSLocalizedString(@"menu_activities", @"Activities");
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];
    
    __block SWActivitiesViewController* blockSelf = self;
    self.uploadDataBlock = ^(SWMedia* m, NSData* data, NSString* filePath) {
            
            NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys: 
                                     m.filename, @"key", 
                                     m.awsAccessKeyID, @"AWSAccessKeyId",
                                     m.acl, @"acl",
                                     m.policy, @"policy",
                                     m.signature, @"signature",
                                     m.contentType, @"Content-Type",
                                     nil];
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:m.bucketURL]];                               
            NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"" parameters:headers constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                [formData appendPartWithFileData:data name:@"file" fileName:m.filename mimeType:m.contentType];
            }];

            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            __weak AFHTTPRequestOperation* op = operation;
            [operation setUploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
                
                if (m.isCancelled)
                {
                    [op cancel];
                    return;
                }
                
                if (m.isVideo)
                    m.uploadProgress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite / 2 + 0.5f;
                else
                    m.uploadProgress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;

                [blockSelf launchRefreshTimer];
            }];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObject:m.signature forKey:@"signature"];
                --blockSelf.nbUploadElements;
                if (blockSelf.nbUploadElements <= 0)
                    [params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"notify"]];
                
                [[SWAPIClient sharedClient] putPath:[NSString stringWithFormat:@"/medias/%d/confirm_upload", m.serverID]
                                         parameters:params
                                            success:^(AFHTTPRequestOperation *opReq, id respObjReq) {
                                                
                                                [MRCoreDataAction saveDataWithBlock:^(NSManagedObjectContext *localContext) {
                                                    
                                                    SWMedia* media = [SWMedia MR_findFirstByAttribute:@"serverID" withValue:[NSNumber numberWithInt:m.serverID] inContext:localContext];
                                                    media.uploadProgress = 1.0f;
                                                    media.isUploaded = YES;
                                                    media.uploadedDate = [[NSDate date] timeIntervalSinceReferenceDate];
                                                    
                                                    NSError *errDel;
                                                    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath])
                                                    {
                                                        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&errDel])
                                                        {
                                                            NSLog(@"Delete file error: %@", errDel);
                                                        }
                                                    }
                                                    
                                                    [blockSelf reload];
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SWUploadMediaDone" object:m];                                                      
                                                }];
                                            }
                                            failure:^(AFHTTPRequestOperation *opReq, NSError *errorReq) {
                                                
                                                [MRCoreDataAction saveDataWithBlock:^(NSManagedObjectContext *localContext) {
                                                    
                                                    SWMedia* media = [SWMedia MR_findFirstByAttribute:@"serverID" withValue:[NSNumber numberWithInt:m.serverID] inContext:localContext];
                                                    media.uploadProgress = 1.0f;
                                                    media.isUploaded = YES;
                                                    media.uploadedDate = [[NSDate date] timeIntervalSinceReferenceDate];                                           
                                                    
                                                    NSError *errDel;
                                                    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath])
                                                    {
                                                        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&errDel])
                                                        {
                                                            NSLog(@"Delete file error: %@", errDel);
                                                        }
                                                    }                                                
                                                    
                                                    [blockSelf reload];                                                
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"generic_error_desc", @"error") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                                                        [av show];
                                                    });
                                                }];
                                            }
                 ];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error: %@", [operation responseString]);                
            }];
            [operation start];
    };
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self reload];
    [self uploadFiles];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [self stopTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)reload
{
    [MRCoreDataAction saveDataInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        
    } completion:^{
        self.inProgress = [SWMedia findInProgressObjects];
        self.recent = [SWMedia findRecentObjects];
        [self.tableView reloadData];
    }];
}

- (void)uploadFiles
{
    _nbUploadElements = 0;
    for (SWMedia* m in self.inProgress)
    {
        if (m.uploadProgress == 0.0f)
        {
            [self launchRefreshTimer];
            
            NSInteger imageQuality = [SWUploadQualityViewController imageQuality];
            float imageCompression = 1.0f;
            if (imageQuality == UPLOAD_QUALITY_KEY_MEDIUM)
                imageCompression = 0.7f;
            else if (imageQuality == UPLOAD_QUALITY_KEY_LOW)
                imageCompression = 0.4f;
            
            NSInteger videoQuality = [SWUploadQualityViewController videoQuality];            
            
            //__block SWActivitiesViewController* selfBlock = self;
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{            
                ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:[NSURL URLWithString:m.assetURL]
                               resultBlock:^(ALAsset *asset) {
                                   
                                   if ([m.contentType isEqualToString:@"image/png"])
                                   {
                                       UIImage* img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                                       NSData* imgData = UIImagePNGRepresentation(img);
                                       ++self.nbUploadElements;
                                       self.uploadDataBlock(m, imgData, nil);
                                   }
                                   else if ([m.contentType isEqualToString:@"image/jpg"] || [m.contentType isEqualToString:@"image/jpeg"])
                                   {
                                       UIImage* img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];                                   
                                       NSData* imgData = UIImageJPEGRepresentation(img, imageCompression);
                                       ++self.nbUploadElements;
                                       self.uploadDataBlock(m, imgData, nil);
                                   }
                                   else
                                   {
                                       // Video
                                       AVURLAsset* avAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:m.assetURL] options:nil];
                                       
                                       AVAssetExportSession *exportSession;
                                       if (videoQuality == UPLOAD_QUALITY_KEY_HIGH)
                                           exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
                                       else if (videoQuality == UPLOAD_QUALITY_KEY_MEDIUM)
                                           exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
                                       else if (videoQuality == UPLOAD_QUALITY_KEY_LOW)
                                           exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetLowQuality];
                                       
                                       NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                       NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
                                       NSString* exportPath = [documentsDirectoryPath stringByAppendingPathComponent:m.filename];
                                       [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
                                       
                                       NSURL* exportURL = [NSURL fileURLWithPath:exportPath];
                                       exportSession.outputURL = exportURL;
                                       exportSession.outputFileType = AVFileTypeQuickTimeMovie;
                                       exportSession.shouldOptimizeForNetworkUse = YES;
                                       [exportSession exportAsynchronouslyWithCompletionHandler:^ {
                                           
                                           switch ([exportSession status]) {
                                               case AVAssetExportSessionStatusFailed:
                                               case AVAssetExportSessionStatusCancelled:
                                               case AVAssetExportSessionStatusWaiting:
                                                   break;
                                               case AVAssetExportSessionStatusCompleted:
                                                   if (!m.isCancelled)
                                                   {
                                                       ++self.nbUploadElements;
                                                       self.uploadDataBlock(m, [NSData dataWithContentsOfURL:exportURL], [exportURL absoluteString]);
                                                   }
                                                   break;
                                               default:
                                                   
                                                   break;
                                           }
                                       }];
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:m, @"media", exportSession, @"exportSession", nil];
                                           [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                            target:self
                                                                          selector:@selector(updateExportProgress:)
                                                                          userInfo:dict 
                                                                           repeats:YES];                                           
                                       });
                                   }
                               }
                              failureBlock:^(NSError *error) {
                                  dispatch_async(dispatch_get_main_queue(), ^{                                  
                                       UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"error_no_alassets_access", @"no access ot library") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil];
                                       [av show]; 
                                       return;
                                  });
                              }];
            });
        }        
    }
}

- (void)launchRefreshTimer
{
    if (!_refreshTimer || ![_refreshTimer isValid])
    {
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                         target:self
                                                       selector:@selector(updateRefresh:)
                                                       userInfo:nil 
                                                        repeats:YES];
    }
}

- (void)stopTimer
{
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}

- (void)updateRefresh:(NSTimer*)timer
{
    [self.tableView reloadData];
}

- (IBAction)removeMediaUpload:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    SWActivityTableViewCell* cell = (SWActivityTableViewCell*)[btn superview];
    
    [MRCoreDataAction saveDataWithBlock:^(NSManagedObjectContext *localContext) {
        
        SWMedia* media = [SWMedia MR_findFirstByAttribute:@"serverID" withValue:[NSNumber numberWithInt:cell.media.serverID] inContext:localContext];
        
        if (media.isUploaded)
            media.isHiddenFromActivities = YES;
        else
            media.isCancelled = YES;
    }];
    
    [self reload];
}

- (void)updateExportProgress:(NSTimer*)timer
{
    AVAssetExportSession* exportSession = (AVAssetExportSession*)[[timer userInfo] objectForKey:@"exportSession"];
    SWMedia* media                      = (SWMedia*)[[timer userInfo] objectForKey:@"media"];    
        
    switch (exportSession.status) 
    {
        case AVAssetExportSessionStatusFailed:
        case AVAssetExportSessionStatusCancelled:
        case AVAssetExportSessionStatusCompleted:
            [timer invalidate];
            break;
        case AVAssetExportSessionStatusExporting:
            media.uploadProgress = exportSession.progress / 2.0f;
            break;
        default:
            
            break;
    }            
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [self.inProgress count];
    return [self.recent count];
}

- (UIView*)tableView:(UITableView*)tv viewForHeaderInSection:(NSInteger)section
{
    UILabel* v = [[UILabel alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableview_header"]];
    v.textColor = [UIColor whiteColor];
    v.font = [UIFont boldSystemFontOfSize:14.0];
    
    if (section == 0)
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"activities_in_progress", @"in progress")];
    else
        v.text = [NSString stringWithFormat:@"   %@", NSLocalizedString(@"activities_recent", @"recent")];
    
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78.0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWActivityTableViewCell* cell; 
    if (indexPath.section == 0)    
        cell = [tv dequeueReusableCellWithIdentifier:@"ActivityCellInProgress"];
    else
        cell = [tv dequeueReusableCellWithIdentifier:@"ActivityCellRecent"];
    
    if (!cell)
    {
        if (indexPath.section == 0)
            cell = [[SWActivityTableViewCell alloc] initWithProgressView:YES style:UITableViewCellStyleDefault reuseIdentifier:@"ActivityCellInProgress"];
        else
            cell = [[SWActivityTableViewCell alloc] initWithProgressView:NO style:UITableViewCellStyleDefault reuseIdentifier:@"ActivityCellRecent"];
        cell.opaque = NO;
        [cell.btnClear addTarget:self action:@selector(removeMediaUpload:) forControlEvents:UIControlEventTouchUpInside];
    }

    SWMedia* media;
    if (indexPath.section == 0)
        media = [self.inProgress objectAtIndex:indexPath.row];
    else
        media = [self.recent objectAtIndex:indexPath.row];
    
    cell.media = media;
    cell.progress = media.uploadProgress;
    
    if ([media.album.name length] > 0)
        cell.title.text = [NSString stringWithFormat:NSLocalizedString(@"in_album", @"in album: "), media.album.name];        
    
    if (media.isCancelled)
        cell.subtitle.text = NSLocalizedString(@"cancelled", @"cancelled");
    else if (media.isUploaded)
        cell.subtitle.text = [media uploadedTime];
    else if (media.uploadProgress > 0.0f)
        cell.subtitle.text = NSLocalizedString(@"is_uploading", @"uploading...");
        
    cell.imageView.image = [media thumbnailOrDefaultImage];
    
    return cell;
}
@end
