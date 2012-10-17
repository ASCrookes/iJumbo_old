//
//  BuildingCell.h
//  Tufts
//
//  Created by Amadou Crookes on 10/16/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuildingViewController.h"

@interface BuildingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *buildingName;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) NSDictionary* building;
// the table view that this cell belongs to
@property (strong, nonatomic) UIViewController* viewController;

- (void)setupCellWithBuilding:(NSDictionary*)building andViewController:(UIViewController*)vc;

@end
