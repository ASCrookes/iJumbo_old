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
        self.buildingName = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 186, 43)];
        self.buildingName.font = [UIFont boldSystemFontOfSize:17];
        
        UIImage* image = [UIImage imageNamed:@"places_button.png"];
        
        self.mapButton = [[UIButton alloc] initWithFrame:CGRectMake(206, 3, 40, 38)];
        [self.mapButton addTarget:self action:@selector(mapButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mapButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.mapButton setTitle:@"Map" forState:UIControlStateNormal];
        [self.mapButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        self.infoButton = [[UIButton alloc] initWithFrame:CGRectMake(254, 3, 40, 38)];
        [self.infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.infoButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.infoButton setTitle:@"Info" forState:UIControlStateNormal];
        self.infoButton.titleLabel.textColor = [UIColor blackColor];
        [self.infoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self addSubview:self.buildingName];
        [self addSubview:self.mapButton];
        [self addSubview:self.infoButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setupCellWithBuilding:(NSDictionary*)building hasDetailedText:(BOOL)hasDetailedText {
    self.building = building;
    self.buildingName.text = [building objectForKey:@"building_name"];
    self.mapButton.hidden = !hasDetailedText;
    self.infoButton.hidden = !hasDetailedText;
}

- (void)mapButtonAction:(id)sender {
    MapViewController* mvc = [[MapViewController alloc] init];
    mvc.delegate = self.viewController;
    // have to load the view before dropping the pin to get the animation to work
    [self.viewController.navigationController pushViewController:mvc animated:YES];
    [mvc loadView];
    [mvc viewDidLoad];
    [mvc showBuilding:self.building];
}

- (void)infoButtonAction:(id)sender {
    BuildingViewController* bvc = (BuildingViewController*)[StandardUtils viewControllerFromStoryboardWithIdentifier:@"Building View"];
    bvc.allowsMap = YES;
    [bvc setBuilding:self.building];
    bvc.view.backgroundColor = self.viewController.view.backgroundColor;
    [self.viewController.navigationController pushViewController:bvc animated:YES];
}

@end
