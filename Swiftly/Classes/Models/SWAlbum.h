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
    int             _objectID;
    int             _ownerID;
    BOOL            _canEditMedias;
    BOOL            _canEditPeople;
    NSString*       _name;
    
    UIImage*        _thumbnail; // tmp, should be a url(string), coming from server
}


@property (nonatomic, assign) int               objectID;
@property (nonatomic, assign) int               ownerID;
@property (nonatomic, assign) BOOL              canEditMedias;
@property (nonatomic, assign) BOOL              canEditPeople;
@property (nonatomic, strong) NSString*         name;

@property (nonatomic, strong) UIImage*          thumbnail;

@end
