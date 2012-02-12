//
//  AssetTablePicker.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"


@implementation ELCAssetTablePicker

@synthesize parent;
@synthesize selectedAssetsLabel;
@synthesize assetGroup, elcAssets;

-(void)viewDidLoad {
        
    shouldSelectAll = YES;
    
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]]];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    [tempArray release];
	
	UIBarButtonItem *doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
	[self.navigationItem setTitle:NSLocalizedString(@"loading", @"loading")];

	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    
    // Show partial while full list loads
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:.5];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(50,0,0,0)];
    
    btnSelectAll = [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width / 2 - self.tableView.frame.size.width / 6, -40, self.tableView.frame.size.width / 3, 30)];
    [btnSelectAll setBackgroundImage:[[UIImage imageNamed:@"rounded_button"] stretchableImageWithLeftCapWidth:9 topCapHeight:9] forState:UIControlStateNormal];
    btnSelectAll.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [btnSelectAll setTitle:NSLocalizedString(@"select_all", @"select all") forState:UIControlStateNormal];
    [btnSelectAll addTarget:self action:@selector(selectAllFiles:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:btnSelectAll];
}

- (void)selectAllFiles:(id)sender
{
	for(ELCAsset *elcAsset in self.elcAssets) 
    {		
        [elcAsset setSelected:shouldSelectAll];
	}
    
    shouldSelectAll = !shouldSelectAll;
    if (shouldSelectAll)
        [btnSelectAll setTitle:NSLocalizedString(@"select_all", @"select all") forState:UIControlStateNormal];
    else
        [btnSelectAll setTitle:NSLocalizedString(@"deselect_all", @"deselect all") forState:UIControlStateNormal];        
}

-(void)preparePhotos {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	
    [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) 
     {         
         if(result == nil) 
         {
             return;
         }
         
         ELCAsset *elcAsset = [[[ELCAsset alloc] initWithAsset:result] autorelease];
         [elcAsset setParent:self];
         [self.elcAssets addObject:elcAsset];
     }];    
	
	[self.tableView reloadData];
	[self.navigationItem setTitle:NSLocalizedString(@"pick_files", @"pick files")];
    
    [pool release];

}

- (void) doneAction:(id)sender {
	
	NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
	    
	for(ELCAsset *elcAsset in self.elcAssets) 
    {		
		if([elcAsset selected]) {
			
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
        
    [(ELCAlbumPickerController*)self.parent selectedAssets:selectedAssetsImages];
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceil([self.assetGroup numberOfAssets] / 4.0);
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    
	int index = (_indexPath.row*4);
	int maxIndex = (_indexPath.row*4+3);
    
	// NSLog(@"Getting assets for %d to %d with array count %d", index, maxIndex, [assets count]);
    
	if(maxIndex < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				[self.elcAssets objectAtIndex:index+3],
				nil];
	}
    
	else if(maxIndex-1 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				nil];
	}
    
	else if(maxIndex-2 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				nil];
	}
    
	else if(maxIndex-3 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObject:[self.elcAssets objectAtIndex:index]];
	}
    
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {		        
        cell = [[[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier] autorelease];
    }	
	else 
    {		
		[cell setAssets:[self assetsForIndexPath:indexPath]];
	}

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 79;
}

- (int)totalSelectedAssets {
    
    int count = 0;
    
    for(ELCAsset *asset in self.elcAssets) 
    {
		if([asset selected]) 
        {            
            count++;	
		}
	}
    
    return count;
}

- (void)dealloc 
{
    [elcAssets release];
    [selectedAssetsLabel release];
    [btnSelectAll release];
    [super dealloc];    
}

@end
