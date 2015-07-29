//
//  ClueViewController.m
//  Scavengram
//
//  Created by Cody Zazulak on 2015-07-27.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "ClueViewController.h"
#import "GeoPhoto.h"


@interface ClueViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UIImage* submittedImage;

@property (nonatomic) GeoPhoto *currentGeoPhoto;
@property (nonatomic) int currentClueIndex;

@end

@implementation ClueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Inside clue view!");
    _currentClueIndex = 0;
    
    [self setClue];
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
//                                    NSError *fileError = nil;
//                                    NSFileManager *fileManager = [NSFileManager defaultManager];
//                                    
//                                    NSURL *newLocation = location.URLByDeletingPathExtension;
//                                    newLocation = [newLocation URLByAppendingPathExtension:@"jpeg"];
//                                    
//                                    [fileManager moveItemAtURL:location toURL:newLocation error:&fileError];
                                    
                                    NSData *data = [NSData dataWithContentsOfURL:location];
                                    UIImage *image = [UIImage imageWithData:data];
                                    
                                    GeoPhoto *geoPhoto = [[GeoPhoto alloc]initWithUrl:imageURL.absoluteString andLat:retrievedPhotoLat andLng:retrievedPhotoLng];
                                    
                                    [_geophotoArray addObject:geoPhoto];
                                    [_imageArray addObject:image];
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
- (IBAction)presentCluesCollectionView:(UIButton *)sender {
}

- (IBAction)checkResult:(UIButton *)sender {
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    
//    [self presentViewController:picker animated:YES completion:nil];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:appDelegate.currentLocation.coordinate.latitude longitude:appDelegate.currentLocation.coordinate.longitude];
    GeoPhoto *currentClue = _geophotoArray[_currentClueIndex];
    if([currentClue isWithinProximityToLocation:currentLocation]){
        if (_currentClueIndex < _geophotoArray.count - 1) {
            _currentClueIndex++;
            [self setClue];
        } else {
            NSLog(@"Game Over! You Won!!");
        }
    }
    else
        NSLog(@"Bummer! Not close enough my friend");
}

- (void) setClue{
    _currentGeoPhoto = self.geophotoArray[_currentClueIndex];
    self.mainImageView.image = self.imageArray[_currentClueIndex];
    NSString *lat = _currentGeoPhoto[@"lat"];
    NSString *lng = _currentGeoPhoto[@"lng"];
    
    NSLog(@"https://www.google.ca/maps/dir/%@,%@//@%@,%@,15z",lat,lng,lat,lng);
    self.mainLabel.text = @"Check log for location";
}

#pragma mark - Photo function

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    //_submittedImage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:appDelegate.currentLocation.coordinate.latitude longitude:appDelegate.currentLocation.coordinate.longitude];
    GeoPhoto *currentClue = _geophotoArray[_currentClueIndex];
    if([currentClue isWithinProximityToLocation:currentLocation])
        NSLog(@"Correct! Now the next clue");
    else
        NSLog(@"Bummer! Not close enough my friend");
    
    
}


@end
