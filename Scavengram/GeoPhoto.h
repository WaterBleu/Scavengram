//
//  GeoPhoto.h
//  Scavengram
//
//  Created by Jeff Huang on 2015-07-27.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface GeoPhoto : RLMObject

@property (nonatomic) double lat;
@property (nonatomic) double lng;

- (instancetype)initWithUrl:(NSString*)url andLat:(double)lat andLng:(double)lng;
- (instancetype)initWithImage:(UIImage*)image andLat:(double)lat andLng:(double)lng;
- (BOOL)isWithinProximityToLocation:(CLLocation*)location;
@end
