//
//  GeoPhoto.m
//  Scavengram
//
//  Created by Jeff Huang on 2015-07-27.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GeoPhoto.h"

const double proximity = 100;
@interface GeoPhoto ()

@property (nonatomic) UIImage *image;

@end

@implementation GeoPhoto

- (instancetype)initWithImage:(UIImage*)image andLat:(double)lat andLng:(double)lng
{
    self = [super init];
    if (self) {
        self.image = image;
        self.lat = lat;
        self.lng = lng;
    }
    return self;
}

- (BOOL)isWithinProximityToLocation:(CLLocation*)location{
    CLLocationDistance distance = [location distanceFromLocation:[[CLLocation alloc]initWithLatitude:self.lat longitude:self.lng]];
    if (distance < proximity)
        return YES;
    else
        return NO;
}



@end
