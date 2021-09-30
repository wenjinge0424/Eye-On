//
//  AppDelegate.h
//  Eye On
//
//  Created by developer on 23/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MFSideMenu.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import "PFFacebookUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKApplicationDelegate.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AudioToolbox/AudioToolbox.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLPlacemark *currentLocationPlacemark;
@property (strong, nonatomic) UINavigationController *rootNavigationViewController;

@end

