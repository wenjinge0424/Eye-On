//
//  AppDelegate.m
//  Eye On
//
//  Created by developer on 23/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

@import GoogleMaps;
@import GooglePlaces;
#import "AppDelegate.h"
#import "Config.h"

@interface AppDelegate ()<CLLocationManagerDelegate>
{
    CLLocationManager *manager;
    NSTimer *locationtimer;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Parse init
    [PFUser enableAutomaticUser];
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"";
        configuration.clientKey = @"";
        configuration.server = @"https://parse.dillyapp.com:20001/parse";
    }]];
    

    [PFUser enableRevocableSessionInBackground];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    PFInstallation *currentInstall = [PFInstallation currentInstallation];
    if (currentInstall) {
        currentInstall.badge = 0;
        [currentInstall saveInBackground];
    }
    
    // Push Notification
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    }
    
    // Google Map SDK
    [GMSServices provideAPIKey:@"
    [GMSPlacesClient provideAPIKey:@"
    
    // Google SignIn
    [GIDSignIn sharedInstance].clientID = @"522931204186-bfillpja5u0snr1pci3iapbpn9bdou7k.apps.googleusercontent.com";
    
    // Facebook
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

    [self CurrentLocationIdentifier];
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received Notification");
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
        
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1;
    } else { // active status
        application.applicationIconBadgeNumber = 0;
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        currentInstallation.badge = 0;
        [currentInstallation saveInBackground];
    }
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([self handleActionURL:url]) {
        return YES;
    }
    
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                          options:options];
}

- (BOOL)handleActionURL:(NSURL *)url {
    return NO;
}

-(void)CurrentLocationIdentifier
{
    manager = [CLLocationManager new];
    manager.delegate = self;
    manager.distanceFilter = kCLDistanceFilterNone;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [manager requestAlwaysAuthorization];
    [manager startUpdatingLocation];
    
    locationtimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updatelocation:) userInfo:nil repeats:YES];
}

- (void)updatelocation:(id)sender
{
    static CLLocation *old;
    
    CLLocation *current = self.currentLocation;
    PFUser *me = [PFUser currentUser];
    if (me) {
        if (old == nil || [current distanceFromLocation:old] >= 50.0) {
            old = current;
            me[PARSE_USER_LOCATION] = [PFGeoPoint geoPointWithLocation:current];
#ifdef DEBUG
            me[PARSE_USER_LOCATION] = [PFGeoPoint geoPointWithLatitude:40.7303429 longitude:-73.9910126];
#endif
            [me saveInBackground];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations objectAtIndex:0];
    //#ifdef DEBUG
    //    self.currentLocation = [[CLLocation alloc] initWithLatitude:29.8830527 longitude:-97.941793];
    //#endif
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             self.currentLocationPlacemark = [placemarks objectAtIndex:0];
         }
     }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
