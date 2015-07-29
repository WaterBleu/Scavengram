//
//  ParamsViewController.m
//  Scavengram
//
//  Created by Cody Zazulak on 2015-07-27.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import "ParamsViewController.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "GeoPhoto.h"
#import "ClueViewController.h"
#import <Realm/Realm.h>

@interface ParamsViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputRadius;
@property (weak, nonatomic) IBOutlet UITextField *inputNumResult;
@property (weak, nonatomic) IBOutlet UIPickerView *inputCategory;

@property (nonatomic) NSArray* tagArray;
@property (nonatomic) NSString* tag;

@property (nonatomic) CLLocation *currentLocation;

@property (nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) NSMutableArray* photoIDArray;
@property (nonatomic) NSMutableArray* imageArray;
@property (nonatomic) NSMutableArray* geophotoArray;
@end

#define medPhotoIndex = 5;

@implementation ParamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tagArray = @[@"Restaurant", @"Park", @"Cafe", @"Shopping", @"Beach", @"Sightseeing"];
    self.inputCategory.delegate = self;
    self.tag = _tagArray[0];
    
    _imageArray = [[NSMutableArray alloc]init];
    _photoIDArray = [[NSMutableArray alloc] init];
    _geophotoArray = [[NSMutableArray alloc] init];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)runSpinner {
//    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    
//    [self addSubview:_spinner];
//    
//    [_spinner startAnimating];
//}



- (IBAction)fetchResult:(UIButton *)sender {
    
    [self.view setUserInteractionEnabled:NO];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.frame = CGRectMake(self.view.center.x-50, self.view.center.y-50, 100, 100);
    _spinner.backgroundColor = [UIColor grayColor];
    _spinner.layer.cornerRadius = 10.0;
    self.view.alpha = 0.7;
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    self.currentLocation = [[CLLocation alloc] initWithLatitude:appDelegate.currentLocation.coordinate.latitude longitude:appDelegate.currentLocation.coordinate.longitude];
    
    NSString *apiURL = @"https://api.flickr.com/services/rest/?api_key=5f834de364c936e23556add640bc4ee8&format=json&tags=%@&tag_mode=all&min_upload_date=1420070400&sort=interestingness-desc&privacy_filter=1&has_geo=1&lat=%f&lon=%f&radius=%@&per_page=%@&method=flickr.photos.search&nojsoncallback=1";
    
    NSString *radiusString = @"";
    
    if ([_inputRadius.text doubleValue] > 5.0) {
        radiusString = @"5";
    } else if ([_inputRadius.text doubleValue] < 0.5) {
        radiusString = @"0.5";
    } else {
        radiusString = _inputRadius.text;
    }
    NSLog(@"Radius Input: %@", radiusString);
    
    NSURL *targetURL = [[NSURL alloc] initWithString:
                        [NSString stringWithFormat:apiURL
                         , _tag
                         , _currentLocation.coordinate.latitude
                         , _currentLocation.coordinate.longitude
                         , radiusString
                         , _inputNumResult.text]];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:targetURL];
    NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error){
            NSError *jsonError = nil;
            
            NSDictionary *retrievedPhotoIDDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            NSArray *retrievedPhotoID = [retrievedPhotoIDDict valueForKeyPath:@"photos.photo"];
            
            for(NSDictionary *dict in retrievedPhotoID){
                [_photoIDArray addObject:dict[@"id"]];
            }
            
            NSString *apiURL = @"https://api.flickr.com/services/rest/?api_key=5f834de364c936e23556add640bc4ee8&format=json&photo_id=%@&method=flickr.photos.getsizes&nojsoncallback=1";

            NSURL *targetURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:apiURL,[_photoIDArray firstObject]]];
            // retrieving the first item in the array and the rest can be downloaded in the background.
            
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
                                GeoPhoto *geoPhoto = nil;
                                if (!error){
                                    UIImage *image = [[UIImage alloc] initWithData:data];
                                    geoPhoto = [[GeoPhoto alloc]initWithUrl:imageURL.absoluteString andLat:retrievedPhotoLat andLng:retrievedPhotoLng];
                                    [_geophotoArray addObject:geoPhoto];
                                    [_imageArray addObject:image];
                                }
                                
                                ClueViewController *clueView = [self.storyboard instantiateViewControllerWithIdentifier:@"ClueViewController"];
                                [clueView setGeophotoArray:_geophotoArray];
                                [clueView setPhotoIDArray:_photoIDArray];
                                [clueView setImageArray:_imageArray];
                                [self.spinner stopAnimating];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    RLMRealm *realm = [RLMRealm defaultRealm];
                                    [realm beginWriteTransaction];
                                    [realm addObject:geoPhoto];
                                    [realm commitWriteTransaction];
                                    
                                    self.navigationController.viewControllers = [NSArray arrayWithObject:clueView];
                                });
                                
                            }];
                            [dataTask resume];
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

#pragma mark - uipickerview item
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.tagArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.tagArray objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(pickerView == self.inputCategory)
    {
        [self.inputRadius resignFirstResponder];
        [self.inputNumResult resignFirstResponder];
    }
    switch (row) {
        case 0:
            self.tag = @"Restaurant";
            break;
        case 1:
            self.tag = @"Park";
            break;
        case 2:
            self.tag = @"Cafe";
            break;
        case 3:
            self.tag = @"Shopping";
            break;
        case 4:
            self.tag = @"Beach";
            break;
        case 5:
            self.tag = @"Sightseeing";
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
