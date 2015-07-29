//
//  GeoPhoto.h
//  Scavengram
//
//  Created by Jeff Huang on 2015-07-27.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoPhoto : NSObject

@property (nonatomic) double lat;
@property (nonatomic) double lng;

- (instancetype)initWithImage:(UIImage*)image andLat:(double)lat andLng:(double)lng;
- (BOOL)isWithinProximityToLocation:(CLLocation*)location;
@end
