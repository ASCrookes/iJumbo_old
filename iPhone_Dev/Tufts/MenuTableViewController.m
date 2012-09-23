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
const int SEGMENT_TODAY = 0;
const int SEGMENT_TOMORROW = 1;

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

@synthesize dataSource = _dataSource;
@synthesize masterDict = _masterDict;
@synthesize isLoading = _isLoading;
@synthesize lastUpdate = _lastUpdate;
@synthesize loadingView = _loadingView;
@synthesize noFood = _noFood;
@synthesize dateSegment = _dateSegment;
@synthesize extraBar = _extraBar;
@synthesize tableView = _tableView;

//*********************************************************
//*********************************************************
#pragma mark - Standard Stuff
//*********************************************************
//*********************************************************


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBarInfo];
    if(!self.isLoading) {
        [self.tableView reloadData];
    }
    // If the datasource(masterDict, has not been set yet, if it is an empty array, or if the "no food" view is visible -> load data again
    if(!self.masterDict || [self.masterDict count] == 0 || !self.noFood.hidden) {
        [self loadData];
    }
    [self loadDataBasedOnDate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadDataBasedOnDate];
}

- (void)addBarInfo
{
    UIBarButtonItem* halls = [[UIBarButtonItem alloc] initWithTitle:@"Carmichael" style:UIBarButtonItemStylePlain target:self action:@selector(changeHall)];
    self.navigationItem.rightBarButtonItem = halls;
    
    UISegmentedControl* segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Break",@"Lunch",@"Dinner",nil]];
    segment.selectedSegmentIndex = 0;
    [segment addTarget:self action:@selector(setDataSourceFromMaster) forControlEvents:UIControlEventValueChanged];
    [segment setSegmentedControlStyle:UISegmentedControlStyleBar];
    segment.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segment;
    
    [self.extraBar setBackgroundImage:[UIImage imageNamed:@"LowerNavBar.png"] forBarMetrics:UIBarMetricsDefault];

    
    [self.dateSegment addTarget:self action:@selector(setDataSourceFromMaster) forControlEvents:UIControlEventValueChanged];
    self.dateSegment.selectedSegmentIndex = 0;
}


- (void)viewDidUnload
{
    [self setDateSegment:nil];
    [self setExtraBar:nil];
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
#pragma mark - Segments and Action Sheets
//*********************************************************
//*********************************************************

- (void)changeHall
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Select Dining Hall"
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"Dewick", @"Hodgdon", @"Carmichael", nil];
    
    // Show the sheet
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* diningHall = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([self.navigationItem.rightBarButtonItem.title isEqualToString:diningHall] || 
       [[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]    ) {
        return;
    }
    self.navigationItem.rightBarButtonItem.title = diningHall;
    [self setDataSourceFromMaster];
}


- (void)setDataSourceFromMaster
{
    if(!self.masterDict || !self.tomorrowsDict) {
        [self loadData];
    }
    int segIndex = ((UISegmentedControl*)self.navigationItem.titleView).selectedSegmentIndex;
    int dayIndex = ((UISegmentedControl*)self.extraBar.topItem.titleView).selectedSegmentIndex;
    NSString* mealKey = (segIndex == 0) ? @"Breakfast" : (segIndex == 1) ? @"Lunch" : @"Dinner";
    NSString* hallName = self.navigationItem.rightBarButtonItem.title;
    if(!hallName) {
        hallName = @"Carmichael";
    }
    NSDictionary* hall;
    if(dayIndex == SEGMENT_TODAY) {
        hall = [self.masterDict objectForKey:hallName];
    } else if(dayIndex == SEGMENT_TOMORROW) {
        hall = [self.tomorrowsDict objectForKey:hallName];
    }
    
    if([hall containsKey:mealKey]) {
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
    self.noFood.hidden = YES;
    self.dataSource = [NSArray array];
    [self.tableView reloadData];
    // Load data in a background queue
    dispatch_queue_t queue = dispatch_queue_create("Menu Table Load", nil);
    dispatch_async(queue, ^{
        [self parseData];
    });
    dispatch_release(queue);
}


- (void)parseData
{
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.eecs.tufts.edu/~acrook01/files/meals.json"]];
    NSData* tomorrowsData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.eecs.tufts.edu/~acrook01/files/tomorrowsMeals.json"]];
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
        [(UISegmentedControl*)self.extraBar.topItem.titleView setTitle:mealsDate forSegmentAtIndex:SEGMENT_TODAY];
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
    self.noFood.hidden = !([self.dataSource count] == 0 && !self.isLoading);
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.dataSource objectAtIndex:section] objectForKey:@"foods"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Menu Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"foods"] objectAtIndex:indexPath.row] objectForKey:@"FoodName"];
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.dataSource objectAtIndex:section] objectForKey:@"SectionName"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FoodViewController* fvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Food View"];
    [fvc setFood:[[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"foods"] objectAtIndex:indexPath.row]];
    [fvc setTitle:[fvc.food objectForKey:@"FoodName"]];
    fvc.view.backgroundColor = self.tableView.backgroundColor;
    [self.navigationController pushViewController:fvc animated:YES];
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 320, SECTION_HEIGHT)];
    label.backgroundColor = self.tableView.backgroundColor;
    label.text = [[self.dataSource objectAtIndex:section] objectForKey:@"SectionName"];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.numberOfLines = 2;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumFontSize = 14;
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, SECTION_HEIGHT)];
    [header addSubview:label];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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
- (void)loadDataBasedOnDate
{
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
 
+ (NSNumber*)getNumericalDate:(NSDate*)date
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMddHHmm"];
    NSString* dateString = [dateFormat stringFromDate:date];
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* dateNum = [formatter numberFromString:dateString];

    return dateNum;
}

+ (NSNumber*)getServersLastUpdateTime
{
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.eecs.tufts.edu/~acrook01/files/mealDate.json"]];
    NSError* error;
    NSDictionary* dateDict = [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:&error];
    NSNumber* number = [dateDict objectForKey:@"date"];
    return number;
}

// Tony Kim is the jizz
- (IBAction)showMyFood:(id)sender
{
    MyFoodViewController* myFood = [self.storyboard instantiateViewControllerWithIdentifier:@"My Food"];
    myFood.tableView.backgroundColor = self.tableView.backgroundColor;
    [self.navigationController pushViewController:myFood animated:YES];
}



//*********************************************************
//*********************************************************
#pragma mark - Data Management
//*********************************************************
//*********************************************************

- (void)clearUnnecessary
{
    [self setNoFood:nil];
    [self setLoadingView:nil];
}

- (UIView*)loadingView
{
    
    if(!_loadingView) {
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, HEIGHT_OF_HELPER_VIEWS_IN_MEALS)];
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
        _noFood = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 186)];
        _noFood.backgroundColor = [UIColor clearColor];
        UILabel* label = [[UILabel alloc] initWithFrame:_noFood.frame];
        label.text = @"Meal Not Available";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [_noFood addSubview:label];
        [self.tableView addSubview:_noFood];
    }
    return _noFood;
}

@end
