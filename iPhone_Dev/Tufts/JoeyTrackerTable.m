//
//  JoeyTrackerTable.m
//  Tufts
//
//  Created by Amadou Crookes on 7/11/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "JoeyTrackerTable.h"
#import "AppDelegate.h"

@interface JoeyTrackerTable ()
@end

@implementation JoeyTrackerTable

@synthesize joeyInfo = _joeyInfo;
@synthesize map = _map;
@synthesize reload = _reload;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.reload;
    [self loadData];
}

//*********************************************************
//*********************************************************
#pragma mark - JSON loading
//*********************************************************
//*********************************************************

- (void)loadData
{
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityView startAnimating];
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.navigationItem.rightBarButtonItem = loadingView;
    NSURL *url = [NSURL URLWithString:@"http://ijumboapp.com/api/json/joey"];
    self.title = @"Refreshing...";
    
    // Set up a concurrent queue
    dispatch_queue_t queue = dispatch_queue_create("Joey.Pull.Data", nil);
    dispatch_async(queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        [self parseData:data];
    });
    dispatch_release(queue);
    
}

- (void)parseData:(NSData *)responseData
{
    if(responseData == nil) {
        AppDelegate* del = [[UIApplication sharedApplication] delegate];
        [del pingServer];
        [self stopLoadingUI];
        return;
    }
    NSError* error;

    self.joeyInfo = [NSJSONSerialization JSONObjectWithData:responseData
                                                    options:0
                                                      error:&error];
    self.navigationItem.rightBarButtonItem = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = @"Transportation";
        self.navigationItem.rightBarButtonItem = self.reload;
        [self.tableView reloadData];
        [self stopLoadingUI];
        if (self.joeyInfo.count == 0 & self.navigationController.visibleViewController == self) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Joey Tracker is not available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    });
}

// Stops the UI that is setup when the data is loading
- (void)stopLoadingUI
{
    self.title = @"Transportation";
    self.navigationItem.rightBarButtonItem = self.reload;
}

//*********************************************************
//*********************************************************
#pragma mark - Table view Delegate/Data Source
//*********************************************************
//*********************************************************

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.joeyInfo.count == 0) ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 1) {
        return (self.joeyInfo.count > 0) ? self.joeyInfo.count : 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If there is no data just show a cell with a spinner saying the data is loading
    static NSString *CellIdentifier = @"Joey Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    if(indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"schedule"];
        cell.textLabel.text = @"Schedule";
        return cell;
    }
    if (self.joeyInfo.count == 0) {
        cell.textLabel.text = @"tracker is unavailable";
        cell.detailTextLabel.text = @"";
    } else {
        NSDictionary* joeyDict = [self.joeyInfo objectAtIndex:indexPath.row];
        cell.textLabel.text = [joeyDict objectForKey:@"location"];
        cell.detailTextLabel.text  = [joeyDict objectForKey:@"ETA"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        WebViewController* webView = [[WebViewController alloc] init];
        [webView setWebViewWithURL:[JoeyTrackerTable getScheduleURLBasedOnDate] delegate:nil];
        webView.title = @"Joey Schedule";
        [self.navigationController pushViewController:webView animated:YES];
        return;
    }
    if (self.joeyInfo.count == 0)
        return;
    [self.map viewDidLoad];
    self.map.allowAnnotationClick = NO;
    self.map.searchBar.userInteractionEnabled = NO;
    [self.map showBuilding:[[self.joeyInfo objectAtIndex:indexPath.row] objectForKey:@"geo"]];
    
    [self.navigationController pushViewController:self.map animated:YES];
}

+ (NSString*)getScheduleURLBasedOnDate {
    NSString* url = @"";
    NSDate* date = [NSDate date];
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [cal components:NSHourCalendarUnit fromDate:date];
    NSInteger hour = [comps hour];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"c"];
    int day_of_week = [[formatter stringFromDate:date] intValue];
    if (day_of_week == 1) {
        url = @"http://publicsafety.tufts.edu/adminsvc/sunday-schedule-2/";
    } else if (day_of_week == 7) {
        url = @"http://publicsafety.tufts.edu/adminsvc/saturday-schedule-2/";
    } else {
        if (hour < 18) {
            url = @"http://publicsafety.tufts.edu/adminsvc/day-schedule-monday-friday/";
        } else if (day_of_week < 5) {
            url = @"http://publicsafety.tufts.edu/adminsvc/night-schedule-monday-wednesday-2/";
        } else {
            url = @"http://publicsafety.tufts.edu/adminsvc/night-schedule-thursday-friday-2/";
        }
    }
    return url;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 320, 45)];
    label.backgroundColor = self.tableView.backgroundColor;
    label.text = (section == 1) ? @"Tufts Life Joey Tracker" : @"Joey Tracker Schedule";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.numberOfLines = 2;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumFontSize = 14;
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    [header addSubview:label];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

//*********************************************************
//*********************************************************
#pragma mark - Data Management
//*********************************************************
//*********************************************************

// The map is easily created
// data cannot be removed because it contains info for when the cell is clikced on
- (void)clearUnnecessary {
    self.map = nil;
}

//*********************************************************
//*********************************************************
#pragma mark - Setters
//*********************************************************
//*********************************************************

- (NSArray*)joeyInfo {
    if(!_joeyInfo) {
        _joeyInfo = [NSArray array];
    }
    return _joeyInfo;
}

- (MapViewController*)map {
    if(!_map) {
        _map = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"Map View"];
    }
    return _map;
}

- (UIBarButtonItem*)reload {
    if(!_reload) {
        _reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData)];
    }
    return _reload;
}

@end
