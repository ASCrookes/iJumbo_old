//
//  MyFoodViewController.h
//  Tufts
//
//  Created by Amadou Crookes on 9/22/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface MyFoodViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) NSArray* myFood;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* allFood;
@property (strong, nonatomic) NSArray* dataSource;

+ (void)subscribeToFood:(NSString*)foodName;

@end
