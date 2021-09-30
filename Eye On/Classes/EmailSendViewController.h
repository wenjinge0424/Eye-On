//
//  EmailSendViewController.h
//  Eye On
//
//  Created by developer on 05/05/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"

@interface EmailSendViewController : SuperViewController
@property (strong, nonatomic) PFObject *object;
@property (nonatomic) int type;
@end
