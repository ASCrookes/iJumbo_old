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

@interface MenuTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic,strong) NSArray* dataSource;
@property (nonatomic,strong) NSDictionary* masterDict;
@property (nonatomic,strong) NSDictionary* tomorrowsDict;
@property (nonatomic) BOOL isLoading;
@property (nonatomic,strong) NSDate* lastUpdate;
@property (nonatomic,strong) UIView* loadingView;
@property (nonatomic,strong) UIView* noFood;
@property (weak, nonatomic) IBOutlet UINavigationBar *extraBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary* diningHallInfo;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *todayBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tomorrowBarButton;
@property (weak, nonatomic) IBOutlet UIButton *myFoodButton;
@property (nonatomic,strong) NSSet* foodSet;



- (void)loadData;
- (void)parseData;
- (void)addBarInfo;
- (void)loadDataBasedOnDate;
- (void)clearUnnecessary;


+ (NSNumber*)getNumericalDate:(NSDate*)date;


@end
