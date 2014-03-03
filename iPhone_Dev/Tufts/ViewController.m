//
//  ViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 4/16/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize etvc = _etvc;
@synthesize mtvc = _mtvc;
@synthesize btvc = _btvc;
@synthesize links = _links;
@synthesize joey = _joey;
@synthesize dayNum = _dayNum;
@synthesize dayWord = _dayWord;
@synthesize map = _map;
@synthesize news = _news;
@synthesize backgroundColor = _backgroundColor;

const BOOL SHOW_NEW = NO;

//*********************************************************
//*********************************************************
#pragma mark - Standard Stuff
//*********************************************************
//*********************************************************


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = self.backgroundColor;
    self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.title = @"iJumbo";
        
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    [self setIcons];
    [self addMainButtons];
    //[self.etvc loadData]; a relatively small amount of data to load beforehand
    [self.mtvc loadData];
    [self.map loadData];
    [self.news loadData];
    [self.btvc loadData];
    [self.links loadData];
    
    // if the app is yet to launch then show a page with what is new to this version of the app
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"] && SHOW_NEW) {
        // show the new stuff here!!!!
        [self launchTutorial];
    }
    
    // Checking that the internet is available if not an alert will be shown
    [self pingInternet];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)launchTutorial
{
    UIViewController* tutorialPage = [self.storyboard instantiateViewControllerWithIdentifier:@"First Launch Tutorial"];
    tutorialPage.view.backgroundColor = self.backgroundColor;
    tutorialPage.title = @"What's New?";
    UINavigationController* navcon = [[UINavigationController alloc] initWithRootViewController:tutorialPage];
    UIBarButtonItem* barBtn = [[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStylePlain target:self action:@selector(closeTutorialPage)];
    tutorialPage.navigationItem.rightBarButtonItem = barBtn;
    navcon.navigationItem.rightBarButtonItem = barBtn;
    
    [self presentModalViewController:navcon animated:YES];
}

- (void)closeTutorialPage
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setIcons];
}

- (void)viewDidUnload
{
    [self setDayNum:nil];
    [self setDayWord:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//*********************************************************
//*********************************************************
#pragma mark - Pushing View Controllers
//*********************************************************
//*********************************************************

- (void)getEvents:(id)sender
{
    [self.navigationController pushViewController:self.etvc animated:YES];
}

- (void)getMenus:(id)sender
{
    [self.navigationController pushViewController:self.mtvc animated:YES];
}

- (void)getLinks:(id)sender
{
    [self.navigationController pushViewController:self.links animated:YES];
}

- (void)getJoey:(id)sender
{
    [self.navigationController pushViewController:self.joey animated:YES];
}

- (void)getMap:(id)sender
{
    [self.navigationController pushViewController:self.btvc animated:YES];
}

- (void)getNews:(id)sender
{
    [self.navigationController pushViewController:self.news animated:YES];
}

- (IBAction)getAppInfo:(id)sender 
{
    InfoViewController* info = [self.storyboard instantiateViewControllerWithIdentifier:@"INFO TABLE"];
    info.tableView.backgroundColor = self.backgroundColor;
    [self.navigationController pushViewController:info animated:YES];
}

//*********************************************************
//*********************************************************
#pragma mark - Other
//*********************************************************
//*********************************************************

- (void)setIcons
{
    NSDate* today = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd"];
    [_dayNum setText:[formatter stringFromDate:today]];
    [formatter setDateFormat:@"EEEE"];
    _dayWord.text = [formatter stringFromDate:today];
}

// The delegate pings the internet and then alerts if the internet is not available
- (void)pingInternet
{
    AppDelegate* del = [[UIApplication sharedApplication] delegate];
    [del pingServer];
}

- (void)addMainButtons {
    UIButton* news = [[UIButton alloc] initWithFrame:CGRectMake(20, 72, 109, 108)];
    [news setImage:[UIImage imageNamed:@"news.png"] forState:UIControlStateNormal];
    [news addTarget:self action:@selector(getNews:) forControlEvents:UIControlEventTouchUpInside];
    UIButton* places = [[UIButton alloc] initWithFrame:CGRectMake(196, 67, 109, 113)];
    [places setImage:[UIImage imageNamed:@"map.png"] forState:UIControlStateNormal];
    [places addTarget:self action:@selector(getMap:) forControlEvents:UIControlEventTouchUpInside];
    UIButton* menus = [[UIButton alloc] initWithFrame:CGRectMake(16, 203, 116, 113)];
    [menus setImage:[UIImage imageNamed:@"burger.png"] forState:UIControlStateNormal];
    [menus addTarget:self action:@selector(getMenus:) forControlEvents:UIControlEventTouchUpInside];
    UIButton* transport = [[UIButton alloc] initWithFrame:CGRectMake(196, 203, 109, 113)];
    [transport setImage:[UIImage imageNamed:@"Bus.png"] forState:UIControlStateNormal];
    [transport addTarget:self action:@selector(getJoey:) forControlEvents:UIControlEventTouchUpInside];
    UIButton* events = [[UIButton alloc] initWithFrame:CGRectMake(20, 346, 109, 109)];
    [events setImage:[UIImage imageNamed:@"event.png"] forState:UIControlStateNormal];
    [events addTarget:self action:@selector(getEvents:) forControlEvents:UIControlEventTouchUpInside];
    UIButton* links = [[UIButton alloc] initWithFrame:CGRectMake(194, 346, 109, 109)];
    [links setImage:[UIImage imageNamed:@"Webpage.png"] forState:UIControlStateNormal];
    [links addTarget:self action:@selector(getLinks:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:news];
    [self.view addSubview:places];
    [self.view addSubview:menus];
    [self.view addSubview:transport];
    [self.view addSubview:events];
    [self.view addSubview:links];

}

//*********************************************************
//*********************************************************
#pragma mark - Data Management
//*********************************************************
//*********************************************************

- (void)didReceiveMemoryWarning
{
    [self.etvc clearUnnecessary];
    [self.mtvc clearUnnecessary];
    [self.joey clearUnnecessary];
    [self.news clearUnnecessary];
}

//*********************************************************
//*********************************************************
#pragma mark - Setters
//*********************************************************
//*********************************************************


- (EventTableViewController*)etvc
{
    if(!_etvc) {
        _etvc = [[EventTableViewController alloc] init];
        _etvc.view.hidden = NO;
        _etvc.tableView.backgroundColor = self.backgroundColor;
        _etvc.view.backgroundColor = self.backgroundColor;
    }
    return _etvc;
}

- (MenuTableViewController*)mtvc
{
    if(!_mtvc) {
        _mtvc = [[MenuTableViewController alloc] init];
        _mtvc.view.hidden = NO;
        _mtvc.tableView.backgroundColor = self.backgroundColor;
        _mtvc.view.backgroundColor = self.backgroundColor;
    }
    return _mtvc;
}

- (BuildingTableViewController*)btvc
{
    if(!_btvc) {
        _btvc = [[BuildingTableViewController alloc] init];
        _btvc.mapSelect = NO;
        _btvc.hasDetailedCells = YES;
        [_btvc loadView];
        [_btvc viewDidLoad];
        _btvc.tableView.backgroundColor = self.backgroundColor;
        _btvc.view.backgroundColor = self.backgroundColor;
    }
    return _btvc;
}

- (LinksTableViewController*)links {
    if (!_links) {
        _links = [[LinksTableViewController alloc] init];
        _links.backgroundColor = self.backgroundColor;
        _links.view.backgroundColor = self.backgroundColor;
        _links.tableView.backgroundColor = self.backgroundColor;
        _links.title = @"Links";
    }
    return _links;
}

- (JoeyTrackerTable*)joey
{
    if(!_joey) {
        _joey = [[JoeyTrackerTable alloc] init];
        _joey.tableView.backgroundColor = self.backgroundColor;
        _joey.view.backgroundColor = self.backgroundColor;
    }
    return _joey;
}

- (MapViewController*)map
{
    if(!_map) {
        _map = [[MapViewController alloc] init];
        [_map addBarButton];
        _map.allowAnnotationClick = YES;
        _map.view.backgroundColor = self.backgroundColor;
    }
    return _map;
}

- (NewsViewController*)news
{
    if(!_news) {
        _news = [[NewsViewController alloc] init];
        _news.title = @"News";
    }
    return _news;
}

- (UIColor*)backgroundColor
{
    if(!_backgroundColor) {
        _backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    }
    return _backgroundColor;
}


@end
