//
//  Util.h
//  Scavengram
//
//  Created by Jeff Huang on 2015-07-29.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (NSString*)getProductName;

+ (void)writeToFile:(NSData*)data withFolderName:(NSString*)folderName andFileName:(NSString *)fileName;
+ (NSData*)getImageData:(NSString*)fileName withFolderName:(NSString*)folderName;
+ (BOOL)hasFetchedImage;
+ (int)getNumOfHints;

+ (void)removeSession;
+ (void)removeHints;

@end
