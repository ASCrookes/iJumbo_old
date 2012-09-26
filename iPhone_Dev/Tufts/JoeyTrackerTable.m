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
@synthesize updateTimer = _updateTimer;
@synthesize reload = _reload;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    self.navigationItem.rightBarButtonItem = self.reload;
    [self loadData];
    if(![self.updateTimer isValid]) {
        [self.updateTimer fire];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self.updateTimer invalidate];
    self.tableView.scrollEnabled = NO;
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
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityView startAnimating];
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.navigationItem.rightBarButtonItem = loadingView;
    NSURL *url = [NSURL URLWithString:@"http://ijumboapp.com/api/json/joey"];
    self.title = @"Refreshing...";
    
    // Set up a concurrent queue
    dispatch_queue_t queue = dispatch_queue_create("Joey Load Data", nil);
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [self.joeyInfo count];
    if(count == 0) {
        return 1;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If there is no data just show a cell with a spinner saying the data is loading
    if(indexPath.section == 0 && [self.joeyInfo count] == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"Joey Loading Cell"];
    }
    static NSString *CellIdentifier = @"Joey Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }

    NSDictionary* joeyDict = [self.joeyInfo objectAtIndex:indexPath.row];
    cell.textLabel.text = [joeyDict objectForKey:@"location"];
    cell.detailTextLabel.text  = [joeyDict objectForKey:@"ETA"];
    cell.userInteractionEnabled = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.joeyInfo count] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"The Joey tracker is unavailable" message:@"or you do not have internet"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self.map viewDidLoad];
    self.map.allowAnnotationClick = NO;
    self.map.searchBar.hidden = YES;
    self.map.mapView.frame = CGRectMake(0, 0, 320, 460);
    [self.map showBuilding:[[self.joeyInfo objectAtIndex:indexPath.row] objectForKey:@"geo"]];
    
    [self.navigationController pushViewController:self.map animated:YES];

}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 320, 45)];
    label.backgroundColor = self.tableView.backgroundColor;
    label.text = @"Joey Tracker";
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
- (void)clearUnnecessary
{
    self.map = nil;
}


//*********************************************************
//*********************************************************
#pragma mark - Setters
//*********************************************************
//*********************************************************

- (NSArray*)joeyInfo
{
    if(!_joeyInfo) {
        _joeyInfo = [NSArray array];
    }
    return _joeyInfo;
}

- (MapViewController*)map
{
    if(!_map) {
        _map = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"Map View"];
    }
    return _map;
}

- (NSTimer*)updateTimer
{
    if(!_updateTimer) {
        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:55 target:self selector:@selector(loadData) userInfo:nil repeats:YES];
    }
    return _updateTimer;
}


- (UIBarButtonItem*)reload
{
    if(!_reload) {
        _reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData)];
    }
    return _reload;
}



@end
