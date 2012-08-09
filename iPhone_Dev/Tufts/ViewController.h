//
//  ViewController.h
//  Tufts
//
//  Created by Amadou Crookes on 4/16/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "EventTableViewController.h"
#import "MenuTableViewController.h"
#import "BuildingTableViewController.h"
#import "MapViewController.h"
#import "JoeyTrackerTable.h"
#import "NewsViewController.h"
#import "InfoViewController.h"
#import "AppDelegate.h"

@interface ViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic,strong) EventTableViewController* etvc;
@property (nonatomic,strong) MenuTableViewController* mtvc;
@property (nonatomic,strong) BuildingTableViewController *btvc;
@property (nonatomic,strong) JoeyTrackerTable *joey;
@property (nonatomic,strong) MapViewController* map;
@property (nonatomic,strong) NewsViewController* news;
@property (nonatomic,strong) UIViewController* trunk;
@property (weak, nonatomic) IBOutlet UILabel* dayNum;
@property (weak, nonatomic) IBOutlet UILabel *dayWord;
@property (strong, nonatomic) UIColor* backgroundColor;

@end
