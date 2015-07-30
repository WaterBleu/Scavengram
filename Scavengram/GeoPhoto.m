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

const double proximity = 30;
@interface GeoPhoto ()

@property (nonatomic) NSString *url;

@end

@implementation GeoPhoto

- (instancetype)initWithUrl:(NSString*)url andLat:(double)lat andLng:(double)lng
{
    self = [super init];
    if (self) {
        self.url = url;
        self.lat = lat;
        self.lng = lng;
    }
    return self;
}

- (BOOL)isWithinProximityToLocation:(CLLocation*)location{
    CLLocationDistance distance = [location distanceFromLocation:[[CLLocation alloc]initWithLatitude:self.lat longitude:self.lng]];
    NSLog(@"Distance: %f", distance);
    if (distance < proximity)
        return YES;
    else
        return NO;
}

-(NSString*)findDistance:(CLLocation*)location {
    CLLocationDistance distance = [location distanceFromLocation:[[CLLocation alloc]initWithLatitude:self.lat longitude:self.lng]];
    return [NSString stringWithFormat:@"%f", distance];
}

@end
