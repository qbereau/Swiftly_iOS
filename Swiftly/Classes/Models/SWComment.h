//
//  SWComment.h
//  Swiftly
//
//  Created by Quentin Bereau on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWMedia, SWPerson;

@interface SWComment : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * createdDT;
@property (nonatomic) int32_t serverID;
@property (nonatomic, retain) SWPerson *author;
@property (nonatomic, retain) SWMedia *media;

@end
