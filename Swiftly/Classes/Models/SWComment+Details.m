//
//  SWComment+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWComment+Details.h"

@implementation SWComment (Details)

- (void)updateWithObject:(id)obj inContext:(NSManagedObjectContext *)context
{    
    NSString* content = [obj valueForKey:@"content"];
    if (!content || [content class] == [NSNull class])
        content = nil;
    
    if (content)
        self.content = content;
    
    self.serverID = [[obj valueForKey:@"id"] intValue];
    
    NSString* creation = [obj valueForKey:@"created_at"];
    if (!creation || [creation class] == [NSNull class])
        creation = nil;
    
    if (creation)
    {
        self.createdDT = [[creation stringByReplacingOccurrencesOfString:@"T" withString:@" "] stringByReplacingOccurrencesOfString:@"Z" withString:@" "];
    }
    
    SWPerson* p = [SWPerson MR_findFirstByAttribute:@"serverID" withValue:[obj valueForKey:@"author_id"] inContext:context];
    self.author = p;
}

+ (NSArray*)findLatestCommentsForMediaID:(int)mediaID inContext:(NSManagedObjectContext*)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"media.serverID == %d", mediaID];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"serverID" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *request = [SWComment MR_requestAllWithPredicate:predicate inContext:context];
    [request setSortDescriptors:sortDescriptors];    
    return [SWComment MR_executeFetchRequest:request inContext:context];
}

@end
