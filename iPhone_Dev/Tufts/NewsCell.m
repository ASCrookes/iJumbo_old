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

- (WebViewController*)getWebViewController
{
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
    //[webView stringByEvaluatingJavaScriptFromString:@"function setScale(){ var all_metas=document.getElementsByTagName('meta'); if (all_metas){ var k; for (k=0; k<all_metas.length;k++){ var meta_tag=all_metas[k]; var viewport= meta_tag.getAttribute('name'); if (viewport&& viewport=='viewport'){ meta_tag.setAttribute('content','width=device-width; initial-scale=1.0; maximum-scale=5.0; user-scalable=1;');}}}}"];
}

- (WebViewController*)webVC
{
    if(!_webVC) {
        _webVC = [[UIStoryboard storyboardWithName:@"MainStoryboard1" bundle:nil] instantiateViewControllerWithIdentifier:@"Web View"];
        if(self.link) {
            [_webVC setWebViewWithURL:self.link delegate:self];
        }
    }
    return _webVC;
}


@end
