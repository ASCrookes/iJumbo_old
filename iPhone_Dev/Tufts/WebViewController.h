//
//  WebViewController.h
//  Tufts
//
//  Created by Amadou Crookes on 10/4/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *forwardButton;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) UIBarButtonItem* safari;

- (void)setWebViewWithURL:(NSString*)url delegate:(id <UIWebViewDelegate>)del;

@end
