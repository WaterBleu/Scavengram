//
//  ClueViewController.m
//  Scavengram
//
//  Created by Cody Zazulak on 2015-07-27.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import "ClueViewController.h"
#import "GeoPhoto.h"

@interface ClueViewController ()

@end

@implementation ClueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Inside clue view!");
    
    GeoPhoto *image = self.imageArray[0];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:image[@"url"]]];
    self.mainImageView.image = [UIImage imageWithData: imageData];
    NSString *lat = image[@"lat"];
    NSString *lng = image[@"lng"];
    NSLog(@"https://www.google.ca/maps/dir/%@,%@//@%@,%@,15z",lat,lng,lat,lng);
    self.mainLabel.text = @"Check log for location";
    
//    [self.mainImageView setImage:image];
    [self retrieveClue];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) retrieveClue{
    NSString *apiURL = @"https://api.flickr.com/services/rest/?api_key=5f834de364c936e23556add640bc4ee8&format=json&photo_id=%@&method=flickr.photos.getsizes&nojsoncallback=1";
    
    if(_photoIDArray.count > 1){
        for(int i = 1; i < _photoIDArray.count; i++){
            NSURL *targetURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:apiURL,_photoIDArray[i]]];
            // retrieving the remaining item in the array and download in background
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:targetURL];
            NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error){
                    NSError *jsonError = nil;
                    
                    NSDictionary *retrievedPhotoDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    
                    NSArray *retrievedPhotos = [retrievedPhotoDict valueForKeyPath:@"sizes.size"];
                    
                    NSURL *imageURL;
                    for(NSDictionary *dict in retrievedPhotos){
                        if ([dict[@"label"] isEqualToString:@"Medium"]) {
                            imageURL = [[NSURL alloc] initWithString:dict[@"source"]];
                        }
                    }
                    
                    NSString *apiURL = @"https://api.flickr.com/services/rest/?api_key=5f834de364c936e23556add640bc4ee8&format=json&photo_id=%@&method=flickr.photos.geo.getlocation&nojsoncallback=1";
                    
                    NSURL *targetURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:apiURL,[_photoIDArray firstObject]]];
                    
                    NSURLSession *session = [NSURLSession sharedSession];
                    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:targetURL];
                    NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (!error){
                            NSError *jsonError = nil;
                            
                            NSDictionary *retrievedPhotoIDDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                            
                            double retrievedPhotoLat = [[retrievedPhotoIDDict valueForKeyPath:@"photo.location.latitude"] doubleValue];
                            double retrievedPhotoLng = [[retrievedPhotoIDDict valueForKeyPath:@"photo.location.longitude"] doubleValue];
                            
                            NSURLSession *session = [NSURLSession sharedSession];
                            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:imageURL];
                            NSURLSessionDownloadTask *dataTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                if(!error){
                                    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@", location]];
                                    GeoPhoto *geoPhoto = [[GeoPhoto alloc]initWithUrl:imageURL.absoluteString andLat:retrievedPhotoLat andLng:retrievedPhotoLng];
                                    
                                    [_imageArray addObject:geoPhoto];
                                    NSLog(@"Downloading in background! %dth Geophoto added, %@",i , geoPhoto);
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        RLMRealm *realm = [RLMRealm defaultRealm];
                                        [realm beginWriteTransaction];
                                        [realm addObject:geoPhoto];
                                        [realm commitWriteTransaction];
                                        
                                    });
                                }
                            }];
                            [dataTask resume];
                        }
                    }];
                    [dataTask resume];
                }
            }];
            [dataTask resume];
        }
    }
}

@end
