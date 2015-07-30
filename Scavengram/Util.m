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

+ (NSString*)getSession{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *sessionString = [appDelegate.sessionID UUIDString];
    return sessionString;
}

+ (NSString*)getStorageDirectory{
    NSString *sessionString = [self getSession];
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *bundleName = [self getProductName];
    
    NSString *targetDirectory = [documentDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/%@/", bundleName, sessionString]];
    
    return targetDirectory;
}

+ (void)writeToFile:(NSData*)data withFolderName:(NSString*)folderName andFileName:(NSString *)fileName{
    
    NSError *folderError = nil;
    NSError *fileError = nil;
    
    NSString *targetDirectory = [[self getStorageDirectory] stringByAppendingString:[NSString stringWithFormat:@"%@/", folderName]];
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:targetDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath: targetDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&folderError];
    
    NSString *path = [targetDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName ,[self getProductName]]];
    
    [data writeToFile:path options:NSDataWritingAtomic error:&fileError];
    
}

+ (NSData*)getImageData:(NSString*)fileName withFolderName:(NSString*)folderName{
    NSString *targetDirectory = [[self getStorageDirectory] stringByAppendingString:[NSString stringWithFormat:@"%@/", folderName]];
    NSString *path = [targetDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName ,[self getProductName]]];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    
    return data;
}

+ (BOOL)removeSession{
    NSString *targetDirectory = [self getStorageDirectory];
    return [[NSFileManager defaultManager] removeItemAtPath:targetDirectory error:nil];
}

@end
