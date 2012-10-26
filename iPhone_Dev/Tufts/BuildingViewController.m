//
//  BuildingViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 5/10/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "BuildingViewController.h"
#import "MapViewController.h"
#import "ViewController.h"

@interface BuildingViewController ()

@end

@implementation BuildingViewController

@synthesize building = _building;
@synthesize monday_hours = _monday_hours;
@synthesize tuesday_hours = _tuesday_hours;
@synthesize wednesday_hours = _wednesday_hours;
@synthesize thursday_hours = _thursday_hours;
@synthesize friday_hours = _friday_hours;
@synthesize saturday_hours = _saturday_hours;
@synthesize sunday_hours = _sunday_hours;
@synthesize building_name = _building_name;
@synthesize phone_number = _phone_number;
@synthesize address = _address;
@synthesize scrollView = _scrollView;
@synthesize website = _website;
@synthesize hours = _hours;
@synthesize allowsMap = _allowsMap;
@synthesize monday_label = _monday_label;
@synthesize tuesday_label = _tuesday_label;
@synthesize wedbesday_label = _wedbesday_label;
@synthesize thursday_label = _thursday_label;
@synthesize friday_label = _friday_label;
@synthesize saturday_label = _saturday_label;
@synthesize sunday_label = _sunday_label;

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
	// Do any additional setup after loading the view.
    [self loadInfo];
    if(self.allowsMap)
        [self addMapButton];
    
    self.title = [self.building objectForKey:@"building_name"];
}
                        
- (void)getDirections
{
    NSString* url;
    if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6) {
        url = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%@,%@&spn=8",
               [self.building objectForKey:@"latitude"],
               [self.building objectForKey:@"longitude"] ];
    } else {
        NSString* name = [self.building objectForKey:@"building_name"];
        NSString * urlName = [name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        url = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,+%@+(%@)",
                [self.building objectForKey:@"latitude"],
                [self.building objectForKey:@"longitude"],
                urlName ];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)viewDidUnload
{
    [self setMonday_hours:nil];
    [self setTuesday_hours:nil];
    [self setWednesday_hours:nil];
    [self setThursday_hours:nil];
    [self setFriday_hours:nil];
    [self setSaturday_hours:nil];
    [self setSunday_hours:nil];
    [self setBuilding_name:nil];
    [self setPhone_number:nil];
    [self setAddress:nil];
    [self setScrollView:nil];
    [self setWebsite:nil];
    [self setMonday_label:nil];
    [self setTuesday_label:nil];
    [self setWedbesday_label:nil];
    [self setThursday_label:nil];
    [self setFriday_label:nil];
    [self setSaturday_label:nil];
    [self setSunday_label:nil];
    [self setHours:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


// Hours object will only be an array or boolean(false)
// if it is not as array hid everything
- (void)setupHours
{
    if([[_building objectForKey:@"hours"] isKindOfClass:[NSArray class]]) {
        NSArray* hours = [_building objectForKey:@"hours"];
        self.monday_hours.text = [self createTimeWithStart:[hours objectAtIndex:0] andEnd:[hours objectAtIndex:1]];
        self.tuesday_hours.text = [self createTimeWithStart:[hours objectAtIndex:2] andEnd:[hours objectAtIndex:3]];
        self.wednesday_hours.text = [self createTimeWithStart:[hours objectAtIndex:4] andEnd:[hours objectAtIndex:5]];
        self.thursday_hours.text = [self createTimeWithStart:[hours objectAtIndex:6] andEnd:[hours objectAtIndex:7]];
        self.friday_hours.text = [self createTimeWithStart:[hours objectAtIndex:8] andEnd:[hours objectAtIndex:9]];
        self.saturday_hours.text = [self createTimeWithStart:[hours objectAtIndex:10] andEnd:[hours objectAtIndex:11]];
        self.sunday_hours.text = [self createTimeWithStart:[hours objectAtIndex:12] andEnd:[hours objectAtIndex:13]];
    } else {
        self.hours.hidden = YES;
        
        self.monday_label.hidden = YES;
        self.tuesday_label.hidden = YES;
        self.wedbesday_label.hidden = YES;
        self.thursday_label.hidden = YES;
        self.friday_label.hidden = YES;
        self.saturday_label.hidden = YES;
        self.sunday_label.hidden = YES;
        
        self.monday_hours.hidden = YES;
        self.tuesday_hours.hidden = YES;
        self.wednesday_hours.hidden = YES;
        self.thursday_hours.hidden = YES;
        self.friday_hours.hidden = YES;
        self.saturday_hours.hidden = YES;
        self.sunday_hours.hidden = YES;
    }
}

- (NSString*)createTimeWithStart:(NSString*)start_time andEnd:(NSString*)end_time
{
    NSString* timeSpan = [[start_time stringByAppendingString:@"-"] stringByAppendingString:end_time];
    if([timeSpan isEqualToString:@"CLOSED-CLOSED"]) {
        timeSpan = @"CLOSED";
    }
    return timeSpan;
}
                                  
- (void)addMapButton
{
    NSString* mapType = @"Apple Maps";
    if([[[UIDevice currentDevice] systemVersion] doubleValue] < 6) {
        mapType = @"Google Maps";
    }
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithTitle:mapType style:UIBarButtonItemStylePlain target:self action:@selector(getDirections)];
    self.navigationItem.rightBarButtonItem = barButton;
}

- (void)getMap
{
    MapViewController* map = [(ViewController*)[self.navigationController.viewControllers objectAtIndex:0] map];
    [map showBuilding:self.building];
    map.allowAnnotationClick = NO;
    [self.navigationController pushViewController:map animated:YES];
}

- (void)loadInfo
{
    [self loadView];
    _scrollView.contentSize = CGSizeMake(320, 208);
    _phone_number.text = [_building objectForKey:@"phone_number"];
    _address.text = [_building objectForKey:@"address"];
    _website.text = [_building objectForKey:@"website"];
    [self setupHours];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
