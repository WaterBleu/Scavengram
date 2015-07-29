//
//  GeoPhoto.m
//  Scavengram
//
//  Created by Jeff Huang on 2015-07-27.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeoPhoto.h"

@interface GeoPhoto ()

@property (nonatomic) double lat;
@property (nonatomic) double lng;
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

@end
