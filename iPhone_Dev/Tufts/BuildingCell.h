//
//  BuildingCell.h
//  Tufts
//
//  Created by Amadou Crookes on 10/16/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BuildingTableViewController;

@interface BuildingCell : UITableViewCell

@property (strong, nonatomic) UILabel *buildingName;
@property (strong, nonatomic) UIButton *mapButton;
@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) NSDictionary* building;
// the table view that this cell belongs to
@property (strong, nonatomic) BuildingTableViewController* viewController;

- (void)setupCellWithBuilding:(NSDictionary*)building hasDetailedText:(BOOL)hasDetailedText;
- (IBAction)infoButtonAction:(id)sender;


@end
