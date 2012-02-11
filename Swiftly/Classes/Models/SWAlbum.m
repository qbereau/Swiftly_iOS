//
//  SWAlbum.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbum.h"

@implementation SWAlbum

@synthesize objectID        = _objectID;
@synthesize ownerID         = _ownerID;
@synthesize canEditMedias   = _canEditMedias;
@synthesize canEditPeople   = _canEditPeople;
@synthesize canExportMedias = _canExportMedias;
@synthesize name            = _name;
@synthesize isLocked        = _isLocked;
@synthesize isOwner         = _isOwner;
@synthesize participants    = _participants;
@synthesize thumbnail       = _thumbnail;

@end
