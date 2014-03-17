//
//  MenuTableViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 4/17/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "MenuTableViewController.h"
#import "AppDelegate.h"

const int SECTION_HEIGHT = 45;
const int HEIGHT_OF_HELPER_VIEWS_IN_MEALS = 186;
const int TODAY_INDEX = 0;
const int TOMORROW_INDEX = 1;

@implementation MenuTableViewController

@synthesize dataSource = _dataSource;
@synthesize masterDict = _masterDict;
@synthesize isLoading = _isLoading;
@synthesize lastUpdate = _lastUpdate;
@synthesize loadingView = _loadingView;
@synthesize noFood = _noFood;
@synthesize extraBar = _extraBar;
@synthesize diningHallInfo = _diningHallInfo;
@synthesize foodSet = _foodSet;

//*********************************************************
//*********************************************************
#pragma mark - Standard Stuff
//*********************************************************
//*********************************************************

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBarInfo];
    [self setupView];
    if(!self.isLoading) {
        [self.tableView reloadData];
    }
    // If the datasource(masterDict, has not been set yet, if it is an empty array, or if the "no food" view is visible -> load data again
    if(!self.masterDict || [self.masterDict count] == 0) {// || !self.noFood.hidden) {
        [self loadData];
    }
    [self loadDataBasedOnDate];
}

- (void)setupView {
    self.extraBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.extraBar.barTintColor = [StandardUtils blueColor];
    UINavigationItem* navItem = [[UINavigationItem alloc] init];
    self.todayBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(dateButtonAction:)];
    self.todayBarButton.tintColor = [UIColor lightGrayColor];
    self.tomorrowBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Tomorrow" style:UIBarButtonItemStylePlain target:self action:@selector(dateButtonAction:)];
    navItem.leftBarButtonItem = self.todayBarButton;
    navItem.rightBarButtonItem = self.tomorrowBarButton;
    
    [self.extraBar pushNavigationItem:navItem animated:NO];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.extraBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.extraBar.frame.size.height - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.extraBar];
    [self.view addSubview:self.tableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidAppear:(BOOL)animated
{
    if(!self.masterDict || [self.masterDict count] == 0) {// || !self.noFood.hidden) {
        [self loadData];
        return;
    }
    [self loadDataBasedOnDate];
}

- (void)addBarInfo
{
    UIBarButtonItem* halls = [[UIBarButtonItem alloc] initWithTitle:@"Dewick" style:UIBarButtonItemStylePlain target:self action:@selector(changeHall)];
    self.navigationItem.rightBarButtonItem = halls;
    [self.todayBarButton setTintColor:[UIColor blackColor]];
    UISegmentedControl* segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Break",@"Lunch",@"Dinner",nil]];
    segment.selectedSegmentIndex = 0;
    [segment addTarget:self action:@selector(setDataSourceFromMaster) forControlEvents:UIControlEventValueChanged];
    [segment setSegmentedControlStyle:UISegmentedControlStyleBar];
    segment.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segment;
    
    [self.extraBar setBackgroundImage:[UIImage imageNamed:@"LowerNavBar.png"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidUnload
{
    [self setExtraBar:nil];
    [self setTableView:nil];
    [self setTodayBarButton:nil];
    [self setTomorrowBarButton:nil];
    [self setMyFoodButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//*********************************************************
//*********************************************************
#pragma mark - Segments, Action Sheets, & bar buttons
//*********************************************************
//*********************************************************

- (void)dateButtonAction:(UIBarButtonItem*)sender
{
    if([sender.title isEqualToString:@"Tomorrow"]) {
        [self.tomorrowBarButton setTintColor:[UIColor lightGrayColor]];
        [self.todayBarButton setTintColor:[UIColor whiteColor]];
    } else {
        [self.tomorrowBarButton setTintColor:[UIColor whiteColor]];
        [self.todayBarButton setTintColor:[UIColor lightGrayColor]];
    }
    [self setDataSourceFromMaster];
}

- (void)changeHall
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Select Dining Hall"
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"Dewick", @"Hodgdon", @"Carmichael", @"Refresh", nil];
    
    // Show the sheet
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* diningHall = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([self.navigationItem.rightBarButtonItem.title isEqualToString:diningHall] || 
       [[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]    ) {
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Refresh"]) {
        self.masterDict = nil;
        self.dataSource = nil;
        [self loadData];
    } else {
        self.navigationItem.rightBarButtonItem.title = diningHall;
        [self setDataSourceFromMaster];
    }
}

- (void)setDataSourceFromMaster
{
    if(!self.masterDict || !self.tomorrowsDict) {
        [self loadData];
    }
    int segIndex = ((UISegmentedControl*)self.navigationItem.titleView).selectedSegmentIndex;
    int dayIndex = ([[self.todayBarButton tintColor] isEqual:[UIColor lightGrayColor]]) ? TODAY_INDEX : TOMORROW_INDEX;
    NSString* mealKey = (segIndex == 0) ? @"Breakfast" : (segIndex == 1) ? @"Lunch" : @"Dinner";
    NSString* hallName = self.navigationItem.rightBarButtonItem.title;
    if(!hallName) {
        hallName = @"Dewick";
    }
    NSDictionary* hall;
    if(dayIndex == TODAY_INDEX) {
        hall = [self.masterDict objectForKey:hallName];
    } else if(dayIndex == TOMORROW_INDEX) {
        hall = [self.tomorrowsDict objectForKey:hallName];
    }
    if([hallName isEqualToString:@"Hodgdon"]) {
        self.dataSource = [[hall objectForKey:@"Breakfast"] objectForKey:@"sections"];
    } else if([hall containsKey:mealKey]) {
        self.dataSource = [[hall objectForKey:mealKey] objectForKey:@"sections"];
    }
    [self.tableView reloadData];
}

//*********************************************************
//*********************************************************
#pragma mark - JSON loading
//*********************************************************
//*********************************************************

- (void)loadData
{
    if(self.isLoading) {
        return;
    }
    self.isLoading = YES;
    self.loadingView.hidden = NO;
    //self.noFood.hidden = YES;
    self.dataSource = [NSArray array];
    [self.tableView reloadData];
    // Load data in a background queue
    dispatch_queue_t queue = dispatch_queue_create("Menu.Table.Load", nil);
    dispatch_async(queue, ^{
        [self parseData];
        [self loadFoodSet];
    });
    dispatch_release(queue);
}

- (void)parseData
{
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ijumboapp.com/api/json/meals"]];
    NSData* tomorrowsData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ijumboapp.com/api/json/tomorrowsMeals"]];
    if(data == nil || tomorrowsData == nil) {
        AppDelegate* del = [[UIApplication sharedApplication] delegate];
        [del pingServer];
        self.loadingView.hidden = YES;
        return;
    }
    NSError* error;
    
    self.masterDict = [NSJSONSerialization JSONObjectWithData:data
                                                      options:0
                                                        error:&error];
    self.tomorrowsDict = [NSJSONSerialization JSONObjectWithData:tomorrowsData
                                                         options:0
                                                           error:&error];

    [self setDataSourceFromMaster];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isLoading = NO;
        [self.tableView reloadData];
        self.lastUpdate = [NSDate date];
        self.loadingView.hidden = YES;
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd"];
        NSString* mealsDate = [NSString stringWithFormat:@"Today(%@)", [dateFormat stringFromDate:self.lastUpdate]];
        [self.todayBarButton setTitle:mealsDate];
    });

}

// If more UI added for when the data is loading hide it here 
- (void)stopLoadingUI
{
    self.isLoading = NO;
    self.loadingView.hidden = YES;
}

//*********************************************************
//*********************************************************
#pragma mark - Table View Delegate/Data Source
//*********************************************************
//*********************************************************

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //self.noFood.hidden = !([self.dataSource count] == 0 && !self.isLoading);
    return [self.dataSource count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 1;
    }
    return [[[self.dataSource objectAtIndex:section - 1] objectForKey:@"foods"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Menu Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString* cellText;
    UIColor* textColor = [UIColor blackColor];
    
    if(indexPath.section == 0) {
        cellText = [self.navigationItem.rightBarButtonItem.title stringByAppendingString:@" Info"];
    } else {
        cellText = [[[[self.dataSource objectAtIndex:indexPath.section - 1] objectForKey:@"foods"] objectAtIndex:indexPath.row] objectForKey:@"FoodName"];
        if ([self.foodSet containsObject:cellText]) {
            textColor = [StandardUtils blueColor];
        }
    }
    cell.textLabel.text = cellText;
    cell.textLabel.textColor = textColor;
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return @"";
    }
    return [[self.dataSource objectAtIndex:section - 1] objectForKey:@"SectionName"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        BuildingViewController* bvc = (BuildingViewController*)[StandardUtils viewControllerFromStoryboardWithIdentifier:@"Building View"];
        bvc.allowsMap = YES;
        [bvc setBuilding:[self.diningHallInfo objectForKey:self.navigationItem.rightBarButtonItem.title]];
        bvc.view.backgroundColor = self.tableView.backgroundColor;
        [self.navigationController pushViewController:bvc animated:YES];
        return;
    }
    FoodViewController* fvc = (FoodViewController*)[StandardUtils viewControllerFromStoryboardWithIdentifier:@"Food View"];
    [fvc setFood:[[[self.dataSource objectAtIndex:indexPath.section - 1] objectForKey:@"foods"] objectAtIndex:indexPath.row]];
    [fvc setTitle:[fvc.food objectForKey:@"FoodName"]];
    fvc.view.backgroundColor = self.tableView.backgroundColor;
    [self.navigationController pushViewController:fvc animated:YES];
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* headerIdentifier = @"MenuTableHeaderIdentifier";
    NSInteger headerLabelTag = 1;
    UITableViewHeaderFooterView* header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if (header == nil) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerIdentifier];
        header.frame = CGRectMake(0, 0, self.tableView.frame.size.width, SECTION_HEIGHT);
        header.contentView.backgroundColor = self.view.backgroundColor;
        CGSize headerSize = header.frame.size;
        int labelInset = 20;
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(labelInset, 0, headerSize.width - labelInset, headerSize.height)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.numberOfLines = 2;
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumFontSize = 14;
        label.tag = headerLabelTag;
        [header addSubview:label];
    }
    UILabel* label = (UILabel*)[header viewWithTag:headerLabelTag];
    if(section == 0) {
        label.text = @"Dining Center Info";
    } else {
        label.text = [[self.dataSource objectAtIndex:section - 1] objectForKey:@"SectionName"];
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SECTION_HEIGHT;
}

//*********************************************************
//*********************************************************
#pragma mark - Other
//*********************************************************
//*********************************************************

// If it is after the meal scrape time(2:00) and the last update 
// was before 2:00 then load the data again.
// To be safe it checks if it is after 3
// compares the dates with ints (yyyymmddhh)
- (void)loadDataBasedOnDate {
    if(!self.lastUpdate || !self.dataSource) {
        [self loadData];
        return;
    }
    NSNumber* lastUpdate = [MenuTableViewController getNumericalDate:self.lastUpdate];
    NSNumber* serversLastUpdate = [MenuTableViewController getServersLastUpdateTime];
    NSComparisonResult compare = [serversLastUpdate compare:lastUpdate];
    if(compare == NSOrderedDescending) {
        [self loadData];
    }
}
 
+ (NSNumber*)getNumericalDate:(NSDate*)date {
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMddHHmm"];
    NSString* dateString = [dateFormat stringFromDate:date];
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* dateNum = [formatter numberFromString:dateString];

    return dateNum;
}

+ (NSNumber*)getServersLastUpdateTime {
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ijumboapp.com/api/json/mealDate"]];
    NSError* error;
    if(!data) {
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMddhhmm"];
        return [NSNumber numberWithInt:[[dateFormat stringFromDate:[NSDate date]] intValue]];
    }
    NSDictionary* dateDict = [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:&error];
    NSNumber* number = [dateDict objectForKey:@"date"];
    return number;
}

- (IBAction)showMyFood:(id)sender {
    MyFoodViewController* myFood = (MyFoodViewController*)[StandardUtils viewControllerFromStoryboardWithIdentifier:@"My Food VC"];
    myFood.view.hidden = NO;
    myFood.tableView.backgroundColor = self.view.backgroundColor;
    myFood.foodSet = self.foodSet;
    [self.navigationController pushViewController:myFood animated:YES];
}

+ (void)subscribeToFood:(NSString*)foodName {
    [MyFoodViewController subscribeToFood:foodName];
}

//*********************************************************
//*********************************************************
#pragma mark - Data Management
//*********************************************************
//*********************************************************

- (void)clearUnnecessary {
    [self setNoFood:nil];
    [self setLoadingView:nil];
    [self setDiningHallInfo:nil];
}

- (UIView*)loadingView {
    if(!_loadingView) {
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 320, HEIGHT_OF_HELPER_VIEWS_IN_MEALS)];
        _loadingView.backgroundColor = [UIColor clearColor];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, HEIGHT_OF_HELPER_VIEWS_IN_MEALS)];
        label.text = @"LOADING";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        [_loadingView addSubview:label];
        UIActivityIndicatorView* activiyIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(180, 0, 40, HEIGHT_OF_HELPER_VIEWS_IN_MEALS)];
        activiyIndicator.backgroundColor = [UIColor clearColor];
        [activiyIndicator startAnimating];
        [_loadingView addSubview:activiyIndicator];
        [self.tableView addSubview:_loadingView];
    }
    return _loadingView;
}

- (UIView*)noFood
{
    if(!_noFood) {
        _noFood = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 275)];
        _noFood.backgroundColor = [UIColor clearColor];
        UILabel* label = [[UILabel alloc] initWithFrame:_noFood.frame];
        label.text = @"Meal Not Available";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        //[_noFood addSubview:label];
        [self.tableView addSubview:_noFood];
    }
    return _noFood;
}

- (NSDictionary*)diningHallInfo
{
    if(!_diningHallInfo) {
        NSURL* mainURL = [[NSBundle mainBundle] bundleURL];
        NSURL* localURL = [NSURL URLWithString:@"diningHallInfo.json" relativeToURL:mainURL];
        NSData* jsonData = [NSData dataWithContentsOfURL:localURL];
        NSError* error;
        _diningHallInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        // update the data just in case I messed up the data as it was hand written
        dispatch_queue_t queue = dispatch_queue_create("dining.hall.info", nil);
        dispatch_async(queue, ^{
            NSURL* diningInfoURL = [NSURL URLWithString:@"http://ijumboapp.com/api/json/diningHallInfo"];
            NSData* data = [NSData dataWithContentsOfURL:diningInfoURL];
            NSError* error;
            NSDictionary* diningInfo = [NSJSONSerialization  JSONObjectWithData:data
                                                                        options:0
                                                                          error:&error];
            self.diningHallInfo = diningInfo;
            [data writeToURL:localURL atomically:YES];
        });
        dispatch_release(queue);
    }
    return _diningHallInfo;
}

- (NSSet*)foodSet {
    if (!_foodSet)
        [self loadFoodSet];
    return _foodSet;
}

- (void)loadFoodSet {
    [self setFoodSet:[PFPush getSubscribedChannels:nil]];
}

@end
