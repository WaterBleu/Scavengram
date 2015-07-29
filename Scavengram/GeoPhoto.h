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

- (instancetype)initWithUrl:(NSString*)url andLat:(double)lat andLng:(double)lng;

@end