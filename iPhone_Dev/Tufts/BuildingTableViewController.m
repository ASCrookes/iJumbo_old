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
@property (nonatomic, strong) UIRefreshControl* refreshControl;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    self.view.backgroundColor = [StandardUtils backgroundColor];
    self.tableView.backgroundColor = [StandardUtils backgroundColor];
    self.title = @"Places";
    UIBarButtonItem* mapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(showMap)];
    self.navigationItem.rightBarButtonItem = mapButton;
    if(!self.buildings || [self.buildings count] == 0) {
        // do not have to check if file is there because the app starts with it there
        NSURL* mainURL = [[NSBundle mainBundle] bundleURL];
        NSURL* localURL = [NSURL URLWithString:@"buildings.json" relativeToURL:mainURL];
        NSData* jsonData = [NSData dataWithContentsOfURL:localURL];
        NSError* error;
        self.buildings = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        [self.tableView reloadData];
        [self loadData];
    }
    
    [self.tableView reloadData];
}

- (void)setupPullToRefresh {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)pullToRefresh {
    [self.refreshControl beginRefreshing];
    [self loadData];
}

// adds the tableview and searchbar
- (void)setupView {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.barTintColor = [StandardUtils blueColor];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    int navBarHeight = 64;  // Also includes statusbar
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height - navBarHeight)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self setupPullToRefresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)showMap {
    MapViewController* map = [[MapViewController alloc] init];
    map.delegate = self;
    map.buildings = self.buildings;
    map.tableBuildings = self.buildings;
    [self.navigationController pushViewController:map animated:YES];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//*********************************************************
//*********************************************************
#pragma mark - JSON loading
//*********************************************************
//*********************************************************

- (void)loadData
{
    dispatch_queue_t queue = dispatch_queue_create("Building.Table.Load", NULL);
    dispatch_async(queue, ^{
        NSURL *url = [NSURL URLWithString:@"http://ijumboapp.com/api/json/buildings"];
        
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
            [self.refreshControl endRefreshing];
        });
    });
    dispatch_release(queue);
}

//*********************************************************
//*********************************************************
#pragma mark - Search
//*********************************************************
//*********************************************************

- (NSArray*)searchForBuildingByName:(NSString*)searchTerm {
    NSMutableArray* results = [[NSMutableArray alloc] init];
    NSRange range;
    
    for(NSArray* section in self.buildings) {
        NSMutableArray* resultsInSection = [[NSMutableArray alloc] init];
        for(NSDictionary* building in section) {
            NSString* buildingName = [building objectForKey:@"building_name"];
            if (buildingName != nil && buildingName.length > 0) {
                range = [buildingName rangeOfString:searchTerm options:NSCaseInsensitiveSearch];
                if(range.location != NSNotFound) {
                    [resultsInSection addObject:building];
                }
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
        [self.searchBar performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.4];
    }
}

// This is actually a MapViewDelegate methods so searching the map links back to this view
- (void)searchBuildingsByName:(NSString *)searchText
{
    [self.navigationController popViewControllerAnimated:YES];
    // change the text of the search bar and make it search using that
    [self.searchBar setText:searchText];
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
        cell = [[BuildingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.viewController = self;
        cell.hidden = NO;
    }
    NSDictionary* buildingDict = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell setupCellWithBuilding:buildingDict hasDetailedText:hasDetailedCells];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    if(_mapSelect) {
        [self.delegate selectedBuilding:[[_buildings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    } else {
        BuildingCell* cell = (BuildingCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell infoButtonAction:nil];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    BuildingViewController* bvc = (BuildingViewController*)[StandardUtils viewControllerFromStoryboardWithIdentifier:@"Building View"];
    bvc.allowsMap = YES;
    [bvc setBuilding:[[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    bvc.view.backgroundColor = self.view.backgroundColor;
    [self.navigationController pushViewController:bvc animated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* sectionTitle = [[[[self.dataSource objectAtIndex:section] objectAtIndex:0] objectForKey:@"building_name"] substringToIndex:1];
    if([sectionTitle isEqualToString:@"1"]) {
        sectionTitle = @"123";
    }
    return sectionTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString* headerIdentifier = @"BuildingTableHeaderIdentifier";
    NSInteger headerLabelTag = 10;
    UITableViewHeaderFooterView* header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if (header == nil) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerIdentifier];
        header.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 30);
        header.contentView.backgroundColor = self.tableView.backgroundColor;
        UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 320, 30)];
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:16];
        headerLabel.numberOfLines = 2;
        headerLabel.adjustsFontSizeToFitWidth = YES;
        headerLabel.minimumFontSize = 14;
        headerLabel.tag = headerLabelTag;
        [header addSubview:headerLabel];
    }
    UILabel* label = (UILabel*)[header viewWithTag:headerLabelTag];
    label.textColor = [UIColor whiteColor];
    NSString* sectionTitle = [[[[self.dataSource objectAtIndex:section] objectAtIndex:0] objectForKey:@"building_name"] substringToIndex:1];
    if([sectionTitle isEqualToString:@"1"]) {
        sectionTitle = @"123";
    }
    label.text = sectionTitle;
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
