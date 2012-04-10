//
//  SWAlbum+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWAlbum+Details.h"

@implementation SWAlbum (Details)

- (NSArray*)participants_arr
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY albums.serverID = %d", self.serverID];    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSManagedObjectContext* moc = [NSManagedObjectContext MR_context];
    NSFetchRequest *request = [SWPerson MR_requestAllWithPredicate:predicate inContext:moc];
    [request setSortDescriptors:sortDescriptors];
    
    return [SWPerson MR_executeFetchRequest:request inContext:moc];    
}

- (NSString*)participants_str
{
    NSMutableString* output = [[NSMutableString alloc] init];
    for (SWPerson* p in [self participants_arr])
    {
        [output appendFormat:@"%@, ", [p name]];
    }
    
    if ([[self participants] count] > 0)
        return [output substringToIndex:[output length] - 2];
    
    return output;
}

- (UIImage*)customThumbnail
{
    if (!self.updated)
    {
        if (!self.thumbnail)
            [UIImage imageNamed:@"photoDefault.png"];
        else
            return self.thumbnail;
    }
    
    UIImage* icon = [UIImage imageNamed:@"new"];
    UIImage* thumb = self.thumbnail;
    
    CGSize size = CGSizeMake(78, 78);
    
    // Reduce contact thumbnail
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [self.thumbnail drawInRect:CGRectMake(0, 0, size.width, size.height)];
    thumb = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();    
    
    
    // Merge two images
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    [thumb drawInRect:CGRectMake(0, 0, thumb.size.width, thumb.size.height)];
    [icon drawInRect:CGRectMake(62, 0, 16, 16) blendMode:kCGBlendModeNormal alpha:1];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (NSArray*)sortedMedias
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"album.serverID = %d AND isSyncedFromServer = YES", self.serverID];    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"serverID" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *request = [SWMedia MR_requestAllWithPredicate:predicate];
    [request setSortDescriptors:sortDescriptors];
    
    return [SWMedia MR_executeFetchRequest:request];
}

- (void)updateWithObject:(id)obj
{    
    NSString* album_name = [obj valueForKey:@"name"];
    if (!album_name || [album_name class] == [NSNull class])
        album_name = nil;
    
    if (album_name)
        self.name = album_name;
    
    self.serverID           = [[obj valueForKey:@"id"] intValue];
    self.canEditPeople      = [[obj valueForKey:@"edit_accounts"] boolValue];
    self.canEditMedias      = [[obj valueForKey:@"edit_medias"] boolValue];
    self.ownerID            = [[obj valueForKey:@"owner_id"] intValue];
    self.isOwner            = [[obj valueForKey:@"owner"] boolValue];    
    self.isQuickShareAlbum  = [[obj valueForKey:@"quickshare_medias"] boolValue];
    self.isMyMediasAlbum    = [[obj valueForKey:@"created_medias"] boolValue];
    
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:[obj valueForKey:@"updated_at"]];    
    self.lastUpdate         = [dateFromString timeIntervalSinceReferenceDate];

    NSString* thumbURL = [obj valueForKey:@"thumbnail_url"];
    if (!thumbURL || [thumbURL class] == [NSNull class])
        self.thumbnailURL = nil;
    else 
        self.thumbnailURL = thumbURL;
}

- (SWAlbum*)deepCopyInContext:(NSManagedObjectContext*)context
{
    SWAlbum* a = [SWAlbum newEntityInContext:context];
    a.name = self.name;
    a.serverID = self.serverID;
    a.canEditPeople = self.canEditPeople;
    a.canEditMedias = self.canEditMedias;
    a.canExportMedias = self.canExportMedias;
    a.isLocked = self.isLocked;
    a.isOwner = self.isOwner;
    a.isQuickShareAlbum = self.isQuickShareAlbum;
    a.isMyMediasAlbum = self.isMyMediasAlbum;
    a.ownerID = self.ownerID;
    a.thumbnail = self.thumbnail;
    a.lastUpdate = self.lastUpdate;
    a.thumbnailURL = self.thumbnailURL;
    
    for (SWMedia* m in self.medias)
    {
        [a addMediasObject:[m MR_inContext:context]];
    }
    
    for (SWPerson* p in self.participants)
    {
        [a addParticipantsObject:[p MR_inContext:context]];
    }    
    
    return a;
}

- (NSDictionary*)toDictionnary
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    if (self.name)
        [dict setObject:self.name forKey:@"name"];
    
    if (self.serverID == 0 || self.isOwner)
    {
        [dict setObject:[NSNumber numberWithBool:self.canEditPeople] forKey:@"edit_accounts"];
        [dict setObject:[NSNumber numberWithBool:self.canEditMedias] forKey:@"edit_medias"];        
    }
    
    [dict setObject:[NSNumber numberWithBool:self.canExportMedias] forKey:@"open_medias"];
    
    return dict;
}

+ (NSArray*)findAllLinkableAlbums:(NSManagedObjectContext*)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(canEditMedias = YES OR isOwner = YES) AND isQuickShareAlbum = NO AND isMyMediasAlbum = NO"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUpdate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *request = [SWAlbum MR_requestAllWithPredicate:predicate inContext:context];
    [request setSortDescriptors:sortDescriptors];
    
    return [SWAlbum MR_executeFetchRequest:request inContext:context];
}

+ (NSArray*)findUnlockedSharedAlbums:(NSManagedObjectContext*)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isQuickShareAlbum = NO AND isMyMediasAlbum = NO AND isLocked = NO"];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUpdate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *request = [SWAlbum MR_requestAllWithPredicate:predicate inContext:context];
    [request setSortDescriptors:sortDescriptors];
    
    return [SWAlbum MR_executeFetchRequest:request inContext:context];
}

+ (NSArray *)findAllSharedAlbums:(NSManagedObjectContext*)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isQuickShareAlbum = NO AND isMyMediasAlbum = NO"];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUpdate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *request = [SWAlbum MR_requestAllWithPredicate:predicate inContext:context];
    [request setSortDescriptors:sortDescriptors];
    
    return [SWAlbum MR_executeFetchRequest:request inContext:context];
}

+ (NSArray *)findAllSpecialAlbums:(NSManagedObjectContext*)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isQuickShareAlbum = YES OR isMyMediasAlbum = YES"];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUpdate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *request = [SWAlbum MR_requestAllWithPredicate:predicate inContext:context];
    [request setSortDescriptors:sortDescriptors];
    
    return [SWAlbum MR_executeFetchRequest:request inContext:context];
}

+ (SWAlbum*)findQuickShareAlbum:(NSManagedObjectContext*)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isQuickShareAlbum = YES"];
    return [[SWAlbum MR_findAllWithPredicate:predicate inContext:context] objectAtIndex:0];
}

+ (SWAlbum*)newEntityInContext:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    SWAlbum* obj = [[SWAlbum alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    return obj;
}

@end

@implementation ImageToDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}


- (id)reverseTransformedValue:(id)value {
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return uiImage;
}

@end