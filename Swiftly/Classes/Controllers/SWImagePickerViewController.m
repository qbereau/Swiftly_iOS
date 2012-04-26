//
//  SWImagePickerViewController.m
//  Swiftly
//
//  Created by Quentin Bereau on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SWImagePickerViewController.h"

@implementation SWImagePickerViewController

@synthesize albumController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;
    
    self.navigationBarHidden = NO;
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]];     
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.albumController)
    {
        self.albumController = [[SWAlbumPickerViewController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
        self.albumController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linen"]]; 
        self.viewControllers = [NSArray arrayWithObject:self.albumController];
        
        [self.albumController setParent:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)selectedAssets:(NSArray*)_assets 
{    
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	for(ALAsset *asset in _assets) 
    {
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		[workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
        //[workingDictionary setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"]; // Bottleneck!!
        [workingDictionary setObject:[UIImage imageWithCGImage:[asset thumbnail]] forKey:@"UIImagePickerControllerThumbnail"];        
		[workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
		
		[returnArray addObject:workingDictionary];
	}
    

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    SWAlbumChoiceSelectionViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"AlbumChoiceSelectionViewController"];
    vc.filesToUpload = returnArray;
    [self pushViewController:vc animated:YES];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSUInteger indexOfTab = [tabBarController.viewControllers indexOfObject:viewController];
    UITabBarItem *item = [tabBarController.tabBar.items objectAtIndex:indexOfTab];
    
    if (item.tag != 2) // Share
    {
        self.albumController = nil;
    }
}

@end
