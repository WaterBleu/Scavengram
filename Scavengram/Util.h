//
//  Util.h
//  Scavengram
//
//  Created by Jeff Huang on 2015-07-29.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (void)writeToFile:(NSData*)data andFileName:(NSString*)name;
+ (NSData*)getImageData:(int)index;

@end
