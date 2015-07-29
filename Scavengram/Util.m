//
//  Util.m
//  Scavengram
//
//  Created by Jeff Huang on 2015-07-29.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import "Util.h"
#import "AppDelegate.h"

@implementation Util

+ (NSString*)getProductName{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

+ (NSString*)getStorageDirectory{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *sessionString = [appDelegate.sessionID UUIDString];
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *bundleName = [self getProductName];
    
    NSString *targetDirectory = [documentDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/%@/", bundleName, sessionString]];
    
    return targetDirectory;
}

+ (void)writeToFile:(NSData*)data andFileName:(NSString *)name{
    
    NSError *folderError = nil;
    NSError *fileError = nil;
    
    NSString *targetDirectory = [self getStorageDirectory];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:targetDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath: targetDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&folderError];
    
    NSString *path = [targetDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",name ,[self getProductName]]];
    
    [data writeToFile:path options:NSDataWritingAtomic error:&fileError];
    
}

+ (NSData*)getImageData:(int)index{
    NSString *targetDirectory = [self getStorageDirectory];
    NSString *path = [targetDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.%@",index ,[self getProductName]]];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    
    return data;
}
@end
