//
//  BuildingTableViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 5/9/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "BuildingTableViewController.h"
#import "MapViewController.h"


@interface BuildingTableViewController () <MapViewDelegate>

@end


@implementation BuildingTableViewController

@synthesize buildings = _buildings;
@synthesize mapSelect = _mapSelect;
@synthesize searchBar = _searchBar;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize hasDetailedCells;


//*********************************************************
//*********************************************************
#pragma mark - Standard Stuff
//*********************************************************
//*********************************************************


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Places";
    UIBarButtonItem* mapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(showMap)];
    self.navigationItem.rightBarButtonItem = mapButton;
    //[self.searchBar setBackgroundImage:[UIImage imageNamed:@"LowerNavBar.png"]];
}

- (void)showMap
{
    MapViewController* map = [self.storyboard instantiateViewControllerWithIdentifier:@"Map View"];
    map.delegate = self;
    map.buildings = self.buildings;
    map.tableBuildings = self.buildings;
    map.view.backgroundColor = self.view.backgroundColor;
    [map setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    UINavigationController* navcon = [[UINavigationController alloc] initWithRootViewController:map];
    [navcon setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalViewControllerAnimated:)];
    map.navigationItem.leftBarButtonItem = backButton;
    [self presentModalViewController:navcon animated:YES];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//*********************************************************
//*********************************************************
#pragma mark - JSON loading
//*********************************************************
//*********************************************************

- (void)loadData
{
    dispatch_queue_t queue = dispatch_queue_create("Building Table Load", NULL);
    dispatch_async(queue, ^{
        NSURL *url = [NSURL URLWithString:@"http://www.eecs.tufts.edu/~acrook01/files/buildings.json"];
        
        // Set up a concurrent queue
        NSData *data = [NSData dataWithContentsOfURL:url];
        if(data == nil) {
            return;
        }
        NSError* error;
        self.buildings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        self.dataSource = self.buildings;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    dispatch_release(queue);
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
    
    for(NSArray* section in self.buildings)
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
    [self.searchBar resignFirstResponder];
    return results;
}

//*********************************************************
//*********************************************************
#pragma mark - UISearchBar Delegate
//*********************************************************
//*********************************************************

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.dataSource = [self searchForBuildingByName:searchBar.text];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.dataSource = self.buildings;
    [self.tableView reloadData];
}

// this allows them to clear the text and get the full text back
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText isEqualToString:@""]) {
        self.dataSource = self.buildings;
        [self.tableView reloadData];
    }
}

// This is actually a MapViewDelegate methods so searching the map links back to this view
- (void)searchBuildingsByName:(NSString *)searchText
{
    [self dismissModalViewControllerAnimated:YES];
    // change the text of the search bar and make it search using that
    self.searchBar.text = searchText;
    [self searchBarSearchButtonClicked:self.searchBar];
}


//*********************************************************
//*********************************************************
#pragma mark - Table View Delegate/Data Source
//*********************************************************
//*********************************************************

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.dataSource objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Building Cell";
    BuildingCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        if(hasDetailedCells) {
            cell = (BuildingCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        } else {
            cell = (BuildingCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    NSDictionary* buildingDict = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if(hasDetailedCells) {
        [cell setupCellWithBuilding:buildingDict andViewController:self];
        cell.infoButton.hidden = NO;
        cell.mapButton.hidden  = NO;
    } else {
        cell.textLabel.text = [buildingDict objectForKey:@"building_name"];
        cell.infoButton.hidden = YES;
        cell.mapButton.hidden  = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    if(_mapSelect) {
        [self.delegate selectedBuilding:[[_buildings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    } else {
        BuildingViewController* bvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Building View"];
        bvc.view.backgroundColor = self.tableView.backgroundColor;
        bvc.allowsMap = YES;
        [bvc setBuilding:[[_buildings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:bvc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    BuildingViewController* bvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Building View"];
    bvc.allowsMap = YES;
    [bvc setBuilding:[[_buildings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    bvc.view.backgroundColor = self.view.backgroundColor;
    [self.navigationController pushViewController:bvc animated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* sectionTitle = [[[[_buildings objectAtIndex:section] objectAtIndex:0] objectForKey:@"building_name"] substringToIndex:1];
    if([sectionTitle isEqualToString:@"1"]) {
        sectionTitle = @"123";
    }
    return sectionTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 320, 45)];
    label.backgroundColor = self.tableView.backgroundColor;
    NSString* sectionTitle = [[[[_buildings objectAtIndex:section] objectAtIndex:0] objectForKey:@"building_name"] substringToIndex:1];
    if([sectionTitle isEqualToString:@"1"]) {
        sectionTitle = @"123";
    }
    label.text = sectionTitle;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.numberOfLines = 2;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumFontSize = 14;
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    [header addSubview:label];
    
    return header;
}


//*********************************************************
//*********************************************************
#pragma mark - Setters/Getters
//*********************************************************
//*********************************************************

- (NSArray*)dataSource
{
    if(!_dataSource) {
        _dataSource = [NSArray array];
    }
    return _dataSource;
}







@end
