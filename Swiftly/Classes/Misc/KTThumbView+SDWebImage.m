//
//  KTThumbView+SDWebImage.m
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTThumbView+SDWebImage.h"
#import "SDWebImageManager.h"

@implementation KTThumbView (SDWebImage)

- (void)setImageWithMedia:(SWMedia*)media placeholderImage:(UIImage *)placeholder
{
    if (media.localThumbnailURL && [[NSFileManager defaultManager] fileExistsAtPath:media.localThumbnailURL])
    {
        UIImage* img = [UIImage imageWithData:[NSData dataWithContentsOfFile:media.localThumbnailURL]];
        [self setThumbImage:img];
    }
    else
    {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager cancelForDelegate:self];        
        
        if (placeholder) 
        {
            [self setThumbImage:placeholder];
        }        
        
        if (media.resourceURL) 
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:media.thumbnailURL]];
                if (data)
                {
                    UIImage* img = [UIImage imageWithData:data];
                    
                    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
                    NSString* exportPath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_th.data", media.serverID]];                        
                    
                    if ([data writeToFile:exportPath atomically:YES])
                    {
                        media.localThumbnailURL = exportPath;                            
                        [[(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] save:nil];
                    }
                    
                    if (img) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self setThumbImage:img];
                        });
                    }
                }
            });
        }
    }
}

@end
