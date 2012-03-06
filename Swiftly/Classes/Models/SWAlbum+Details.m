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
    NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"predicateContactName" ascending:YES];
    NSArray* arr = [self.participants sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    arr = [arr sortedArrayUsingComparator:^(id a, id b){
        NSString* o1 = [(SWPerson*)a predicateContactName];
        NSString* o2 = [(SWPerson*)b predicateContactName];
        return [o1 compare:o2];
    }];
    return arr;
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

- (NSArray*)sortedMedias
{
    return [[self.medias allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SWMedia* m1 = (SWMedia*)obj1;
        SWMedia* m2 = (SWMedia*)obj2;
        return m1.serverID < m2.serverID;
    }];
}

// Core Data Helpers

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context
{
    return [self respondsToSelector:@selector(entityInManagedObjectContext:)] ?
    [self performSelector:@selector(entityInManagedObjectContext:) withObject:context] :
    [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+ (NSArray *)findAllObjects
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [SWAlbum findAllObjectsInContext:context];
}

+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext*)context
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    return [context executeFetchRequest:request error:nil];
}

+ (void)deleteAllObjects
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:request error:&error];
    
    
    for (NSManagedObject *managedObject in items) 
    {
        [context deleteObject:managedObject];
    }
    
    [context save:&error];
}

+ (SWAlbum*)findObjectWithServerID:(int)serverID
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [SWAlbum findObjectWithServerID:serverID inContext:context];
}

+ (SWAlbum*)findObjectWithServerID:(int)serverID inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID = %d", serverID];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray* items = [context executeFetchRequest:request error:nil];
    if ([items count] == 0)
        return nil;
    return (SWAlbum*)[items objectAtIndex:0];
}

+ (NSArray*)findAllLinkableAlbums
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(canEditMedias == %@ OR isOwner == %@) AND isQuickShareAlbum == %@ AND isMyMediasAlbum == %@", [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];

    NSArray* arr = [[context executeFetchRequest:request error:nil] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* n1 = [(SWAlbum*)obj1 name];
        NSString* n2 = [(SWAlbum*)obj2 name];
        return [n1 compare:n2];        
    }];    
    return arr;
}

+ (NSArray*)findUnlockedSharedAlbums
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isQuickShareAlbum == %@ AND isMyMediasAlbum == %@ AND (isLocked == %@ OR isLocked == nil)", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    NSArray* arr = [[context executeFetchRequest:request error:nil] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* n1 = [(SWAlbum*)obj1 name];
        NSString* n2 = [(SWAlbum*)obj2 name];
        return [n1 compare:n2];        
    }];    
    return arr;
}

+ (NSArray*)findAllSharedAlbums
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isQuickShareAlbum == %@ AND isMyMediasAlbum == %@", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray* arr = [[context executeFetchRequest:request error:nil] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* n1 = [(SWAlbum*)obj1 name];
        NSString* n2 = [(SWAlbum*)obj2 name];
        return [n1 compare:n2];        
    }];
    return arr;
}

+ (NSArray*)findAllSpecialAlbums
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isQuickShareAlbum == %@ OR isMyMediasAlbum == %@", [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray* arr = [[context executeFetchRequest:request error:nil] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* n1 = [(SWAlbum*)obj1 name];
        NSString* n2 = [(SWAlbum*)obj2 name];
        return [n1 compare:n2];        
    }];    
    return arr;
}

+ (SWAlbum*)findQuickShareAlbum
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];    
    return [SWAlbum findQuickShareAlbumInContext:context];
}

+ (SWAlbum*)findQuickShareAlbumInContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isQuickShareAlbum = %@", [NSNumber numberWithBool:YES]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray* items = [context executeFetchRequest:request error:nil];
    if ([items count] == 0)
        return nil;
    return (SWAlbum*)[items objectAtIndex:0];
}

+ (SWAlbum*)createEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [SWAlbum createEntityInContext:context];
}

+ (SWAlbum*)createEntityInContext:(NSManagedObjectContext *)context
{
    SWAlbum* obj = [NSEntityDescription
                    insertNewObjectForEntityForName:NSStringFromClass([self class])
                    inManagedObjectContext:context];
    
    return (SWAlbum*)obj;    
}

+ (SWAlbum*)newEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];    
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    SWAlbum* obj = [[SWAlbum alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    return obj;
}

- (void)deleteEntity
{
    NSManagedObjectContext *context = [(SWAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [self deleteEntityInContext:context];
}

- (void)deleteEntityInContext:(NSManagedObjectContext*)context
{
    [context deleteObject:self];
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
    
    NSString* thumbnail_url = [obj valueForKey:@"thumbnail_url"];
    if (thumbnail_url && [thumbnail_url class] != [NSNull class])
    {
        // Warning sync ... should be handled ansync!
        self.thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnail_url]]];
    }
    else
        self.thumbnail = [UIImage imageNamed:@"photoDefault.png"]; 
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