//
//  EventViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 4/17/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "EventViewController.h"

@interface EventViewController ()

@end

@implementation EventViewController

@synthesize event = _event;
@synthesize eventTitle = _eventTitle;
@synthesize time = _time;
@synthesize location = _location;
@synthesize description = _description;
@synthesize link = _link;


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
    [self setUp];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setEventTitle:nil];
    [self setTime:nil];
    [self setLocation:nil];
    [self setDescription:nil];
    [self setLink:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setUp
{
    self.description.text = [self.event objectForKey:@"description"];
    self.eventTitle.text  = [self.event objectForKey:@"title"];
    self.location.text    = [self.event objectForKey:@"location"];
    self.link.text        = [self.event objectForKey:@"link"];
    self.time.text        = [self getTimeSpanFromEvent:self.event];
    
}

- (NSString*)getTimeSpanFromEvent:(NSDictionary*)event
{
    NSString* timeSpan = [event objectForKey:@"event_start"];
    if([event containsKey:@"event_end"]) {
        timeSpan = [[timeSpan stringByAppendingString:@"-"] stringByAppendingString:[event objectForKey:@"event_end"]];
    }
    return timeSpan;
}



@end
