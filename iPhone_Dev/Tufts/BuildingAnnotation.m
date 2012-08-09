//
//  BuildingAnnotation.m
//  Tufts
//
//  Created by Amadou Crookes on 5/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "BuildingAnnotation.h"

@implementation BuildingAnnotation

@synthesize building = _building;
@synthesize coordinate = _coordinate;

+ (BuildingAnnotation*) buildingWithJson:(id)json
{
    BuildingAnnotation* annotation = [[BuildingAnnotation alloc] init];
    annotation.building = json;
    
    return annotation;
}

- (NSString*)title
{
    return [_building objectForKey:@"building_name"];
}

- (NSString*)subtitle
{
    return nil;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D location;
    location.latitude = [(NSString*)[_building objectForKey:@"latitude"] doubleValue];
    location.longitude = [(NSString*)[_building objectForKey:@"longitude"] doubleValue];
    
    return location;
}


@end
