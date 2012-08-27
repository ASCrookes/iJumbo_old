//
//  NewsStoryViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 7/24/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "NewsStoryViewController.h"

@interface NewsStoryViewController ()

@end

@implementation NewsStoryViewController
@synthesize navBar;
@synthesize webView;
@synthesize backButton;
@synthesize forwardButton;

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
}

- (void)viewDidUnload
{
    [self setNavBar:nil];
    [self setWebView:nil];
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
