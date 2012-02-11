//
//  SWAlbum.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWAlbum : NSObject
{
    NSNumber*                   _objectID;
    int                         _ownerID;
    BOOL                        _canEditMedias;
    BOOL                        _canEditPeople;
    BOOL                        _canExportMedias;
    BOOL                        _isLocked;
    BOOL                        _isOwner;
    NSString*                   _name;
    NSArray*                    _participants;
    UIImage*                    _thumbnail; // tmp, should be a url(string), coming from server
}


@property (nonatomic, strong) NSNumber*         objectID;
@property (nonatomic, assign) int               ownerID;
@property (nonatomic, assign) BOOL              canEditMedias;
@property (nonatomic, assign) BOOL              canEditPeople;
@property (nonatomic, assign) BOOL              canExportMedias;
@property (nonatomic, assign) BOOL              isLocked;
@property (nonatomic, assign) BOOL              isOwner;
@property (nonatomic, strong) NSString*         name;
@property (nonatomic, strong) NSArray*          participants;
@property (nonatomic, strong) UIImage*          thumbnail;

@end
