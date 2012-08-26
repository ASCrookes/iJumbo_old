//
//  NewsCell.h
//  Tufts
//
//  Created by Amadou Crookes on 7/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsStoryViewController.h"

@interface NewsCell : UITableViewCell <UIWebViewDelegate>

@property (weak,nonatomic) IBOutlet UIImageView* thumbnail;
@property (weak,nonatomic) IBOutlet UILabel* title;
@property (weak,nonatomic) IBOutlet UILabel* author;
@property (strong,nonatomic) NSString* link;
@property (strong,nonatomic) UIWebView* webView;
@property (strong,nonatomic) NewsStoryViewController* webVC;

- (void)setupCellWithStory:(NSDictionary*)story andImageData:(NSData*)imageData;
- (UIViewController*)getWebViewController;

@end

