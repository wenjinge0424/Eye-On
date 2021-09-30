//
//  VenueViewController.h
//  Eye On
//
//  Created by developer on 12/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"
#import "PlaceModel.h"
#import "FourSquareKit.h"
@import GooglePlaces;

@interface VenueViewController : SuperViewController
@property (strong, nonatomic) PlaceModel *object;
@property (strong, nonatomic) UXRFourSquareNetworkingEngine *fourSquareEngine;
@end
