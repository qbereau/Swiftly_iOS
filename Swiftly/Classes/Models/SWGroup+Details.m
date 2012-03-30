//
//  SWGroup+Details.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWGroup+Details.h"
#import "SWPeopleListViewController.h"

@implementation SWGroup (Details)

- (NSString*)contacts_str
{
    NSMutableString* output = [[NSMutableString alloc] init];
    for (SWPerson* p in [self contacts_arr])
    {
        [output appendFormat:@"%@, ", [p name]];
    }
    
    if ([self.contacts count] > 0)
        return [output substringToIndex:[output length] - 2];
    
    return output;
}

- (NSArray*)contacts_arr
{
    NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"predicateContactName" ascending:YES];
    NSArray* arr = [self.contacts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    arr = [arr sortedArrayUsingComparator:^(id a, id b){
        NSString* o1 = [(SWPerson*)a predicateContactName];
        NSString* o2 = [(SWPerson*)b predicateContactName];
        return [o1 compare:o2];
    }];
    return arr;    
}

- (void)updateWithObject:(id)obj inContext:(NSManagedObjectContext*)context
{    
    NSString* g_name = [obj valueForKey:@"name"];
    if (!g_name || [g_name class] == [NSNull class])
        g_name = nil;
    
    if (g_name)
        self.name = g_name;
    
    self.serverID = [[obj valueForKey:@"id"] intValue];
    
    [self setContacts:nil];
    
    for (NSNumber* account_id in [obj valueForKey:@"account_ids"])
    {
        SWPerson* p = [SWPerson MR_findFirstByAttribute:@"serverID" withValue:account_id inContext:context];
        if (!p)
        {
            p = [SWPerson MR_createEntity];
            p.serverID = [account_id intValue];
        }
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"serverID = %d", p.serverID];
        NSSet* set = [self.contacts filteredSetUsingPredicate:predicate];
        if ([set count] == 0)
            [self addContactsObject:p];
    }
}

+ (SWGroup*)newEntityInContext:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    SWGroup* obj = [[SWGroup alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    return obj;
}

@end
