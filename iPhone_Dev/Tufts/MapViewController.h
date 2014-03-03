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

@protocol MapViewDelegate <NSObject>

- (void)searchBuildingsByName:(NSString*)searchText;

@end

@interface MapViewController : UIViewController <BuildingTableDelegate, UISearchBarDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UISearchBar *searchBar;

@property (nonatomic,strong) NSArray* buildings;
@property (nonatomic,strong) NSArray* annotations;

@property (nonatomic,strong) NSArray* tableBuildings;

@property (nonatomic)        BOOL allowAnnotationClick;
@property (nonatomic)        BOOL isLoading;

@property (nonatomic,strong) id <MapViewDelegate> delegate;


- (void)parseData:(NSData *)responseData;
- (void)loadData;
- (void)setupView;
- (void)pushBuilding;
- (void)addBarButton;
- (void)showBuilding:(id)buildingJSON;
- (void)showTableWithAllBuildings;

@end
