//
//  ClueViewController.h
//  Scavengram
//
//  Created by Cody Zazulak on 2015-07-27.
//  Copyright (c) 2015 Jeff Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClueViewController : UIViewController

@property (nonatomic) NSMutableArray* photoIDArray;
@property (nonatomic) NSMutableArray* geophotoArray;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;

@end

