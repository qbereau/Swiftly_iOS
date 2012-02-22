//
//  KTPhotoView+SDWebImage.m
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTPhotoView+SDWebImage.h"
#import "SDWebImageManager.h"

@implementation KTPhotoView (SDWebImage)

- (void)setImageWithMedia:(SWMedia*)media placeholderImage:(UIImage *)placeholder
{
    if (media.localResourceURL && [[NSFileManager defaultManager] fileExistsAtPath:media.localResourceURL])
    {
        UIImage* img = [UIImage imageWithData:[NSData dataWithContentsOfFile:media.localResourceURL]];
        [self setImage:img];
    }
    else
    {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager cancelForDelegate:self];        
        
        if (placeholder) 
        {
            [self setImage:placeholder];
        }        
        
        if (media.resourceURL) 
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:media.resourceURL]];
                if (data)
                {
                    UIImage* img = [UIImage imageWithData:data];
                    
                    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
                    NSString* exportPath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.data", media.serverID]];                        
                    
                    if ([data writeToFile:exportPath atomically:YES])
                    {
                        media.localResourceURL = exportPath;
                        [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
                    }
                    
                    if (img) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self setImage:img];
                        });
                    }
                }
            });
        }
    }
}

@end