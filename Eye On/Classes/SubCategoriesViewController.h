//
//  SubCategoriesViewController.h
//  Eye On
//
//  Created by developer on 18/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"

@interface SubCategoriesViewController : SuperViewController
@property (strong, nonatomic) NSMutableArray *mainCategory;

enum {
    TAG_RESTAURANT = 1,
    TAG_MUSIC,
    TAG_BARS,
    TAG_SPORT,
    TAG_CAFE,
    TAG_HOTEL,
    TAG_NETWORK,
    TAG_CLUBS
};

enum {
    SUB_COUNT_RESTAURANT = 19,
    SUB_COUNT_MUSIC = 14,
    SUB_COUNT_BARS = 15,
    SUB_COUNT_SPORT = 10,
    SUB_COUNT_CAFE = 0,
    SUB_COUNT_HOTEL = 0,
    SUB_COUNT_NETWORK = 7,
    SUB_COUNT_CLUBS = 0
};

@end
