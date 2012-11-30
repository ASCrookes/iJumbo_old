//
//  EventTableViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 4/16/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "EventTableViewController.h"

const int SECONDS_IN_DAY = 86400;
const int HEIGHT_OF_HELPER_VIEWS = 186;

@interface EventTableViewController ()

@end


@implementation EventTableViewController

@synthesize events = _events;
@synthesize date = _date;
@synthesize rssParser = _rssParser;
@synthesize currentKey = _currentKey;
@synthesize dayBar = _dayBar;
@synthesize tableView = _tableView;
@synthesize currentEvent = _currentEvent;
@synthesize url = _url;
@synthesize dataSource = _dataSource;
@synthesize noEvents = _noEvents;
@synthesize loadingView = _loadingView;
@synthesize datePicker = _datePicker;
@synthesize isLoading = _isLoading;

//*********************************************************
//*********************************************************
#pragma mark - Standard Stuff
//*********************************************************
//*********************************************************



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Tufts Life";
    // load the date picker so it doesnt randomly show up when the events page first displays
    (void)self.datePicker;

    // Loading and no event views are added before the screen loads
    // they need to be deleted or else they will alwyas be there
    self.loadingView = nil;
    self.noEvents = nil;
    
    


    [self.dayBar setBackgroundImage:[UIImage imageNamed:@"LowerNavBar.png"] forBarMetrics:UIBarMetricsDefault];
    self.date = [NSDate date];
    UIBarButtonItem* datePicker = [[UIBarButtonItem alloc] initWithTitle:@"Calendar" style:UIBarButtonItemStylePlain target:self action:@selector(showDatePicker:)];
    [self.navigationItem setRightBarButtonItem:datePicker];
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [self setDayBar:nil];
    [self setTableView:nil];
    [self setNoEvents:nil];
    [self setLoadingView:nil];
    [self setDatePicker:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(self.isLoading) {
        self.loadingView.hidden = NO;
    } else {
        [self.tableView reloadData];
        if([self.dataSource count] == 0) {
            self.noEvents.hidden = NO;
            [self loadData];
        }
    }
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
    [self abortParser];
    self.dataSource = [NSArray array];
    //[self.tableView reloadData];
    dispatch_queue_t queue = dispatch_queue_create("Event.Table.Load", NULL);
    dispatch_async(queue, ^{
        self.events = [NSMutableArray array];
        [self parseXMLFileAtURL:self.url];
        
    });
    dispatch_release(queue);
}

//*********************************************************
//*********************************************************
#pragma mark - Table view data source
//*********************************************************
//*********************************************************


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [self.dataSource count];
    self.noEvents.hidden = !(rows == 0);

    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Event Table Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    id event = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [event objectForKey:@"title"];
    cell.detailTextLabel.text = [EventTableViewController getTimeSpanFromEvent:event];
    
    return cell;
}

+ (NSString*)getTimeSpanFromEvent:(NSDictionary*)event
{
    NSString* timeSpan = [EventTableViewController twelveHourTime:[event objectForKey:@"event_start"]];
    [EventTableViewController twelveHourTime:timeSpan];
    if([event containsKey:@"event_end"]) {
        timeSpan = [[timeSpan stringByAppendingString:@"-"] stringByAppendingString:[EventTableViewController twelveHourTime:[event objectForKey:@"event_end"]]];
    }
    return timeSpan;
}

+ (NSString*)twelveHourTime:(NSString*)time
{
    int hours = [[time substringToIndex:2] intValue];
    int minutes = [[time substringFromIndex:3] intValue];
    if( (hours == 12 || hours == 0) && minutes == 0) {
        return (hours == 12) ? @"NOON" : @"MIDNIGHT";
    }
    
    NSString* period = (hours >12) ? @"PM" : @"AM";
    hours = (hours > 12) ? hours - 12 : hours;
    
    
    return [[NSString stringWithFormat:@"%02d:%02d", hours, minutes] stringByAppendingString:period];
}


//*********************************************************
//*********************************************************
#pragma mark - Table view delegate
//*********************************************************
//*********************************************************


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self resignDatePicker];
    EventViewController* eventPage = [self.storyboard instantiateViewControllerWithIdentifier:@"Event View"];
    [eventPage loadView];
    [eventPage setEvent:[self.dataSource objectAtIndex:indexPath.row]];
    [eventPage setUp];
    eventPage.title = @"Events";
    eventPage.view.backgroundColor = self.tableView.backgroundColor;
    [self.navigationController pushViewController:eventPage animated:YES];
}


//*********************************************************
//*********************************************************
#pragma mark - RSS XML Parsing
//*********************************************************
//*********************************************************


- (void)parseXMLFileAtURL:(NSString *)URL 
{ 
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataSource = [NSArray array];
        self.events = [NSMutableArray array];
        self.currentEvent = [NSMutableDictionary dictionaryWithObject:@"" forKey:@"description"];
        self.noEvents.hidden = YES;
        self.loadingView.hidden = NO;
    });
    NSURL *xmlURL = [NSURL URLWithString:self.url]; // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error // this may be necessary only for the toolchain 
    self.rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL]; // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks. 
    [self.rssParser setDelegate:self]; // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser. 
    [self.rssParser setShouldProcessNamespaces:NO]; 
    [self.rssParser setShouldReportNamespacePrefixes:NO]; 
    [self.rssParser setShouldResolveExternalEntities:NO];
    [self.rssParser parse];

}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.currentKey = elementName;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"description"] && self.currentEvent && [self.currentEvent count] >= 7) {
        if(![[self.currentEvent objectForKey:@"title"] isEqualToString:@"TuftsLife Calendar Feed"]) {
            [self.events addObject:self.currentEvent];
        }
        self.currentEvent = [NSMutableDictionary dictionaryWithObject:@"" forKey:@"description"];
    }
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.events = [NSMutableArray array];
    NSLog(@"STARTING DOC");
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    self.dataSource = self.events;
    self.events = [NSMutableArray array];
    self.isLoading = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingView.hidden = YES;
        [self.tableView reloadData];
    });
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"FOUND: %@", string);
    if(![self continueWithCurrentKey] || ![self validEventValue:string]) {
        return;
    }
    
    if([self.currentKey isEqualToString:@"item"]) {
        self.currentEvent = [NSMutableDictionary dictionaryWithObject:@"" forKey:@"description"];
    } else if([self.currentKey isEqualToString:@"title"]) {
        [self.currentEvent setObject:string forKey:@"title"];
        
    } else if([self.currentKey isEqualToString:@"link"]) {
        [self.currentEvent setObject:string forKey:@"link"];
        
    } else if([self.currentKey isEqualToString:@"location"]) {
        [self.currentEvent setObject:string forKey:@"location"];
        
    } else if([self.currentKey isEqualToString:@"event_date"]) {
        [self.currentEvent setObject:string forKey:@"event_date"];
        
    } else if([self.currentKey isEqualToString:@"event_start"]) {
        [self.currentEvent setObject:string forKey:@"event_start"];
        
    } else if([self.currentKey isEqualToString:@"event_end"]) {
        [self.currentEvent setObject:string forKey:@"event_end"];
    } 
    else if([self.currentKey isEqualToString:@"description"]) {
        NSString* desc = ([self validEventValue:string]) ? [[self.currentEvent objectForKey:@"description"] stringByAppendingString:string] : nil;
        if(desc) {
            [self.currentEvent setObject:desc forKey:@"description"];
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"PARSER ERROR: %@", parseError);
    [self abortParser];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    NSLog(@"VALIDATION ERROR: %@", validationError);
    [self abortParser];
}


- (BOOL)continueWithCurrentKey
{
    // Make sure the key is one that we want to capture and it is not already set
    if(!self.currentKey) { return NO; }
    return  ([self.currentKey isEqualToString:@"item"] && ![self.currentEvent objectForKey:@"item"])               || 
            ([self.currentKey isEqualToString:@"title"] && ![self. currentEvent objectForKey:@"title"])            ||
            ([self.currentKey isEqualToString:@"link"] && ![self.currentEvent objectForKey:@"link"])               ||
            ([self.currentKey isEqualToString:@"location"] && ![self.currentEvent objectForKey:@"location"])       ||
            ([self.currentKey isEqualToString:@"event_date"] && ![self.currentEvent objectForKey:@"event_date"])   ||
            ([self.currentKey isEqualToString:@"event_start"] && ![self.currentEvent objectForKey:@"event_start"]) ||
            ([self.currentKey isEqualToString:@"event_end"] && ![self.currentEvent objectForKey:@"event_end"])     ||
            ([self.currentKey isEqualToString:@"description"]);
}

- (BOOL)validEventValue:(NSString*)value
{
    NSString* strippedVal = [value stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    return ( ![strippedVal isEqualToString:@""]    && 
            ![strippedVal isEqualToString:@"<"]    && 
            ![strippedVal isEqualToString:@"p"]    && 
            ![strippedVal isEqualToString:@">"]    &&
            ![strippedVal isEqualToString:@"br /"] &&
            ![strippedVal isEqualToString:@"/p"]);
}

- (void)abortParser {
    self.isLoading = NO;
    self.rssParser = nil;
    self.dataSource = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingView.hidden = YES;
        [self.tableView reloadData];
    });
}

//*********************************************************
//*********************************************************
#pragma mark - Tab bar items
//*********************************************************
//*********************************************************


- (IBAction)leftBarButtonAction:(id)sender
{
    [self resignDatePicker];
    [self changeDateToDate:[self.date dateByAddingTimeInterval:-1 * SECONDS_IN_DAY]];
}

- (IBAction)rightBarButtonAction:(id)sender
{
    [self resignDatePicker];
    [self changeDateToDate:[self.date dateByAddingTimeInterval:SECONDS_IN_DAY]];
}

//*********************************************************
//*********************************************************
#pragma mark - Date picker/keyboard
//*********************************************************
//*********************************************************

- (void)showDatePicker:(id)sender
{
    self.datePicker.date = self.date;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    if(self.datePicker.center.y > screenHeight) {
        [UIView animateWithDuration:0.3 animations:^{
            self.navigationItem.rightBarButtonItem.title = @"Hide Cal";
            self.datePicker.center = CGPointMake(screenWidth/2, screenHeight-172);
        }];
    } else {
        [self resignDatePicker];
    }
}

- (void)resignDatePicker
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationItem.rightBarButtonItem.title = @"Calendar";
        self.datePicker.center = CGPointMake(screenWidth/2, screenHeight+44);
    }];
}

- (void)datePickerValueChanged
{
    [self changeDateToDate:self.datePicker.date];
}

- (void)changeDateToDate:(NSDate*)newDate
{
    
    self.noEvents.hidden = YES;
    self.loadingView.hidden = YES;
    [self abortParser];
    self.dataSource = [NSArray array];
    [self.tableView reloadData];
    self.events = [NSMutableArray array];
    self.currentEvent = [NSMutableDictionary dictionaryWithObject:@"" forKey:@"description"];
    
    self.date = newDate;
    [self loadData];
}


//*********************************************************
//*********************************************************
#pragma mark - Data Management
//*********************************************************
//*********************************************************

- (void)clearUnnecessary
{
    if(!self.isLoading) {
        NSLog(@"CLEARING");
        self.noEvents = nil;
        self.loadingView = nil;
        self.datePicker = nil;
    }
}



//*********************************************************
//*********************************************************
#pragma mark - Setters
//*********************************************************
//*********************************************************

- (UIDatePicker*)datePicker
{
    if(!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        [_datePicker setDatePickerMode:UIDatePickerModeDate];
        [_datePicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        _datePicker.center = CGPointMake(screenWidth/2, screenHeight+44);
        [self.view addSubview:_datePicker];
    }
    return _datePicker;
}

- (NSMutableArray*)events
{
    if(!_events) {
        _events = [NSMutableArray array];
    }
    return _events;
}

- (NSDate*)date
{
    if(!_date) {
        _date = [NSDate date];
    }
    return _date;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd"];

    self.dayBar.topItem.title = [dateFormat stringFromDate:_date];
}

- (NSString*)url
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM+dd%2'C'+yyyy"];
    _url = [NSString stringWithFormat:@"https://www.tuftslife.com/occurrences.rss?date=%@", [dateFormat stringFromDate:self.date]];
    return _url;
}

- (NSArray*)dataSource
{
    if(!_dataSource) {
        _dataSource = [NSArray array];
    }
    return _dataSource;
}

- (UIView*)noEvents
{
    if(!_noEvents) {
        _noEvents = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, HEIGHT_OF_HELPER_VIEWS)];
        _noEvents.backgroundColor = [UIColor clearColor];
        UILabel* label = [[UILabel alloc] initWithFrame:_noEvents.frame];
        label.text = @"NO EVENTS";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [_noEvents addSubview:label];
        [self.tableView addSubview:_noEvents];
    }
    return _noEvents;
}

- (UIView*)loadingView
{
    
    if(!_loadingView) {
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, HEIGHT_OF_HELPER_VIEWS)];
        _loadingView.backgroundColor = [UIColor clearColor];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, HEIGHT_OF_HELPER_VIEWS)];
        label.text = @"LOADING";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        [_loadingView addSubview:label];
        UIActivityIndicatorView* activiyIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(180, 0, 40, HEIGHT_OF_HELPER_VIEWS)];
        activiyIndicator.backgroundColor = [UIColor clearColor];
        [activiyIndicator startAnimating];
        [_loadingView addSubview:activiyIndicator];
        [self.tableView addSubview:_loadingView];
    }
    return _loadingView;
}

@end

