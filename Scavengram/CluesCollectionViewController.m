//
//  CluesCollectionViewController.m
//  Scavengram
//
//  Created by Cody Zazulak on 2015-07-27.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import "CluesCollectionViewController.h"
#import "CluesCollectionViewCell.h"
#import "GeoPhoto.h"
#import "Util.h"

@interface CluesCollectionViewController ()

@property (nonatomic) NSMutableArray *imageDataArray;
@property (nonatomic) NSMutableArray *photoIDArray;

@property (nonatomic) BOOL hasFetched;


@end

const int numResult = 5;
@implementation CluesCollectionViewController

static NSString * const reuseIdentifier = @"ClueCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageDataArray = [[NSMutableArray alloc] init];
    _photoIDArray = [[NSMutableArray alloc] init];
    [self setupHint];
}

- (void)setupHint {
    if(![Util hasFetchedImage])
        [self fetchResult];
    else{
        if([Util getNumOfHints] == numResult){
            for(int i = 0; i < numResult; i++){
                NSData *data = [Util getImageData:[NSString stringWithFormat:@"%d-%d", _currentClueIndex, i] withFolderName:@"Hints"];
                [_imageDataArray addObject:data];
            }
        }
        else
            [self fetchResult];
    }
}

- (void)fetchResult {
    //self.navigationItem.hidesBackButton = YES;
    
    NSString *apiURL = @"https://api.flickr.com/services/rest/?api_key=5f834de364c936e23556add640bc4ee8&format=json&tags=%@&tag_mode=any&min_upload_date=1420070400&sort=interestingness-desc&privacy_filter=1&has_geo=1&lat=%f&lon=%f&radius=%@&per_page=%@&method=flickr.photos.search&nojsoncallback=1";
    
    NSURL *targetURL = [[NSURL alloc] initWithString:
                        [NSString stringWithFormat:apiURL
                         , @"restaurant,cafe,shopping,vacation,fun" //current tag
                         , _currentGeoPhoto.lat //main image's lat
                         , _currentGeoPhoto.lng //main image's lng
                         , @"0.3"
                         , [NSString stringWithFormat:@"%d", numResult]]];
    
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
            
            for(int i = 0; i < _photoIDArray.count; i++){
                NSURL *targetURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:apiURL,_photoIDArray[i]]];
                
                NSURLSession *session = [NSURLSession sharedSession];
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:targetURL];
                NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (!error){
                        NSError *jsonError = nil;
                        
                        NSDictionary *retrievedPhotoDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                        
                        NSArray *retrievedPhotos = [retrievedPhotoDict valueForKeyPath:@"sizes.size"];
                        
                        NSURL *imageURL;
                        for(NSDictionary *dict in retrievedPhotos){
                            //Change size accordingly https://www.flickr.com/services/api/flickr.photos.getSizes.html
                            if ([dict[@"label"] isEqualToString:@"Medium"]) {
                                imageURL = [[NSURL alloc] initWithString:dict[@"source"]];
                            }
                        }
                        
                        NSURLSession *session = [NSURLSession sharedSession];
                        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:imageURL];
                        NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                            if(!error){
                                [Util writeToFile:data withFolderName:@"Hints" andFileName:[NSString stringWithFormat:@"%d-%d",_currentClueIndex , i]];
                                [_imageDataArray addObject:[Util getImageData:[NSString stringWithFormat:@"%d-%d",_currentClueIndex , i] withFolderName:@"Hints"]];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //self.navigationItem.hidesBackButton = NO;
                                    [self.collectionView reloadData];
                                });
                            }
                        }];
                        [dataTask resume];
                    }
                }];
                [dataTask resume];
            }
            [dataTask resume];
        }
    }];
    [dataTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_imageDataArray count];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int width = collectionView.bounds.size.width;
    return CGSizeMake(width, width);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    NSData *data = [Util getImageData:[NSString stringWithFormat:@"%d-%d", _currentClueIndex, (int)indexPath.item] withFolderName:@"Hints"];//[_imageDataArray objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithData:data];
    CluesCollectionViewCell *cell = [self.itemView dequeueReusableCellWithReuseIdentifier:@"ClueCell" forIndexPath:indexPath];
    cell.geoPhotoImageView.image = image;
    
    return cell;
    
}

@end
