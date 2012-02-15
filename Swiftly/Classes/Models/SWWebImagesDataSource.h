//
//  SWWebImagesDataSource.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"
#import "SWMedia.h"
#import "SWMedia+Details.h"

@interface SWWebImagesDataSource : NSObject <KTPhotoBrowserDataSource>
{
    NSArray*            _allMedias;
    NSArray*            _filteredMedias;
}

@property (nonatomic, strong) NSArray*  allMedias;


- (void)resetFilter;
- (void)imageFilter;
- (void)videoFilter;

- (BOOL)isMediaOpenAtIndex:(NSInteger)index;

@end
