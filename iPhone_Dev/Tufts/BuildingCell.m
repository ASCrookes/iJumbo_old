//
//  BuildingCell.m
//  Tufts
//
//  Created by Amadou Crookes on 10/16/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "BuildingCell.h"
#import "MapViewController.h"

@implementation BuildingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupCellWithBuilding:(NSDictionary*)building andViewController:(UIViewController*)vc
{
    self.building = building;
    self.buildingName.text = [building objectForKey:@"building_name"];
    self.viewController = vc;
}

- (IBAction)mapButtonAction:(id)sender
{
    MapViewController* mvc = [self.viewController.storyboard instantiateViewControllerWithIdentifier:@"Map View"];
    [mvc showBuilding:self.building];
    [self.viewController.navigationController pushViewController:mvc animated:YES];
}

- (IBAction)infoButtonAction:(id)sender
{
    BuildingViewController* bvc = [[UIStoryboard storyboardWithName:@"MainStoryboard1" bundle:nil] instantiateViewControllerWithIdentifier:@"Building View"];
    bvc.allowsMap = YES;
    [bvc setBuilding:self.building];
    bvc.view.backgroundColor = self.viewController.view.backgroundColor;
    [self.viewController.navigationController pushViewController:bvc animated:YES];
}

@end
