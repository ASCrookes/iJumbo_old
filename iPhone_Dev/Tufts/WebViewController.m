//
//  WebViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 10/4/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize navBar;
@synthesize webView = _webView;
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

    [self.navBar setBackgroundImage:[UIImage imageNamed:@"LowerNavBar.png"] forBarMetrics:UIBarMetricsDefault];
}

// The delegate for this function must be set before
- (void)setWebViewWithURL:(NSString*)url delegate:(id <UIWebViewDelegate>)del
{
    self.url = url;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 370)];
    self.webView.delegate = del;
    [self.view addSubview:self.webView];
    NSURL* webURL = [NSURL URLWithString:self.url];
    [self.webView loadRequest:[NSURLRequest requestWithURL:webURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30]];
    self.backButton.target    = self.webView;
    self.backButton.action    = @selector(goBack);
    self.forwardButton.target = self.webView;
    self.forwardButton.action = @selector(goForward);
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
