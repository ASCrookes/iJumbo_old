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

@interface BuildingTableViewController : UITableViewController <UISearchBarDelegate>

@property (nonatomic,strong) NSArray* buildings;
@property (nonatomic) BOOL mapSelect;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) BOOL hasDetailedCells;
@property (nonatomic,strong) id <BuildingTableDelegate> delegate;

- (void)loadData;

@end
