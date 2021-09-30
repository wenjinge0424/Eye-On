//
//  RegisterVenueTwoViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

@import GooglePlaces;
#import "RegisterVenueTwoViewController.h"
#import "LocationConfirmViewController.h"
#import "BIZPopupViewController.h"
#import "PlaceModel.h"

@interface RegisterVenueTwoViewController ()<GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UITextView *txtHeaderTwo;
    IBOutlet UILabel *lblHeaderTitle;
    IBOutlet UIPlaceHolderTextView *txtAddress;
    
    IBOutlet GMSMapView *mapGoogleView;
    IBOutlet UIView *mapBaiduView;
    
    int map_type;
    CGRect originFrame;
    
    NSMutableArray *arrayPlaces;
    NSMutableArray *arrayMarkers;
    
    NSString *myPlaceId;
}
@end

@implementation RegisterVenueTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    
    arrayPlaces = [[NSMutableArray alloc] init];
    arrayMarkers = [[NSMutableArray alloc] init];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
//    [HttpAPI sendRequestWithURL:URL_CHECK_REGION paramDic:nil completionBlock:^(NSDictionary *result, NSError *error){
//        [SVProgressHUD dismiss];
//        if (error){
//            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
//        } else {
//            NSString *county = result[RESPONSE_PARAM_COUNTRY];
//            if ([county isEqualToString:COUNTRY_CHINA]){ // use Baidu map
//                map_type = MAP_TYPE_BAIDU;
//                mapBaiduView.hidden = NO;
//                mapGoogleView.hidden = YES;
//            } else { // use Google map
//                map_type = MAP_TYPE_GOOGLE;
//                mapGoogleView.hidden = NO;
//                mapBaiduView.hidden = YES;
//            }
//            [self loadMap];
//        }
//    }];
    
    map_type = MAP_TYPE_GOOGLE;
    mapGoogleView.hidden = NO;
    mapBaiduView.hidden = YES;
    [self loadMap];
    
    [Util setBorderView:txtAddress color:[UIColor blackColor] width:0.5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configureLanguage {
    lblTitle.text = LOCALIZATION(@"register_venue");
    lblHeaderTitle.text = LOCALIZATION(@"where_location");
    txtHeaderTwo.text = LOCALIZATION(@"register_header_two");
    txtAddress.placeholder = LOCALIZATION(@"type_address");
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureLanguage];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    txtAddress.text = @"";
    originFrame = txtAddress.frame;
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) loadMap {
    if (map_type == MAP_TYPE_GOOGLE){
        [self loadGoogleMap];
    } else if (map_type == MAP_TYPE_BAIDU){
        [self loadBaiduMap];
    }
}

- (void) loadGoogleMap {
    mapGoogleView.camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:1];
    mapGoogleView.delegate = self;
    mapGoogleView.myLocationEnabled = YES;
    mapGoogleView.settings.myLocationButton = YES;
    [SVProgressHUD show];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *meLocation, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"gps_error")];
        } else {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(meLocation.latitude, meLocation.longitude);
            marker.map = mapGoogleView;
            // set Current Location Name
            [Util getAddressFromLatitde:meLocation.latitude Longitude:meLocation.longitude complationBlock:^(NSMutableDictionary *address){
                if (address){
                    txtAddress.frame = originFrame;
                    txtAddress.text = address[@"address"];
                    CGFloat fixedWidth = txtAddress.frame.size.width;
                    CGSize newSize = [txtAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
                    CGRect newFrame = txtAddress.frame;
                    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
                    txtAddress.frame = newFrame;
                    myPlaceId = address[@"placeId"];
                    
                    PlaceModel *model = [[PlaceModel alloc] init];
                    model.placeId = myPlaceId;
                    model.placeName = [[txtAddress.text componentsSeparatedByString:@","] objectAtIndex:0];
                    model.vicinity = txtAddress.text;
                    model.latitue = meLocation.latitude;
                    model.longitude = meLocation.longitude;
                    
                    [arrayMarkers addObject:marker];
                    [arrayPlaces addObject:model];
                } else {
                    txtAddress.text = LOCALIZATION(@"unknown_address");
                }
            }];
            
//            [CATransaction begin];
//            [CATransaction setValue:[NSNumber numberWithFloat: 3] forKey:kCATransactionAnimationDuration];
            
            [mapGoogleView animateToCameraPosition:[GMSCameraPosition
                                                    cameraWithLatitude:meLocation.latitude
                                                    longitude:meLocation.longitude
                                                    zoom:10]];
//            [CATransaction commit];
        }
    }];
}

- (void) loadBaiduMap {
    
}

- (IBAction)onAddress:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

- (void) gotoNextStep:(NSObject *) place {
    CGFloat width = self.view.frame.size.width - 20;
    CGSize size = CGSizeMake(width, width * 1.2);
    LocationConfirmViewController *vc = (LocationConfirmViewController *)[Util getUIViewControllerFromStoryBoard:@"LocationConfirmViewController"];
    vc.place = place;
    vc.venueObject = self.venueObject;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:vc contentSize:size];
    vc.navigationController = self.navigationController;
    [self presentViewController:popUp animated:YES completion:nil];
}

#pragma Google Map delegate
- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
}
- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    NSInteger index = [arrayMarkers indexOfObject:marker];
    if (arrayMarkers.count == 0 || index == NSNotFound){
        return NO;
    }
    
    NSObject *target = [arrayPlaces objectAtIndex:index];
    [self gotoNextStep:target];
    return YES;
}

#pragma Google Places delegate
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [viewController dismissViewControllerAnimated:viewController completion:nil];
    NSString *placeString = place.formattedAddress;
    txtAddress.frame = originFrame;
    txtAddress.text = placeString;
    CGFloat fixedWidth = txtAddress.frame.size.width;
    CGSize newSize = [txtAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = txtAddress.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    txtAddress.frame = newFrame;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
    marker.snippet = place.placeID;
    marker.map = mapGoogleView;
    
    if (![arrayPlaces containsObject:place]){
        [arrayPlaces addObject:place];
        [arrayMarkers addObject:marker];
    }
    
//    [CATransaction begin];
//    [CATransaction setValue:[NSNumber numberWithFloat: 3.0f] forKey:kCATransactionAnimationDuration];
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:place.coordinate zoom:10];
    [mapGoogleView animateWithCameraUpdate:updatedCamera];
//    [CATransaction commit];
    mapGoogleView.camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude zoom:10];
}
- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
    txtAddress.text = @"";
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    txtAddress.text = @"";
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
