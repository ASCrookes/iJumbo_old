//
//  BuildingTableViewController.h
//  Tufts
//
//  Created by Amadou Crookes on 5/9/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuildingViewController.h"
#import "BuildingCell.h"

@protocol BuildingTableDelegate <NSObject>

- (void)selectedBuilding:(id)buildingJSON;

@end

@interface BuildingTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic,strong) NSArray* buildings;
@property (nonatomic,strong) NSArray* dataSource;
@property (nonatomic) BOOL mapSelect;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) BOOL hasDetailedCells;
@property (nonatomic,strong) id <BuildingTableDelegate> delegate;
@property (strong, nonatomic) UITableView *tableView;

- (void)loadData;

@end
