//
//  NewsCell.h
//  Tufts
//
//  Created by Amadou Crookes on 7/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"

@interface NewsCell : UITableViewCell <UIWebViewDelegate>

@property (strong,nonatomic) UIImageView* thumbnail;
@property (strong, nonatomic) UILabel* title;
@property (strong, nonatomic) UILabel* author;
@property (strong, nonatomic) NSString* link;
@property (strong, nonatomic) WebViewController* webVC;
@property (nonatomic) BOOL showLoadingUI;

- (void)setupCellWithStory:(NSDictionary*)story andImageData:(NSData*)imageData;
- (WebViewController*)getWebViewController;

@end

