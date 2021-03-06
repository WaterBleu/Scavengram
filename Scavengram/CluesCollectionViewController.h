//
//  CluesCollectionViewController.h
//  Scavengram
//
//  Created by Cody Zazulak on 2015-07-27.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeoPhoto.h"

@interface CluesCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *itemView;

@property (nonatomic) GeoPhoto *currentGeoPhoto;
@property (nonatomic) int currentClueIndex;

@end
