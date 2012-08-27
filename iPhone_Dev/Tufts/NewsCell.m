//
//  NewsCell.m
//  Tufts
//
//  Created by Amadou Crookes on 7/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "NewsCell.h"


@implementation NewsCell

@synthesize title = _title;
@synthesize author = _author;
@synthesize thumbnail = _thumbnail;
@synthesize webView = _webView;
@synthesize webVC = _webVC;
@synthesize link = _link;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}


// story should contain media:thumbnail author and title
- (void)setupCellWithStory:(NSDictionary*)story andImageData:(NSData*)imageData
{
    self.title.text = [story objectForKey:@"title"];
    NSString* author = [story objectForKey:@"author"];
    self.link = [story objectForKey:@"link"];
    self.author.text = [author isEqualToString:@"  "] ? @"Not Available" : author; 
    if([imageData length] > 0) {
        self.thumbnail.image = [UIImage imageWithData:imageData];
    } else {
        self.thumbnail.image = [UIImage imageNamed:@"newsDefault.png"];
    }
    self.webView = nil;
    self.webVC   = nil;
    self.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//*********************************************************
//*********************************************************
#pragma mark - Web View Methods
//*********************************************************
//*********************************************************

- (NewsStoryViewController*)getWebViewController
{
    self.webVC.backButton.target = self.webView;
    self.webVC.backButton.action = @selector(goBack);
    self.webVC.forwardButton.target = self.webView;
    self.webVC.forwardButton.action = @selector(goForward);
    [self.webVC.navBar setBackgroundImage:[UIImage imageNamed:@"greyLowerNavBar.png"] forBarMetrics:UIBarMetricsDefault];
    return self.webVC;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityView startAnimating];
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.webVC.navigationItem.rightBarButtonItem = loadingView;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webVC.navigationItem.rightBarButtonItem = nil;
}

- (UIWebView*)webView
{
    if(!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 370)];
        _webView.delegate = self;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.link] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20]];
        [self.webVC.view addSubview:_webView];
    }
    return _webView;
}


- (UIViewController*)webVC
{
    if(!_webVC) {
        _webVC = [[UIStoryboard storyboardWithName:@"MainStoryboard1" bundle:nil] instantiateViewControllerWithIdentifier:@"News Story View"];
    }
    return _webVC;
}



@end
