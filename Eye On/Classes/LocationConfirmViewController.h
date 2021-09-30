//
//  LocationConfirmViewController.h
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

@import GooglePlaces;
#import "SuperViewController.h"

@interface LocationConfirmViewController : SuperViewController
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) NSObject *place;
@property (strong, nonatomic) PFObject *venueObject;
@end
