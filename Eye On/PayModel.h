//
//  PayModel.h
//  Eye On
//
//  Created by developer on 04/05/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayModel : NSObject
@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) NSString *amount;
@property (strong, nonatomic) NSString *description;
@end
