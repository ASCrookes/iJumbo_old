//
//  BuildingAnnotation.h
//  Tufts
//
//  Created by Amadou Crookes on 5/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "BuildingViewController.h"


@interface BuildingAnnotation : NSObject <MKAnnotation>

@property (nonatomic,strong) id building; //should be the json for the building

+ (BuildingAnnotation*) buildingWithJson:(id)json;




@end
