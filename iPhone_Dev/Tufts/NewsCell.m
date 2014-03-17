//
//  NewsCell.m
//  Tufts
//
//  Created by Amadou Crookes on 7/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "NewsCell.h"
#import "NetworkManager.h"

@interface NewsCell ()
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;
@end


@implementation NewsCell

@synthesize activityIndicator = _activityIndicator;
@synthesize title = _title;
@synthesize author = _author;
@synthesize thumbnail = _thumbnail;
@synthesize webVC = _webVC;
@synthesize link = _link;
@synthesize showLoadingUI = _showLoadingUI;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
        self.thumbnail.backgroundColor = [UIColor darkGrayColor];
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(92, 0, 217, 69)];
        self.title.numberOfLines = 3;
        self.title.font = [UIFont boldSystemFontOfSize:17];
        self.author = [[UILabel alloc] initWithFrame:CGRectMake(92, 68, 217, 21)];
        self.author.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
        
        UIView* imageBackground = [[UIView alloc] initWithFrame:self.thumbnail.frame];
        imageBackground.backgroundColor = self.thumbnail.backgroundColor;
        
        [self addSubview:imageBackground];
        [self addSubview:self.thumbnail];
        [self addSubview:self.title];
        [self addSubview:self.author];
    }
    return self;
}

// story should contain media:thumbnail author and title
- (void)setupCellWithStory:(NSDictionary*)story {

    self.showLoadingUI = NO;
    self.title.text = [story objectForKey:@"title"];
    NSString* author = [story objectForKey:@"author"];
    self.link = [story objectForKey:@"link"];
    self.author.text = [author isEqualToString:@"  "] ? @"Not Available" : author;

    UIImage* image = [NetworkManager imageFromUrl:story[@"imageUrl"]];

    if (image == nil) {  // The image is being downloaded.
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        self.thumbnail.image = nil;
    } else if ([image isMemberOfClass:[NSNull class]]) {  // This url does not have an image.
        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];
        self.thumbnail.image = [UIImage imageNamed:@"newsDefault.png"];
    } else {  // There is an image already downloaded and in the singleton's cache.
        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];
        
        // If the image was previously being downloaded fade the image in.
        if (self.thumbnail.image == nil) {
            self.thumbnail.alpha = 0.0f;
            self.thumbnail.image = image;
            [UIView animateWithDuration:0.3f animations:^{
                self.thumbnail.alpha = 1.0f;
            }];
        } else {
            self.thumbnail.image = image;
        }
    }

    self.webVC = nil;
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

- (WebViewController*)getWebViewController
{
    return self.webVC;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(!self.showLoadingUI) {
        return;
    }
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityView startAnimating];
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.webVC.navigationItem.rightBarButtonItem = loadingView;
}

// only show loading with navigation type other
// this stop the activity indicator from spinning forever
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webVC.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // the initial load of a page falls into the navigation type "other"
    self.showLoadingUI = (navigationType == UIWebViewNavigationTypeOther ||
                          navigationType == UIWebViewNavigationTypeLinkClicked);
    return YES;
}

- (WebViewController*)webVC
{
    if(!_webVC) {
        _webVC = [[WebViewController alloc] init];
        if(self.link) {
            [_webVC setWebViewWithURL:self.link delegate:self];
        }
    }
    return _webVC;
}

- (UIActivityIndicatorView*)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
        _activityIndicator.hidden = YES;
        [_activityIndicator stopAnimating];
        [self.thumbnail addSubview:_activityIndicator];
    }
    return _activityIndicator;
}


@end
