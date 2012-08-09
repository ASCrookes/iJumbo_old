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

@interface EventTableViewController : UIViewController <NSXMLParserDelegate, UITableViewDataSource, UITabBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSArray* dataSource;
@property (nonatomic,strong) NSMutableArray* events;
@property (nonatomic,strong) NSDate* date;
@property (nonatomic,strong) NSString* url;
@property (nonatomic,strong) UIView* noEvents;
@property (nonatomic,strong) UIView* loadingView;
@property (strong, nonatomic) UIDatePicker* datePicker;
@property (nonatomic) BOOL isLoading;

// For getting the info from the rss feed
@property (nonatomic,strong) NSXMLParser* rssParser;
@property (nonatomic,strong) NSMutableDictionary* currentEvent;
@property (nonatomic,strong) NSString* currentKey;

@property (weak, nonatomic) IBOutlet UINavigationBar *dayBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)parseXMLFileAtURL:(NSString *)URL; 
- (void)loadData;
- (void)clearUnnecessary;

@end
