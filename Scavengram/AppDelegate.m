//
//  AppDelegate.m
//  Scavengram
//
//  Created by Jeff Huang on 2015-07-27.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "ParamsViewController.h"

@interface AppDelegate () <CLLocationManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self startLocationManager];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)setUpLocationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.distanceFilter = 10;
        //have to move 100m before location manager checks again
        
        _locationManager.delegate = self;
        [_locationManager requestWhenInUseAuthorization];
        NSLog(@"new location Manager in startLocationManager");
        
    }
    [_locationManager startUpdatingLocation];
    NSLog(@"Start Regular Location Manager");
}

- (void)startLocationManager{
    if ([CLLocationManager locationServicesEnabled]) {
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
            [self setUpLocationManager];
            
        }else if (!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)){
            [self setUpLocationManager];
            
        }else{
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"Location services are disabled, Please go into Settings > Privacy > Location to enable them for Play"
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"Ok", nil];
            [alertView show];
            
        }
    }
}

-(void)stopLocationManager{
    if ([CLLocationManager locationServicesEnabled]) {
        if (_locationManager) {
            [_locationManager stopUpdatingLocation];
            NSLog(@"Stop Regular Location Manager");
        }
    }
}

-(void)locationManager:(nonnull CLLocationManager *)manager didUpdateLocations:(nonnull NSArray *)locations {
    CLLocation * loc = [locations objectAtIndex: [locations indexOfObject: [locations lastObject]]];
    
    NSLog(@"Time %@, latitude %+.6f, longitude %+.6f currentLocation accuracy %1.2f loc accuracy %1.2f timeinterval %f",[NSDate date],loc.coordinate.latitude, loc.coordinate.longitude, loc.horizontalAccuracy, loc.horizontalAccuracy, fabs([loc.timestamp timeIntervalSinceNow]));
    
    NSTimeInterval locationAge = -[loc.timestamp timeIntervalSinceNow];
    if (locationAge > 10.0){
        NSLog(@"locationAge is %1.2f",locationAge);
        return;
    }
    
    if (loc.horizontalAccuracy < 0){
        NSLog(@"loc.horizontalAccuracy is %1.2f",loc.horizontalAccuracy);
        return;
    }
    
    if (_currentLocation == nil || _currentLocation.horizontalAccuracy >= loc.horizontalAccuracy){
        _currentLocation = loc;
        
        if (loc.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            [self stopLocationManager];
        }
    }
}

@end