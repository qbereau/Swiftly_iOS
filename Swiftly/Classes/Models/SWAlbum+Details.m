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
    NSArray* p_arr = [self participants_arr];
    if ([p_arr count] > 1)
    {
        NSMutableString* output = [[NSMutableString alloc] init];        
        for (SWPerson* p in p_arr)
        {
            [output appendFormat:@"%@, ", [p name]];
        }
        
        return [output substringToIndex:[output length] - 2];        
    }
    
    return NSLocalizedString(@"me", @"me");
}

- (UIImage*)customThumbnail
{
    if (!self.updated)
    {
        if (!self.thumbnail)
            return [UIImage imageNamed:@"photoDefault.png"];
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
    
    // --
    id aData = [obj objectForKey:@"adata"];
    if (aData && [aData class] != [NSNull class])
    {
        self.canEditPeople      = [aData objectForKey:@"canEditPeople"] ? [[aData objectForKey:@"canEditPeople"] boolValue] : NO;
        self.canAddMedias       = [aData objectForKey:@"canAddMedias"] ? [[aData objectForKey:@"canAddMedias"] boolValue] : NO;
        self.canExportMedias    = [aData objectForKey:@"canExportMedias"] ? [[aData objectForKey:@"canExportMedias"] boolValue] : NO;
    }
    // --
    
    self.ownerID            = [[obj valueForKey:@"creator_id"] intValue];
    self.isOwner            = [[obj valueForKey:@"owner"] boolValue];    
    
    
    // Is QuickShare Album ?
    self.isQuickShareAlbum = NO;
    
    if ([[obj objectForKey:@"tags"] isKindOfClass:[NSArray class]])
    {
        NSArray* tags = [obj objectForKey:@"tags"];
        for (NSString* s in tags)
        {
            if ([s isEqualToString:@"quickshare"])
            {
                self.isQuickShareAlbum = YES;
                break;
            }
        }
    }
    else if ([[obj objectForKey:@"tags"] isKindOfClass:[NSString class]])
    {
        NSString* tag = [obj objectForKey:@"tags"];
        if ([tag isEqualToString:@"quickshare"])
        {
            self.isQuickShareAlbum = YES;
        }
    }
    // ----
    
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:[obj valueForKey:@"updated_at"]];    
    self.lastUpdate         = [dateFromString timeIntervalSinceReferenceDate];

    if (!self.isQuickShareAlbum)
    {
        NSString* thumbURL = [obj valueForKey:@"thumbnail_url"];
        if (!thumbURL || [thumbURL class] == [NSNull class])
            self.thumbnailURL = nil;
        else
        {
            self.updated = NO;
            if (![[[self.thumbnailURL componentsSeparatedByString:@"?"] objectAtIndex:0] isEqualToString:[[thumbURL componentsSeparatedByString:@"?"] objectAtIndex:0]] || ( [self.thumbnailURL length] == 0 && [thumbURL length] > 0) )
                self.updated = YES;
            
            self.thumbnailURL = thumbURL;
        }
    }
}

- (SWAlbum*)deepCopyInContext:(NSManagedObjectContext*)context
{
    SWAlbum* a = [SWAlbum newEntityInContext:context];
    a.name = self.name;
    a.serverID = self.serverID;
    a.canEditPeople = self.canEditPeople;
    a.canAddMedias = self.canAddMedias;
    a.canExportMedias = self.canExportMedias;
    a.isLocked = self.isLocked;
    a.isOwner = self.isOwner;
    a.isQuickShareAlbum = self.isQuickShareAlbum;
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
    
    if ([self.participants count] > 0)
    {
        NSMutableArray* contacts_arr = [NSMutableArray array];
        for (SWPerson* p in self.participants)
        {
            if (!p.isSelf)
                [contacts_arr addObject:[NSNumber numberWithInt:p.serverID]];
        }
        
        if ([contacts_arr count] > 0)
        {
            NSDictionary* right = [NSDictionary dictionaryWithObjectsAndKeys:contacts_arr, @"user_ids", 
                                                                             [NSNumber numberWithBool:YES], @"read", 
                                                                             [NSNumber numberWithBool:self.canAddMedias], @"write", 
                                                                             [NSNumber numberWithBool:self.canEditPeople], @"grant",
                                                                             [NSNumber numberWithBool:YES], @"recursive", 
                                    nil];
            [dict setObject:[NSArray arrayWithObject:right] forKey:@"rights"];
        }
    }

    if (!self.serverID || self.serverID == 0)
    {
        [dict setObject:[NSNumber numberWithInt:[SWAppDelegate serviceID]] forKey:@"parent_id"];
        [dict setObject:@"folder" forKey:@"type"];
    }
    
    NSDictionary* aData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:self.canEditPeople], @"canEditPeople",
                                                                     [NSNumber numberWithBool:self.canAddMedias], @"canAddMedias",
                                                                     [NSNumber numberWithBool:self.canExportMedias], @"canExportMedias",
                           nil];
    [dict setObject:aData forKey:@"adata"];
    
    return dict;
}

+ (NSArray*)findAllLinkableAlbums:(NSManagedObjectContext*)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(canAddMedias = YES OR isOwner = YES) AND isQuickShareAlbum = NO"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUpdate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *request = [SWAlbum MR_requestAllWithPredicate:predicate inContext:context];
    [request setSortDescriptors:sortDescriptors];
    
    return [SWAlbum MR_executeFetchRequest:request inContext:context];
}

+ (NSArray*)findUnlockedSharedAlbums:(NSManagedObjectContext*)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isLocked = NO OR isQuickShareAlbum = YES"];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUpdate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *request = [SWAlbum MR_requestAllWithPredicate:predicate inContext:context];
    [request setSortDescriptors:sortDescriptors];
    
    return [SWAlbum MR_executeFetchRequest:request inContext:context];
}

+ (SWAlbum*)findQuickShareAlbum:(NSManagedObjectContext*)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isQuickShareAlbum = YES"];
    NSArray* rez = [SWAlbum MR_findAllWithPredicate:predicate inContext:context];
    if ([rez count] > 0)
        return [rez objectAtIndex:0];
    return nil;
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