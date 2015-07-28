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

@interface ParamsViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) NSString* apiURL;
@property (weak, nonatomic) IBOutlet UITextField *inputRadius;
@property (weak, nonatomic) IBOutlet UITextField *inputNumResult;
@property (weak, nonatomic) IBOutlet UIPickerView *inputCategory;

@property (nonatomic) NSArray* tagArray;
@property (nonatomic) NSString* tag;

@property (nonatomic) CLLocation *currentLocation;

@property (nonatomic) NSMutableArray* photoIDArray;

@end

@implementation ParamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tagArray = @[@"Restaurant", @"Park", @"Cafe", @"Shopping", @"Beach", @"Sightseeing"];
    self.inputCategory.delegate = self;
    self.tag = _tagArray[0];
    
    _photoIDArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)fetchResult:(UIButton *)sender {
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    self.currentLocation = [[CLLocation alloc] initWithLatitude:appDelegate.currentLocation.coordinate.latitude longitude:appDelegate.currentLocation.coordinate.longitude];
    
    _apiURL = @"https://api.flickr.com/services/rest/?api_key=5f834de364c936e23556add640bc4ee8&format=json&tags=%@&tag_mode=all&min_upload_date=1420070400&sort=interestingness-desc&privacy_filter=1&has_geo=1&lat=%f&lon=%f&radius=%@&per_page=%@&method=flickr.photos.search&nojsoncallback=1";
    NSURL *targetURL = [[NSURL alloc] initWithString:
                        [NSString stringWithFormat:self.apiURL
                         , _tag
                         , _currentLocation.coordinate.latitude
                         , _currentLocation.coordinate.longitude
                         , _inputRadius.text
                         , _inputNumResult.text]];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:targetURL];
    NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error){
            NSError *jsonError = nil;
            
            NSDictionary *retrievedPhotoDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            NSArray *retrievedPhotos = [retrievedPhotoDict valueForKeyPath:@"photos.photo"];
            
            for(NSDictionary *dict in retrievedPhotos){
                [_photoIDArray addObject:dict[@"id"]];
            }
            NSLog(@"%@",self.photoIDArray);

            dispatch_async(dispatch_get_main_queue(), ^{
                //[self.reviewTable reloadData];
            });
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
