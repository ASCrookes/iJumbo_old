//
//  EventTableViewController.h
//  Tufts
//
//  Created by Amadou Crookes on 4/16/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventViewController.h"
#import "NSDictionary+Contains_Key.h"

@interface EventTableViewController : UIViewController <NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSDictionary* dataSource;
@property (nonatomic,strong) NSMutableArray* events;
@property (nonatomic,strong) NSDate* date;
@property (nonatomic,strong) NSString* url;
@property (nonatomic,strong) UIView* noEvents;
@property (nonatomic,strong) UIView* loadingView;
@property (strong, nonatomic) UIDatePicker* datePicker;
@property (nonatomic) BOOL isLoading;
@property (strong, nonatomic) UINavigationBar *extraNavBar;
@property (strong, nonatomic) UIBarButtonItem *nextButton;
@property (strong, nonatomic) UIBarButtonItem *previousButton;
@property (strong, nonatomic) NSDate* lastDownload;

// For getting the info from the rss feed
@property (nonatomic,strong) NSXMLParser* rssParser;
@property (nonatomic,strong) NSMutableDictionary* currentEvent;
@property (nonatomic,strong) NSString* currentKey;

@property (strong, nonatomic) UINavigationBar *dayBar;

@property (strong, nonatomic) UITableView *tableView;

- (void)loadData;
- (void)clearUnnecessary;

@end
