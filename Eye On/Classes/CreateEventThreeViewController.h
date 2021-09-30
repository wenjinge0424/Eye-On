//
//  CreateEventThreeViewController.h
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"

@interface CreateEventThreeViewController : SuperViewController
@property (strong, nonatomic) PFObject *eventObject;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSMutableArray *qtyArray;
@end
