//
//  MapViewController.h
//  Tufts
//
//  Created by Amadou Crookes on 5/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BuildingAnnotation.h"
#import "BuildingTableViewController.h"

@interface MapViewController : UIViewController <BuildingTableDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic,strong) NSArray* buildings;
@property (nonatomic,strong) NSArray* annotations;

@property (nonatomic,strong) NSArray* tableBuildings;

@property (nonatomic)        BOOL allowAnnotationClick;
@property (nonatomic) BOOL isLoading;


- (void)parseData:(NSData *)responseData;
- (void)loadData;
- (void)setupView;
- (void)pushBuilding;
- (void)addBarButton;
- (void)showBuilding:(id)buildingJSON;
- (void)showTableWithAllBuildings;

@end
