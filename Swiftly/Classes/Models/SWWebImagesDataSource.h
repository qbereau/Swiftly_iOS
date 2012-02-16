//
//  SWWebImagesDataSource.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"
#import "SWPhotoScrollViewController.h"
#import "SWMedia.h"
#import "SWMedia+Details.h"
#import "SWAPIClient.h"

@interface SWWebImagesDataSource : NSObject <KTPhotoBrowserDataSource>
{
    NSMutableArray*             _allMedias;
    NSArray*                    _filteredMedias;
    
    BOOL                        _isDirty;
}

@property (nonatomic, strong) NSMutableArray*   allMedias;
@property (nonatomic, assign) BOOL              isDirty;

- (void)resetFilter;
- (void)imageFilter;
- (void)videoFilter;

- (SWMedia*)mediaAtIndex:(NSInteger)index;
- (BOOL)isMediaOpenAtIndex:(NSInteger)index;

@end
