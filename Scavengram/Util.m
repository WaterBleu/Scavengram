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

+ (NSString*)getRootDirectory{
    NSString *bundleName = [self getProductName];
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *targetDirectory = [documentDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@/", bundleName]];
    return targetDirectory;
}

+ (NSString*)getStorageDirectory{
    NSString *sessionString = [self getSession];

    NSString *targetDirectory = [[self getRootDirectory] stringByAppendingString:[NSString stringWithFormat:@"%@/", sessionString]];
    
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

+ (BOOL)hasFetchedImage{
    NSError *fetchError = nil;
    NSString *targetDirectory = [[self getStorageDirectory] stringByAppendingString:@"Hints/"];
    NSArray *item = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetDirectory error:&fetchError];
    if(item == nil)
        return NO;
    else
        return item.count > 0;
}

+ (void)removeSession{
    [self remove:@""];
}

+ (void)removeHints{
    [self remove:@"Hints"];
}

+ (void)remove:(NSString*)folderName{
    NSString *targetDirectory = [[self getRootDirectory] stringByAppendingString:[NSString stringWithFormat:@"%@", folderName]];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:targetDirectory error:nil];
    for (NSString *filename in fileArray)  {
        [fileMgr removeItemAtPath:[targetDirectory stringByAppendingPathComponent:filename] error:NULL];
    }
}

@end
