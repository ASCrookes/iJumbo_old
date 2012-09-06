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
#import "TestFlight.h"

@interface MenuTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic,strong) NSArray* dataSource;
@property (nonatomic,strong) NSDictionary* masterDict;
@property (nonatomic,strong) NSDictionary* tomorrowsDict;
@property (nonatomic) BOOL isLoading;
@property (nonatomic,strong) NSDate* lastUpdate;
@property (nonatomic,strong) UIView* loadingView;
@property (nonatomic,strong) UIView* noFood;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dateSegment;
@property (weak, nonatomic) IBOutlet UINavigationBar *extraBar;

- (void)loadData;
- (void)parseData:(NSData *)responseData;
- (void)addBarInfo;
- (void)loadDataBasedOnDate;
- (void)clearUnnecessary;


+ (int)getNumericalDate:(NSDate*)date;


@end
