//
//  PlaceModel.h
//  DinDinSpins
//
//  Created by developer on 19/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaceModel : NSObject
@property (nonatomic) BOOL isParse;
@property (strong, nonatomic) NSString *placeId;
@property (strong, nonatomic) NSString *venueId;
@property (strong, nonatomic) NSString *imagUrl;
@property (strong, nonatomic) NSString *vicinity;//address
@property (strong, nonatomic) NSString *placeName;
@property (nonatomic) double latitue;
@property (nonatomic) double longitude;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *emailAddress;
@property (strong, nonatomic) NSString *webSite;
@property (nonatomic, strong) NSString *reference;
@end
