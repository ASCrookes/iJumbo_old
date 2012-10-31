//
//  MapViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 5/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController () <MKMapViewDelegate>

@end

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize searchBar = _searchBar;
@synthesize buildings = _buildings;
@synthesize annotations = _annotations;
@synthesize tableBuildings = _tableBuildings;
@synthesize allowAnnotationClick = _allowAnnotationClick;
@synthesize isLoading = _isLoading;

//*********************************************************
//*********************************************************
#pragma mark - Standard Stuff
//*********************************************************
//*********************************************************

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    [self.mapView setDelegate:self];

}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//*********************************************************
//*********************************************************
#pragma mark - View Setup
//*********************************************************
//*********************************************************

// Sets the map so it shows the entire Tufts campus
- (void)setupView
{
    CLLocationDegrees lat;
    lat = 42.406056;
    CLLocationDegrees lng;
    lng = -71.120923;
    CLLocationCoordinate2D center;
    center.latitude = lat;
    center.longitude = lng;
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.007;
    span.longitudeDelta = 0.007;
    MKCoordinateRegion region;
    region.center = center;
    region.span = span;
    [self.mapView setRegion:region animated:NO];
}

// Puts away the keyboard for the search bar
- (void)resignSearchKeyboard
{
    [self.searchBar resignFirstResponder];
}

// Adds the browse bar button to the right item in navigation item
- (void)addBarButton
{
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithTitle:@"Places" style:UIBarButtonItemStylePlain target:self action:@selector(showTableWithAllBuildings)];
    self.navigationItem.rightBarButtonItem = barButton;
}

//*********************************************************
//*********************************************************
#pragma mark - JSON loading
//*********************************************************
//*********************************************************

// Loads the building json

- (void)loadData
{

    // Set up a concurrent queue
    dispatch_queue_t queue = dispatch_queue_create("Map Load Data", nil);
    dispatch_async(queue, ^{
        
        self.isLoading = YES;
        NSURL *url = [NSURL URLWithString:@"http://www.eecs.tufts.edu/~acrook01/files/buildings.json"];
        // Load the local file and then load from the server
        // This way the map will still have data to funciton with if there is no internet and if anything on the file changes it gets the new one
        NSURL* mainURL = [[NSBundle mainBundle] bundleURL];
        NSURL* localURL = [NSURL URLWithString:@"buildings.json" relativeToURL:mainURL];
        NSData* jsonData = [NSData dataWithContentsOfURL:localURL];
        NSError* error;
        self.tableBuildings = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [self performSelectorOnMainThread:@selector(parseData:)
                               withObject:data
                            waitUntilDone:YES];
    });
    dispatch_release(queue);
}

// Parse the data from the given json data
- (void)parseData:(NSData *)responseData
{
    if(responseData == nil) {
        self.isLoading = NO;
        return;
    }
    
    NSError* error;
    
    self.tableBuildings = [NSJSONSerialization JSONObjectWithData:responseData
                                                      options:0
                                                        error:&error];
    // After getting the data save it locally 
    NSURL* mainURL = [[NSBundle mainBundle] bundleURL];
    NSURL* localURL = [NSURL URLWithString:@"buildings.json" relativeToURL:mainURL];
    [responseData writeToURL:localURL atomically:YES];
    [self createMapsBuildingsFromAllBuildings];
    self.isLoading = NO;
}

// Read method name
- (void)createMapsBuildingsFromAllBuildings
{
    NSMutableArray* temp = [[NSMutableArray alloc] init];
    for (NSArray* list in self.tableBuildings)
    {
        for (id building in list)
        {
            [temp addObject:building];
        }
    }
    self.buildings = (NSArray*)temp;
}


//*********************************************************
//*********************************************************
#pragma mark - Map
//*********************************************************
//*********************************************************

// The table view delegate method giving the selected building
- (void)selectedBuilding:(id)buildingJSON
{
    [self showBuilding:buildingJSON];
}

// Remove all annotations and add the new one
- (void)showBuilding:(id)buildingJSON
{   
    [self dismissModalViewControllerAnimated:YES];
    if(!buildingJSON) {
        return;
    }
    NSLog(@"animate!");
    BuildingAnnotation* pin = [BuildingAnnotation buildingWithJson:buildingJSON];
    MKCoordinateRegion resetRegion = self.mapView.region;
    resetRegion.span.longitudeDelta = 0.007;
    resetRegion.span.latitudeDelta = 0.007;
    self.mapView.region = resetRegion;
    [UIView animateWithDuration:0.8 animations:^{
        [self.mapView removeAnnotations:self.mapView.annotations];
        MKCoordinateSpan span;
        span.latitudeDelta = 0.007;
        span.longitudeDelta = 0.007;
        MKCoordinateRegion region;
        region.center.latitude  = [(NSString*)[buildingJSON objectForKey:@"latitude"] doubleValue];
        region.center.longitude = [(NSString*)[buildingJSON objectForKey:@"longitude"] doubleValue];
        region.span = span;
        [self.mapView setRegion:region animated:YES];
    } completion:^(BOOL finished) {
        [self.mapView addAnnotation:pin];
        [self.mapView setSelectedAnnotations:[NSArray arrayWithObject:pin]];
    }];
}
               
                    
//*********************************************************
//*********************************************************
#pragma mark - Annotations
//*********************************************************
//*********************************************************


- (void)showTableWithBuildings:(NSArray*)buildings
{    
    BuildingTableViewController* btvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Building Table"];
    btvc.view.backgroundColor = self.view.backgroundColor;
    btvc.buildings = buildings;
    btvc.navigationController.navigationBarHidden = NO;
    btvc.mapSelect = YES;
    btvc.hasDetailedCells = NO; 
    btvc.delegate = self;
    self.buildings = buildings;
    //[btvc loadView];
    //[btvc.tableView reloadData];
    
    
    UINavigationController* navcon = [[UINavigationController alloc] initWithRootViewController:btvc];
    navcon.navigationBar.tintColor = [UIColor blackColor];
    navcon.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [navcon.navigationBar setTintColor:[UIColor colorWithRed:72.0/255 green:145.0/255 blue:206.0/255 alpha:1]];
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalViewControllerAnimated:)];
    btvc.navigationItem.leftBarButtonItem = barButton;
    UIBarButtonItem* onMap = [[UIBarButtonItem alloc] initWithTitle:@"View On Map" style:UIBarButtonItemStylePlain target:self action:@selector(viewSearchResultsOnMap)];
    btvc.navigationItem.rightBarButtonItem = onMap;
    [self resignSearchKeyboard];
    [self presentModalViewController:navcon animated:YES];
}

- (void)showTableWithAllBuildings
{
    [self showTableWithBuildings:self.tableBuildings];
}

- (void)viewSearchResultsOnMap
{
    NSMutableArray* pins = [[NSMutableArray alloc] init];
    for(NSArray* section in self.buildings)
    {
        for(NSDictionary* building in section)
        {
            [pins addObject:[BuildingAnnotation buildingWithJson:building]];
        }
        
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.annotations = (NSArray*)pins;
    [self.mapView addAnnotations:self.annotations];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)pushBuilding
{
    BuildingViewController* bvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Building View"];
    [bvc setBuilding:[(BuildingAnnotation*)[_mapView.selectedAnnotations objectAtIndex:0] building]];
    bvc.allowsMap = YES;
    bvc.view.backgroundColor = self.view.backgroundColor;
    [self.navigationController pushViewController:bvc animated:YES];
}


//*********************************************************
//*********************************************************
#pragma mark - Map View Delegate
//*********************************************************
//*********************************************************


- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView* aView = [_mapView dequeueReusableAnnotationViewWithIdentifier:@"Map Annotation"];
    if(!aView)
    {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Map Annotation"];
        aView.canShowCallout = YES;
        aView.rightCalloutAccessoryView = [[UIButton alloc] init];
    }

    aView.annotation = annotation;
    
    if(_allowAnnotationClick) {
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [(UIButton*)aView.rightCalloutAccessoryView addTarget:self action:@selector(pushBuilding) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return aView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
    for (MKAnnotationView *annView in annotationViews)
    {
        CGRect endFrame = annView.frame;
        annView.frame = CGRectOffset(endFrame, 0, -500);
        [UIView animateWithDuration:0.5 
                         animations:^{ annView.frame = endFrame; }];
    }
}


//*********************************************************
//*********************************************************
#pragma mark - Search
//*********************************************************
//*********************************************************


- (NSArray*)searchForBuildingByName:(NSString*)searchTerm
{
    NSMutableArray* results = [[NSMutableArray alloc] init];
    NSRange range;
    
    for(NSArray* section in self.tableBuildings)
    {
        NSMutableArray* resultsInSection = [[NSMutableArray alloc] init];
        for(NSDictionary* building in section) 
        {
            range = [[building objectForKey:@"building_name"] rangeOfString:searchTerm options:NSCaseInsensitiveSearch];
            if(range.location != NSNotFound) {
                [resultsInSection addObject:building];
            }
        }
        if([resultsInSection count] > 0) {
            [results addObject:resultsInSection];
        }
    }
    [self resignSearchKeyboard];
    return results;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.delegate searchBuildingsByName:searchBar.text]; 
}



@end
