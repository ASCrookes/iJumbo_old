//
//  NewsViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 7/13/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "NewsViewController.h"

const int UPDATE_TIME = 300; // 30 is 5 minutes -> seconds
const int IMAGE_SIZE  = 90; // The images are squares

enum NewsSegment {
    NewsSegmentDaily = 0,
    NewsSegmentObserver = 1
};

@interface NewsViewController ()

@end

@implementation NewsViewController

@synthesize stories = _stories;
@synthesize rssParser = _rssParser;
@synthesize currentStory = _currentStory;
@synthesize currentKey = _currentKey;
@synthesize storyImages = _storyImages;
@synthesize section = _section;
@synthesize urls = _urls;
@synthesize currentURL = _currentURL;
@synthesize dataSource = _dataSource;
@synthesize imageDataSource = _imageDataSource;
@synthesize webViewBackButton = _webViewBackButton;
@synthesize webViewForwardButton = _webViewForwardButton;
@synthesize currentWebView = _currentWebView;
@synthesize storiesByType = _storiesByType;
@synthesize isLoading = _isLoading;
@synthesize theDailyActionSheetButtons = _theDailyActionSheetButtons;
@synthesize theObserverActionSheetButtons = _theObserverActionSheetButtons;
@synthesize newsSegment = _newsSegment;

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
    self.tableView.separatorColor = [UIColor colorWithRed:72.0/255 green:145.0/255 blue:206.0/255 alpha:1];
    self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"whiteBackground.png"]];
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem = self.section;
    self.navigationItem.titleView = self.newsSegment;
    
    if(self.isLoading) {
        [self setLoadingUI];
    } else if([self.dataSource count] == 0) {
        [self loadData];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)loadData
{
    self.isLoading = YES;
    NSArray* storyToLoad = [self.storiesByType objectForKey:[self getKeyFromUI]];
    if(storyToLoad) {
        self.imageDataSource = [self.storiesByType objectForKey:[[self getKeyFromUI] stringByAppendingString:@"-Images"]];
        self.dataSource = storyToLoad;
        [self.tableView reloadData];
         return;
    }
    [self setLoadingUI];
    [self.rssParser abortParsing];
    dispatch_queue_t queue = dispatch_queue_create("load news data", nil);
    dispatch_async(queue, ^{
        [self parseXMLFileAtCurrentURL];
    });
    dispatch_release(queue);
}

- (void)setLoadingUI
{
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityView startAnimating];
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.navigationItem.rightBarButtonItem = loadingView;
    self.navigationItem.titleView = nil;
    self.navigationItem.title = @"Loading...";
}

//*********************************************************
//*********************************************************
#pragma mark - Table View Delegate/Data Source
//*********************************************************
//*********************************************************

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AWESOME NEWS CELL";
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[NewsCell alloc] init];
    }

    [cell setupCellWithStory:[self.dataSource objectAtIndex:indexPath.row] andImageData:[self.imageDataSource objectAtIndex:indexPath.row]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCell* cell = (NewsCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.webVC.title = [self.newsSegment titleForSegmentAtIndex:self.newsSegment.selectedSegmentIndex];
    [self.navigationController pushViewController:[cell getWebViewController] animated:YES];
}


//*********************************************************
//*********************************************************
#pragma mark - RSS XML Parsing
//*********************************************************
//*********************************************************

- (void)parseXMLFileAtCurrentURL
{ 
    self.stories = [[NSMutableArray alloc] init];
    self.storyImages = [[NSMutableArray alloc] init];

    self.currentURL = nil;
    self.rssParser = [[NSXMLParser alloc] initWithContentsOfURL:self.currentURL];
    [self.rssParser setDelegate:self]; 
    [self.rssParser setShouldProcessNamespaces:NO];
    [self.rssParser setShouldReportNamespacePrefixes:NO];
    [self.rssParser setShouldResolveExternalEntities:NO]; 
    [self.rssParser parse];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.currentKey = elementName;
    if([self.currentKey isEqualToString:@"media:thumbnail"]) {
        [self.currentStory setObject:[attributeDict objectForKey:@"url"] forKey:@"media:thumbnail"];
        if(self.newsSegment.selectedSegmentIndex == NewsSegmentObserver) {
            // this is where the observer's storyies should be saved
            [self saveCurrentStory];
        }
        
    }
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.isLoading = YES;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    self.dataSource = self.stories;
    self.imageDataSource = self.storyImages;
    [self.storiesByType setObject:self.dataSource forKey:[self getKeyFromUI]];
    [self.storiesByType setObject:self.imageDataSource forKey:[[self getKeyFromUI] stringByAppendingString:@"-Images"]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self stopLoadingUI];
    });
    self.isLoading = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"KEY: %@", self.currentKey);
    // Regex this instead something like -> '^\n\n?$' -> get obj c regex syntax if so
    NSString* strippedText = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    strippedText = [strippedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([strippedText isEqualToString:@""] && ![self continueWithCurrentKey]) {

        return;
    }
    
    if([self.currentKey isEqualToString:@"item"]) {
        self.currentStory = [NSMutableDictionary dictionaryWithCapacity:4];
    } else if([self.currentKey isEqualToString:@"title"]) {
        NSString* currentTitle = [self.currentStory objectForKey:@"title"];
        currentTitle = (currentTitle) ? currentTitle : @"";
        currentTitle = [currentTitle stringByAppendingString:string];
        [self.currentStory setObject:currentTitle forKey:@"title"];
    } else if([self.currentKey isEqualToString:@"link"]) {
        [self.currentStory setObject:string forKey:@"link"];
    } else if([self.currentKey isEqualToString:@"author"] || [self.currentKey isEqualToString:@"dc:creator"]) {
        [self.currentStory setObject:string forKey:@"author"];
    } else if([self.currentKey isEqualToString:@"enclosure"]) {
        // this is were the daily's stories should be saved
        if(self.currentStory) {
            [self saveCurrentStory];

        }
    }
}

// takes the data collected from the current story and adds it to the list of stories
- (void)saveCurrentStory
{
    // trim whitespace and newlines form the title
    NSString* title = [self.currentStory objectForKey:@"title"];
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.currentStory setObject:title forKey:@"title"];

    [self.stories addObject:self.currentStory];
    
    // adds the thumbnail data
    NSData* thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.currentStory objectForKey:@"media:thumbnail"]]];
    if(!thumbnailData) { thumbnailData = [NSData data]; }
    [self.storyImages addObject:thumbnailData];
    self.currentStory = nil;
}


- (BOOL)continueWithCurrentKey
{
    // Make sure the key is one that we want to capture and it is not already set
    return     ([self.currentKey isEqualToString:@"item"] && ![self.currentStory objectForKey:@"item"])
            || ([self.currentKey isEqualToString:@"title"] /* && ![self. currentStory objectForKey:@"title"]*/)
            || ([self.currentKey isEqualToString:@"link"] && ![self.currentStory objectForKey:@"link"])
            || (([self.currentKey isEqualToString:@"author"] || [self.currentKey isEqualToString:@"dc:creator"]) && ![self.currentStory objectForKey:@"author"])
            || ([self.currentKey isEqualToString:@"media:thumbnail"] && ![self.currentStory objectForKey:@"media:thumbnail"])
            || (([self.currentKey isEqualToString:@"enclosure"] || [self.currentKey isEqualToString:@"slash:comments"]) && ![self.currentStory objectForKey:@"enclosure"]);
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [self stopLoadingUI];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    [self stopLoadingUI];
}

// Stops the UI that show when the data is loading
// only one line but maybe more UI will be used to show data is loading
// this keeps one place of truth
// makes sure it is in the main thread
- (void)stopLoadingUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.titleView = self.newsSegment;
        self.navigationItem.rightBarButtonItem = self.section;
        self.navigationItem.title = @"News";
    });

}


//*********************************************************
//*********************************************************
#pragma mark - Action Sheet Selection
//*********************************************************
//*********************************************************


- (void)changeSection
{
    UIActionSheet* aSheet = [[UIActionSheet alloc] initWithTitle:@"Select A Section" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    NSArray* actionSheetButtons;
    if(self.newsSegment.selectedSegmentIndex == NewsSegmentDaily) {
        actionSheetButtons = self.theDailyActionSheetButtons;
    } else {
        actionSheetButtons = self.theObserverActionSheetButtons;
    }
    for(NSString* btnTitle in actionSheetButtons) {
        [aSheet addButtonWithTitle:btnTitle];
    }
    [aSheet addButtonWithTitle:@"Refresh"];
    [aSheet addButtonWithTitle:@"Cancel"];
    [aSheet setCancelButtonIndex:[aSheet numberOfButtons]-1];
    
    [aSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    NSString* selectedTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([selectedTitle isEqualToString:@"Refresh"]) {
        // clear the data so that it has to load again
        self.imageDataSource = nil;
        self.dataSource = nil;
        self.stories = nil;
        self.storiesByType = nil;
        // reload the table so that it does not try and load data no longer there
        [self.tableView reloadData];
        // fetch the fresh data
        [self loadData];
        return;
    }
    if([selectedTitle isEqualToString:self.section.title] || [selectedTitle isEqualToString:@"Cancel"]) {
        return;
    } else {
        self.section.title = selectedTitle;
    }
    
    self.currentURL = [NSURL URLWithString:[self.urls objectForKey:[self getKeyFromUI]]];
    [self loadData];
}

- (NSString*)getKeyFromUI
{
    NSString* key = [self.newsSegment titleForSegmentAtIndex:self.newsSegment.selectedSegmentIndex];
    key = [key stringByAppendingString:@"-"];
    key = [key stringByAppendingString:self.section.title];
    return key;
}


//*********************************************************
//*********************************************************
#pragma mark - Data Management
//*********************************************************
//*********************************************************

- (void)clearUnnecessary
{
    if(!self.isLoading) {
        self.stories = nil;
        self.rssParser = nil;
        self.currentStory = nil;
        self.currentKey = nil;
        self.storyImages = nil;
        self.urls = nil;
        self.currentURL = nil;
        self.storiesByType = nil;
    }
}


//*********************************************************
//*********************************************************
#pragma mark - Setters/Getters
//*********************************************************
//*********************************************************

- (NSMutableArray*)storyImages
{
    if(!_storyImages) {
        _storyImages = [[NSMutableArray alloc] init];
    }
    return _storyImages;
}

// setups a link between the bar button item to select which newspaper feed to from
- (NSDictionary*)urls
{
    if(!_urls) {
        _urls = [NSDictionary dictionaryWithObjectsAndKeys:
                 // the daily rss feed urls
                 @"http://www.tuftsdaily.com/se/tufts-daily-rss-1.445827", @"Daily-Main",
                 @"http://www.tuftsdaily.com/se/tufts-daily-news-rss-1.445867", @"Daily-News",
                 @"http://www.tuftsdaily.com/se/tufts-daily-features-rss-1.445868",@"Daily-Features",
                 @"http://www.tuftsdaily.com/se/tufts-daily-arts-rss-1.445870",@"Daily-Arts",
                 @"http://www.tuftsdaily.com/se/tufts-daily-op-ed-rss-1.445869",@"Daily-Op-Ed",
                 @"http://www.tuftsdaily.com/se/tufts-daily-sports-rss-1.445871",@"Daily-Sports",
                 // the observer rss feed urls
                 @"http://tuftsobserver.org/category/arts-culture/feed",@"Observer-Arts",
                 @"http://tuftsobserver.org/category/campus/feed",@"Observer-Campus",
                 @"http://tuftsobserver.org/category/news-features/feed",@"Observer-News",
                 @"http://tuftsobserver.org/category/off-campus/feed",@"Observer-Off Campus",
                 @"http://tuftsobserver.org/category/opinion/feed",@"Observer-Opinion",
                 @"http://tuftsobserver.org/category/poetry-prose/feed",@"Observer-Poetry",
                 @"http://tuftsobserver.org/category/extras/feed",@"Observer-Extras",
                 nil];
    }
    return _urls;
}

- (NSMutableDictionary*)storiesByType
{
    // If the the stories were loaded an hour ago delete the list 
    // and update again to get newly updated stories if any
    if(_storiesByType && [[_storiesByType objectForKey:@"createdDate"] timeIntervalSinceNow] > UPDATE_TIME) {
        _storiesByType = nil;
    }
    
    if(!_storiesByType) {
        _storiesByType = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          // keys for the daily news
                          nil,@"Daily-Main",
                          nil,@"Daily-News",
                          nil,@"Daily-Features",
                          nil,@"Daily-Arts",
                          nil,@"Daily-Op-Ed",
                          nil,@"Daily-Sports",
                          // keys for the observer news
                          nil,@"Observer-Arts",
                          nil,@"Observer-Campus",
                          nil,@"Observer-News",
                          nil,@"Observer-Off Campus",
                          nil,@"Observer-Opinion",
                          nil,@"Observer-Poetry",
                          nil,@"Observer-Extras",
                          // keys for the daily images
                          nil,@"Daily-Main-Images",
                          nil,@"Daily-News-Images",
                          nil,@"Daily-Features-Images",
                          nil,@"Daily-Arts-Images",
                          nil,@"Daily-Op-Ed-Images",
                          nil,@"Daily-Sports-Images",
                          // keys for the observer images
                          nil,@"Observer-Arts-Images",
                          nil,@"Observer-Campus-Images",
                          nil,@"Observer-News-Images",
                          nil,@"Observer-Off Campus-Images",
                          nil,@"Observer-Opinion-Images",
                          nil,@"Observer-Poetry-Images",
                          nil,@"Observer-Extras-Images",
                          [NSDate date],@"createdDate",
                          nil];
    }
    return _storiesByType;
}

- (NSArray*)theDailyActionSheetButtons
{
    if(!_theDailyActionSheetButtons) {
        _theDailyActionSheetButtons = [NSArray arrayWithObjects:@"Main",@"News",@"Features",@"Arts",@"Op-Ed",@"Sports",nil];
    }
    return _theDailyActionSheetButtons;
}

- (NSArray*)theObserverActionSheetButtons
{
    if(!_theObserverActionSheetButtons) {
        _theObserverActionSheetButtons = [NSArray arrayWithObjects:@"News",@"Arts",@"Campus",@"Off Campus",@"Opinion",@"Poetry",@"Extras",nil];
    }
    return _theObserverActionSheetButtons;
}

- (NSURL*)currentURL
{
    if(!_currentURL) {
        _currentURL = [NSURL URLWithString:[self.urls objectForKey:[self getKeyFromUI]]];
    }
    return _currentURL;
}

- (UIBarButtonItem*)section
{
    if(!_section) {
        _section = [[UIBarButtonItem alloc] initWithTitle:@"Main" style:UIBarButtonItemStylePlain target:self action:@selector(changeSection)];
    }
    return _section;
}

- (NSMutableArray*)stories
{
    if(!_stories) {
        _stories = [[NSMutableArray alloc] init];
    }
    return _stories;
}

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

- (UIBarButtonItem*)webViewForwardButton
{
    if(!_webViewForwardButton) {
        _webViewForwardButton = [[UIBarButtonItem alloc] initWithTitle:@"Forward" style:UIBarButtonItemStylePlain target:self.currentWebView action:@selector(goForward)];
    }
    return _webViewForwardButton;
}

- (UIBarButtonItem*)webViewBackButton
{
    if(!_webViewBackButton) {
        _webViewBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self.currentWebView action:@selector(goBack)];
    }
    return _webViewBackButton;
}

- (UISegmentedControl*)newsSegment
{
    if(!_newsSegment) {
        _newsSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Daily",@"Observer", nil]];
        [_newsSegment setSegmentedControlStyle:UISegmentedControlStyleBar];
        _newsSegment.selectedSegmentIndex = 0;
        [_newsSegment addTarget:self action:@selector(segmentChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _newsSegment;
}

- (void)segmentChanged
{
    if(self.newsSegment.selectedSegmentIndex == NewsSegmentDaily) {
        self.section.title = [self.theDailyActionSheetButtons objectAtIndex:0];
    } else {
        self.section.title = [self.theObserverActionSheetButtons objectAtIndex:0];
    }
    [self loadData];
}


@end
