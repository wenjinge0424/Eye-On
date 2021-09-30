//
//  MapViewController.h
//  Eye On
//
//  Created by developer on 24/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"
#import "MainViewController.h"
#import "PlaceModel.h"

@interface MapViewController : SuperViewController
@property (strong, nonatomic) NSMutableArray *markers;
@property (strong, nonatomic) NSMutableArray *placeArray;
@property (strong, nonatomic) NSMutableArray *categoryArray;
@end
