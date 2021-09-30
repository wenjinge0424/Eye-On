//
//  SearchModel.h
//  Eye On
//
//  Created by developer on 21/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchModel : NSObject
@property (assign) BOOL isHereNow;
@property (assign) BOOL isPlanning;
@property (assign) BOOL isActive;
@property (assign) BOOL isComplete;
@property (strong, nonatomic) NSString *searchName;
@property (assign) NSInteger distance;
@property (strong, nonatomic) NSString *searchCity;
@property (strong, nonatomic) NSDate *dateFrom;
@property (strong, nonatomic) NSDate *dateTo;
@end
