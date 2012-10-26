//
//  NewsViewController.h
//  Tufts
//
//  Created by Amadou Crookes on 7/13/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsCell.h"

@interface NewsViewController : UITableViewController <NSXMLParserDelegate, UIActionSheetDelegate>

@property (nonatomic,strong) NSMutableArray* stories;
@property (nonatomic,strong) NSArray* dataSource;
@property (nonatomic,strong) NSXMLParser* rssParser;
@property (nonatomic,strong) NSMutableDictionary* currentStory;
@property (nonatomic,strong) NSString* currentKey;
@property (nonatomic,strong) NSMutableArray* storyImages; // the image data
@property (nonatomic,strong) NSArray* imageDataSource;
@property (nonatomic,strong) UIBarButtonItem* section;
@property (nonatomic,strong) NSDictionary* urls;
@property (nonatomic,strong) NSURL* currentURL;
@property (nonatomic,strong) UIBarButtonItem* webViewBackButton;
@property (nonatomic,strong) UIBarButtonItem* webViewForwardButton;
@property (nonatomic,strong) UIWebView* currentWebView;
@property (nonatomic,strong) NSMutableDictionary* storiesByType;
@property (nonatomic,strong) NSArray* theDailyActionSheetButtons;
@property (nonatomic,strong) NSArray* theObserverActionSheetButtons;
@property (nonatomic,strong) UISegmentedControl* newsSegment;
@property (nonatomic) BOOL isLoading;


- (void)loadData;
- (BOOL)continueWithCurrentKey;
- (void)parseXMLFileAtCurrentURL;
- (void)clearUnnecessary;

@end
