//
//  SWImagePickerViewController.h
//  Swiftly
//
//  Created by Quentin Bereau on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerController.h"
#import "SWAlbumPickerViewController.h"
#import "SWAlbumChoiceSelectionViewController.h"

@interface SWImagePickerViewController : ELCImagePickerController <UITabBarControllerDelegate>
{
    SWAlbumPickerViewController*    _albumController;
}

@property (nonatomic, retain) SWAlbumPickerViewController* albumController;

@end
