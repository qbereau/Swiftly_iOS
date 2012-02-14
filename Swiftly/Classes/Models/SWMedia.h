//
//  SWMedia.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWAlbum;

@interface SWMedia : NSManagedObject

@property (nonatomic) int32_t serverID;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSString * policy;
@property (nonatomic, retain) NSString * acl;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * awsAccessKeyID;
@property (nonatomic) int32_t uploadProgress;
@property (nonatomic, retain) SWAlbum *album;

@end
