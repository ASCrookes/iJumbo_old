//
//  JoeyTrackerTable.h
//  Tufts
//
//  Created by Amadou Crookes on 7/11/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface JoeyTrackerTable : UITableViewController <UIScrollViewDelegate>

@property (nonatomic,strong) NSArray* joeyInfo;
@property (nonatomic,strong) MapViewController* map;
@property (nonatomic,strong) NSTimer* updateTimer;
@property (nonatomic,strong) UIBarButtonItem* reload;

- (void)loadData;
- (void)parseData:(NSData *)responseData;
- (void)clearUnnecessary;

@end
