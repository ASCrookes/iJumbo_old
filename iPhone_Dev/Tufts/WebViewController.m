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
@synthesize safari = _safari;

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
    [self.webView setScalesPageToFit:YES];
    self.navigationItem.rightBarButtonItem = self.safari;
	// Do any additional setup after loading the view.
    [self setSecondNavigationBar];
}

- (void)setSecondNavigationBar {
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [self.navBar setBackgroundColor:[UIColor colorWithRed:72.0/255 green:145.0/255 blue:206.0/255 alpha:1.0]];
    [self.navBar setTintColor:[UIColor colorWithRed:72.0/255 green:145.0/255 blue:206.0/255 alpha:1.0]];
    [self.navBar setBarTintColor:self.navBar.tintColor];
    self.navBar.translucent = NO;
    UIBarButtonItem* forward = [[UIBarButtonItem alloc] initWithTitle:@"Forward" style:UIBarButtonItemStylePlain target:self.webView action:@selector(goForward)];
    UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)];
    UINavigationItem* navItem = [[UINavigationItem alloc] init];
    navItem.rightBarButtonItem = forward;
    navItem.leftBarButtonItem = back;
    [self.navBar pushNavigationItem:navItem animated:NO];
    
    [self.view addSubview:self.navBar];
}

// The delegate for this function must be set before
- (void)setWebViewWithURL:(NSString*)url delegate:(id <UIWebViewDelegate>)del
{
    self.url = url;
    int height = [[UIScreen mainScreen] bounds].size.height;
    // the 2 navigation bars plus that status bar is 44 + 44 + 20 which is about 110
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, height-110)];
    self.webView.delegate = self;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)openInSafari {
    NSString *currentURL = self.webView.request.URL.absoluteString;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentURL]];
}

//*********************************************************
//*********************************************************
#pragma mark - Web View Delegate 
//*********************************************************
//*********************************************************

- (void)webViewDidStartLoad:(UIWebView *)webView {
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityView startAnimating];
    self.navBar.topItem.titleView = activityView;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.navBar.topItem.titleView = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Could not load" message:@"Try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    // [alert show];
    self.navBar.topItem.titleView = nil;
}

- (UIBarButtonItem*)safari {
    if (!_safari) {
        _safari = [[UIBarButtonItem alloc] initWithTitle:@"Safari" style:UIBarButtonItemStylePlain target:self action:@selector(openInSafari)];
    }
    return _safari;
}

@end
