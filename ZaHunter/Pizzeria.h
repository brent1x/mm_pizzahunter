//
//  Pizzeria.h
//  ZaHunter
//
//  Created by Brent Dady on 5/28/15.
//  Copyright (c) 2015 Brent Dady. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Pizzeria : NSObject

@property NSString *name;
@property CLLocation *location;
@property MKPlacemark *placemark;
@property CGFloat distance;
@property MKMapItem *mapItem;

@end
