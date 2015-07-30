//
//  ClueViewController.m
//  Scavengram
//
//  Created by Cody Zazulak on 2015-07-27.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "ParamsViewController.h"
#import "ClueViewController.h"
#import "CluesCollectionViewController.h"
#import "GeoPhoto.h"
#import "Util.h"


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
    
    UIBarButtonItem *newGameButton = [[UIBarButtonItem alloc] initWithTitle:@"New Game" style:UIBarButtonItemStylePlain target:self action:@selector(returnToStart:)];
    
    self.navigationItem.rightBarButtonItem = newGameButton;
    self.navigationItem.title = [NSString stringWithFormat:@"Clue #%d", (self.currentClueIndex + 1)];
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
}

-(void)returnToStart:(id)sender {
    NSLog(@"Got here");
    NSString *alertMessage;
    NSString *alertTitle;
    BOOL hasWon;
    if ([sender isEqual:@"gameWon"]) {
        hasWon = YES;
        alertTitle = @"Game Over! You Won!!";
        alertMessage = @"Let's start a new game!";
    }
    else{
        alertTitle = @"New Game";
        alertMessage = @"Are you sure you want to restart?";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
        //new game confirmed and clear out session.
        [Util removeSession];
        
        ParamsViewController *paramsView = [self.storyboard instantiateViewControllerWithIdentifier:@"ParamsViewController"];
        self.navigationController.viewControllers = [NSArray arrayWithObject:paramsView];

    }]];
    
    if(!hasWon){
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * __nonnull action) {
            //
        }]];
    }
    
    [self presentViewController:alert animated:YES completion:nil];

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
                            NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                if(!error){
                                    [Util writeToFile:data withFolderName:@"Clues" andFileName:[NSString stringWithFormat:@"%d", i]];

                                    GeoPhoto *geoPhoto = [[GeoPhoto alloc]initWithUrl:imageURL.absoluteString andLat:retrievedPhotoLat andLng:retrievedPhotoLng];
                                    
                                    [_geophotoArray addObject:geoPhoto];
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
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void) setClue{
    _currentGeoPhoto = self.geophotoArray[_currentClueIndex];
    self.mainImageView.image = [UIImage imageWithData:[Util getImageData:[NSString stringWithFormat:@"%d", _currentClueIndex] withFolderName:@"Clues"]];
    NSString *lat = _currentGeoPhoto[@"lat"];
    NSString *lng = _currentGeoPhoto[@"lng"];
    
    NSLog(@"https://www.google.ca/maps/dir/%@,%@//@%@,%@,15z",lat,lng,lat,lng);
    self.mainLabel.text = @"Check log for location";
    self.mainLabel.text = @"";
}

#pragma mark - Photo function

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToCluesCV"]) {
        CluesCollectionViewController *vc = (CluesCollectionViewController*)segue.destinationViewController;
        vc.currentGeoPhoto = _currentGeoPhoto;
        vc.currentClueIndex = _currentClueIndex;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    _submittedImage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate startLocationManager];
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:appDelegate.currentLocation.coordinate.latitude longitude:appDelegate.currentLocation.coordinate.longitude];
    
    GeoPhoto *currentClue = _geophotoArray[_currentClueIndex];
    
    self.mainLabel.text = [NSString stringWithFormat:@"Distance from Clue: %@", [currentClue findDistance:currentLocation]];
    
    if([currentClue isWithinProximityToLocation:currentLocation]){
        if (_currentClueIndex < _geophotoArray.count - 1) {
            _currentClueIndex++;
            [self setClue];
        } else {
            NSLog(@"Game Over! You Won!!");
            [self returnToStart:@"gameWon"];
        }
    } else {
        NSLog(@"Bummer! Not close enough my friend");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Try Again" message:@"That was not close enough!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
            // Trying again!
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


@end
