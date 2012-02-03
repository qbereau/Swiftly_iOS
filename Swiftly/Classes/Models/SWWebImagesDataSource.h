//
//  SWWebImagesDataSource.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"

@interface SWWebImagesDataSource : NSObject <KTPhotoBrowserDataSource>
{
    NSArray*            _images;
}

@property (nonatomic, strong) NSArray*  images;

@end
