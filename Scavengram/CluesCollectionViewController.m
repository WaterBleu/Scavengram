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


@end

@implementation CluesCollectionViewController

static NSString * const reuseIdentifier = @"ClueCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageDataArray = [[NSMutableArray alloc] init];
    _photoIDArray = [[NSMutableArray alloc] init];
    [self fetchResult];
    
}

- (void)fetchResult {
    
    NSString *apiURL = @"https://api.flickr.com/services/rest/?api_key=5f834de364c936e23556add640bc4ee8&format=json&tags=%@&tag_mode=any&min_upload_date=1420070400&sort=interestingness-desc&privacy_filter=1&has_geo=1&lat=%f&lon=%f&radius=%@&per_page=%@&method=flickr.photos.search&nojsoncallback=1";
    
    NSURL *targetURL = [[NSURL alloc] initWithString:
                        [NSString stringWithFormat:apiURL
                         , @"restaurant,cafe,shopping,vacation,fun" //current tag
                         , _currentGeoPhoto.lat //main image's lat
                         , _currentGeoPhoto.lng //main image's lng
                         , @"0.3"
                         , @"5"]];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    NSData *data = [_imageDataArray objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithData:data];
    CluesCollectionViewCell *cell = [self.itemView dequeueReusableCellWithReuseIdentifier:@"ClueCell" forIndexPath:indexPath];
    cell.geoPhotoImageView.image = image;
    
    return cell;
    
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
