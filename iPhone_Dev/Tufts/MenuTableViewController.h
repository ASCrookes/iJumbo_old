//
//  MenuTableViewController.h
//  Tufts
//
//  Created by Amadou Crookes on 4/17/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodViewController.h"
#import "NSDictionary+Contains_Key.h"
#import "MyFoodViewController.h"

@interface MenuTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) NSArray* dataSource;
@property (nonatomic,strong) NSDictionary* masterDict;
@property (nonatomic,strong) NSDictionary* tomorrowsDict;
@property (nonatomic) BOOL isLoading;
@property (nonatomic,strong) NSDate* lastUpdate;
@property (nonatomic,strong) UIView* loadingView;
@property (nonatomic,strong) UIView* noFood;
@property (strong, nonatomic) UINavigationBar *extraBar;
@property (nonatomic, strong) NSDictionary* diningHallInfo;
@property (strong, nonatomic) UIBarButtonItem *todayBarButton;
@property (strong, nonatomic) UIBarButtonItem *tomorrowBarButton;
@property (strong, nonatomic) UIButton *myFoodButton;
@property (nonatomic,strong) NSSet* foodSet;
@property (nonatomic,strong) UITableView* tableView;

- (void)loadData;
- (void)parseData;
- (void)addBarInfo;
- (void)loadDataBasedOnDate;
- (void)clearUnnecessary;

+ (NSNumber*)getNumericalDate:(NSDate*)date;

@end
