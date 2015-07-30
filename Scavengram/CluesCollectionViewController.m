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

@interface CluesCollectionViewController () {

    NSMutableArray *picsArray;
    NSMutableArray *photoIDArray;
    
}

@end

@implementation CluesCollectionViewController

static NSString * const reuseIdentifier = @"ClueCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)fetchResult {
    
    NSString *apiURL = @"https://api.flickr.com/services/rest/?api_key=5f834de364c936e23556add640bc4ee8&format=json&tags=%@&tag_mode=all&min_upload_date=1420070400&sort=interestingness-desc&privacy_filter=1&has_geo=1&lat=%f&lon=%f&radius=%@&per_page=%@&method=flickr.photos.search&nojsoncallback=1";
    
    NSURL *targetURL = [[NSURL alloc] initWithString:
                        [NSString stringWithFormat:apiURL
                         , @"" //current tag
                         , @"" //main image's lat
                         , @"" //main image's lng
                         , @"0.3"
                         , @"9"]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:targetURL];
    NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error){
            NSError *jsonError = nil;
            
            NSDictionary *retrievedPhotoIDDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            NSArray *retrievedPhotoID = [retrievedPhotoIDDict valueForKeyPath:@"photos.photo"];
            
            for(NSDictionary *dict in retrievedPhotoID){
                [photoIDArray addObject:dict[@"id"]];
            }
            
            NSString *apiURL = @"https://api.flickr.com/services/rest/?api_key=5f834de364c936e23556add640bc4ee8&format=json&photo_id=%@&method=flickr.photos.getsizes&nojsoncallback=1";
            
            NSURL *targetURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:apiURL,[photoIDArray firstObject]]];
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
                    
                    NSURL *targetURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:apiURL,[photoIDArray firstObject]]];
                    
                    NSURLSession *session = [NSURLSession sharedSession];
                    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:targetURL];
                    NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (!error){
                            NSError *jsonError = nil;
                            
                            NSURLSession *session = [NSURLSession sharedSession];
                            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:imageURL];
                            NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                if (!error){
                                    UIImage *image = [[UIImage alloc] initWithData:data];
                                    [picsArray addObject:image];
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
    return [picsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    GeoPhoto *eachImage = [picsArray objectAtIndex:indexPath.row];
    CluesCollectionViewCell *cell = [self.itemView dequeueReusableCellWithReuseIdentifier:@"ClueCell" forIndexPath:indexPath];
    // [cell.geoPhotoImageView setImage:eachImage];
    
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
