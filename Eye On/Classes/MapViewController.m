//
//  MapViewController.m
//  Eye On
//
//  Created by developer on 24/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

@import Mapbox;
@import GoogleMaps;
#import "MapViewController.h"
#import "BIZPopupViewController.h"
#import "EventViewController.h"
#import "CategoryViewController.h"
#import "VenueViewController.h"

@interface MapViewController ()<MGLMapViewDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate>
{
    IBOutlet UIView *mapQuestView;
    
    MQMapView *map;
    IBOutlet GMSMapView *mapGoogleView;
    IBOutlet UIView *mapBaiduView;
    
    int map_type;
    CGRect originFrame;
    
    PFGeoPoint *meLocation;
    
    int distance_radius;
    IBOutlet UIPlaceHolderTextView *txtAddress;
}
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    map_type = -1;
    
    map = [[MQMapView alloc] init];
    map.delegate = self;
    
    mapGoogleView.camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:1];
    mapGoogleView.delegate = self;
    mapGoogleView.myLocationEnabled = YES;
    mapGoogleView.settings.myLocationButton = YES;
    
    distance_radius = DEFAULT_RADIUS; // kilometre
    
    [Util setBorderView:txtAddress color:[UIColor blackColor] width:0.5];
    txtAddress.placeholder = LOCALIZATION(@"type_address");
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(ReloadMap:) name:NOTIFICATION_CHANGED_CATEGORY object:nil];
    
    [self initData];
}

- (void) dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) ReloadMap:(NSNotification *) notif {
    distance_radius = DEFAULT_RADIUS;
    [self initData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (map_type == MAP_TYPE_MAPQUEST){
        map.mapType = MQMapTypeNormal;
        // add marker - in mapquest Marker is Annotation
        MGLPointAnnotation *sanFran = [[MGLPointAnnotation alloc] init];
        sanFran.coordinate = CLLocationCoordinate2DMake(37.7749, -122.4194);
        sanFran.title = @"San Francisco";
        sanFran.subtitle = @"Welcome to San Fran";
        [map addAnnotation:sanFran];
        [map setCenterCoordinate:sanFran.coordinate zoomLevel:10 animated:YES];
    }
}

- (void) viewDidLayoutSubviews {
    map.frame = mapQuestView.frame;
    [mapQuestView addSubview:map];
    
    originFrame = txtAddress.frame;
}

- (void) initData {
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied){
        
    } else {
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"gps_error")];
        return;
    }
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
//    [HttpAPI sendRequestWithURL:URL_CHECK_REGION paramDic:nil completionBlock:^(NSDictionary *result, NSError *error){
//        if (error){
//            [SVProgressHUD dismiss];
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
//            [self loadData];
//        }
//    }];
    map_type = MAP_TYPE_GOOGLE;
    mapGoogleView.hidden = NO;
    mapBaiduView.hidden = YES;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [self loadData];
}

- (IBAction)onMenu:(id)sender {
    [[MainViewController getInstance] showSideMenu];
}

- (IBAction)onCategory:(id)sender {
    CategoryViewController *vc = (CategoryViewController *)[Util getUIViewControllerFromStoryBoard:@"CategoryViewController"];
    vc.isFromTutorial = NO;
    vc.isFromMap = YES;
    [[MainViewController getInstance] pushViewController:vc];
}

- (void) onTapEvent:(PFObject *) object{
    CGFloat width = self.view.frame.size.width - 40;
    CGSize size = CGSizeMake(width, width * 4 / 3.0);
    EventViewController *vc = (EventViewController *)[Util getUIViewControllerFromStoryBoard:@"EventViewController"];
    vc.object = object;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:vc contentSize:size];
    [self presentViewController:popUp animated:YES completion:nil];
}

- (void) onTapVenue:(PlaceModel *) object {
    VenueViewController *vc = (VenueViewController *)[Util getUIViewControllerFromStoryBoard:@"VenueViewController"];
    vc.object = object;
    [[MainViewController getInstance] pushViewController:vc];
}

- (void) loadData {
    // query for Venue
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    // load data to Map
    if (map_type == MAP_TYPE_BAIDU){
        [self loadDataOnBaiduMap:data];
    } else if (map_type == MAP_TYPE_GOOGLE) {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *meLoaction, NSError *error){
            [Util getAddressFromLatitde:meLoaction.latitude Longitude:meLoaction.longitude complationBlock:^(NSMutableDictionary *address){
                if (address){
                    txtAddress.frame = originFrame;
                    txtAddress.text = address[@"address"];
                    CGFloat fixedWidth = txtAddress.frame.size.width;
                    CGSize newSize = [txtAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
                    CGRect newFrame = txtAddress.frame;
                    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
                    txtAddress.frame = newFrame;
                } else {
                    txtAddress.text = LOCALIZATION(@"unknown_address");
                }
            }];
            
            if (!error){
                meLocation = meLoaction;
                NSMutableArray *type = [Util getSearchKey];
                if (type.count>0){
                    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 type, @"categories",
                                                 [NSNumber numberWithDouble:meLoaction.latitude], @"latitude",
                                                 [NSNumber numberWithDouble:meLoaction.longitude], @"longitude",
                                                 nil];
#ifdef DEBUG
//                    data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                            type, @"categories",
//                            [NSNumber numberWithDouble:13.73292670735871], @"latitude",
//                            [NSNumber numberWithDouble:100.5649736870472], @"longitude",
//                            nil];
//                    meLocation.latitude = 13.73292670735871;
//                    meLocation.longitude = 100.5649736870472;
#endif
                    [PFCloud callFunctionInBackground:@"searchVenues" withParameters:data block:^(id object, NSError *error){
                        if (error){
                            [SVProgressHUD dismiss];
                            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                        } else {
                            NSMutableArray *data = [[NSMutableArray alloc] init];
                            [data addObjectsFromArray:[self getParsingData:object]];
                            PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_EVENT];
                            [query whereKey:PARSE_USER_LOCATION nearGeoPoint:meLocation withinKilometers:distance_radius];
                            if ([AppStateManager sharedInstance].categoryArray.count > 0){
                                [query whereKey:PARSE_EVENT_CATEGORY containedIn:[AppStateManager sharedInstance].categoryArray];
                            }
                            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                                [SVProgressHUD dismiss];
                                if (error){
                                    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                                } else {
                                    [data addObjectsFromArray:objects];
                                }
                                [self loadDataOnGoogleMap:data];
                            }];
                            
                        }
                    }];
                } else {
                    [SVProgressHUD dismiss];
                    
                    mapGoogleView.myLocationEnabled = YES;
//                    [CATransaction begin];
//                    [CATransaction setValue:[NSNumber numberWithFloat: 3] forKey:kCATransactionAnimationDuration];
                    
                    [mapGoogleView animateToCameraPosition:[GMSCameraPosition
                                                            cameraWithLatitude:meLocation.latitude
                                                            longitude:meLocation.longitude
                                                            zoom:10]];
//                    [CATransaction commit];
                    mapGoogleView.delegate = self;
                }
            } else {
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"gps_error")];
            }
        }];
    } else if (map_type == MAP_TYPE_MAPQUEST){
        
    }
}

- (void) loadDataLatitude:(double) latitude Longitude:(double) longitude {
    NSMutableArray *data = [[NSMutableArray alloc] init];
    // load data to Map
    if (map_type == MAP_TYPE_BAIDU){
        [self loadDataOnBaiduMap:data];
    } else if (map_type == MAP_TYPE_GOOGLE) {
                NSMutableArray *type = [Util getSearchKey];
                if (type.count>0){
                    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 type, @"categories",
                                                 [NSNumber numberWithDouble:latitude], @"latitude",
                                                 [NSNumber numberWithDouble:longitude], @"longitude",
                                                 nil];
                    
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                    [PFCloud callFunctionInBackground:@"searchVenues" withParameters:data block:^(id object, NSError *error){
                        if (error){
                            [SVProgressHUD dismiss];
                            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                        } else {
                            NSMutableArray *data = [[NSMutableArray alloc] init];
                            [data addObjectsFromArray:[self getParsingData:object latitude:latitude longitude:longitude]];
                            PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_EVENT];
                            [query whereKey:PARSE_USER_LOCATION nearGeoPoint:meLocation withinKilometers:distance_radius];
                            if ([AppStateManager sharedInstance].categoryArray.count > 0){
                                [query whereKey:PARSE_EVENT_CATEGORY containedIn:[AppStateManager sharedInstance].categoryArray];
                            }
                            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                                [SVProgressHUD dismiss];
                                if (error){
                                    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                                } else {
                                    [data addObjectsFromArray:objects];
                                }
                                [self loadDataOnGoogleMap:data aroundOfLatitude:latitude Longitude:longitude];
                            }];
                        }
                    }];
                }
    } else if (map_type == MAP_TYPE_MAPQUEST){
        
    }
}

- (void) loadDataOnGoogleMap:(NSMutableArray *) objects { // objects are Places
    [mapGoogleView clear];
    self.markers = [[NSMutableArray alloc] init];
    self.placeArray = [[NSMutableArray alloc] init];
    if (objects.count == 0){
        GMSMarker *maker = [[GMSMarker alloc] init];
        maker.position = CLLocationCoordinate2DMake(meLocation.latitude, meLocation.longitude);
        [self.markers addObject:maker];
        PlaceModel *model = [[PlaceModel alloc] init];
        [self.placeArray addObject:model];
        [self fitBounds];
    } else {
        for (int i=0;i<objects.count;i++){
            NSObject *obj = [objects objectAtIndex:i];
            if ([obj isKindOfClass:[PlaceModel class]]){
                PlaceModel *place = (PlaceModel *) obj;
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake(place.latitue, place.longitude);
                if (place.isParse){
                    marker.snippet = MARKER_BLUE;
                    marker.icon = [Util image:[UIImage imageNamed:MARKER_BLUE] scaledToSize:CGSizeMake(MARKER_SIZE_WIDTH, MARKER_BLUE_HEIGHT)];
                } else {
                    marker.snippet = MARKER_GREEN;
                    marker.icon = [Util image:[UIImage imageNamed:MARKER_GREEN] scaledToSize:CGSizeMake(MARKER_SIZE_WIDTH, MARKER_BLUE_HEIGHT)];
                }
                marker.map = mapGoogleView;
                [self.markers addObject:marker];
                [self.placeArray addObject:place];
            } else if ([obj isKindOfClass:[PFObject class]]) {
                PFObject *event = [objects objectAtIndex:i];
                GMSMarker *marker = [[GMSMarker alloc] init];
                PFObject *venue = event[PARSE_EVENT_VENUE];
                venue = [venue fetchIfNeeded];
                PFGeoPoint *location = venue[PARSE_VENUE_LOCATION];
                marker.position = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                marker.icon = [Util image:[UIImage imageNamed:MARKER_STAR] scaledToSize:CGSizeMake(MARKER_SIZE_WIDTH, MARKER_BLUE_HEIGHT)];
                marker.snippet = MARKER_STAR;
                marker.map = mapGoogleView;
                [self.markers addObject:marker];
                [self.placeArray addObject:event];
            }
        }
        // add me
        GMSMarker *maker = [[GMSMarker alloc] init];
        maker.position = CLLocationCoordinate2DMake(meLocation.latitude, meLocation.longitude);
        [self.markers addObject:maker];
        PlaceModel *model = [[PlaceModel alloc] init];
        [self.placeArray addObject:model];
        [self fitBounds];
    }
}

- (void) loadDataOnGoogleMap:(NSMutableArray *) objects aroundOfLatitude:(double)latitude Longitude:(double) longitude { // objects are Places
    [mapGoogleView clear];
    self.markers = [[NSMutableArray alloc] init];
    self.placeArray = [[NSMutableArray alloc] init];
    if (objects.count == 0){
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(latitude, longitude);
        marker.map = mapGoogleView;
    } else {
        for (int i=0;i<objects.count;i++){
            NSObject *obj = [objects objectAtIndex:i];
            if ([obj isKindOfClass:[PlaceModel class]]){
                PlaceModel *place = (PlaceModel *) obj;
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake(place.latitue, place.longitude);
                if (place.isParse){
                    marker.snippet = MARKER_BLUE;
                    marker.icon = [Util image:[UIImage imageNamed:MARKER_BLUE] scaledToSize:CGSizeMake(MARKER_SIZE_WIDTH, MARKER_BLUE_HEIGHT)];
                } else {
                    marker.snippet = MARKER_GREEN;
                    marker.icon = [Util image:[UIImage imageNamed:MARKER_GREEN] scaledToSize:CGSizeMake(MARKER_SIZE_WIDTH, MARKER_BLUE_HEIGHT)];
                }
                marker.map = mapGoogleView;
                [self.markers addObject:marker];
                [self.placeArray addObject:place];
            } else if ([obj isKindOfClass:[PFObject class]]) {
                PFObject *event = [objects objectAtIndex:i];
                GMSMarker *marker = [[GMSMarker alloc] init];
                PFObject *venue = event[PARSE_EVENT_VENUE];
                venue = [venue fetchIfNeeded];
                PFGeoPoint *location = venue[PARSE_VENUE_LOCATION];
                marker.position = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                marker.icon = [Util image:[UIImage imageNamed:MARKER_STAR] scaledToSize:CGSizeMake(MARKER_SIZE_WIDTH, MARKER_BLUE_HEIGHT)];
                marker.snippet = MARKER_STAR;
                marker.map = mapGoogleView;
                [self.markers addObject:marker];
                [self.placeArray addObject:event];
            }
        }
        // add center
        GMSMarker *maker = [[GMSMarker alloc] init];
        maker.position = CLLocationCoordinate2DMake(latitude, longitude);
        [self.markers addObject:maker];
        maker.map = mapGoogleView;
        PlaceModel *model = [[PlaceModel alloc] init];
        [self.placeArray addObject:model];
        [self fitBounds];
    }
}

- (void) loadDataOnBaiduMap:(NSMutableArray *) objects {
    if (objects.count == 0){
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *meLoaction, NSError *error){
            if (!error){
                
            } else {
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"gps_error")];
            }
        }];
        return;
    }
    
    // load markers on Map
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


// MapQuest Delegate
- (void)mapView:(MGLMapView *)mapView didSelectAnnotation:(id <MGLAnnotation>)annotation{
    // red
    [self onTapEvent:nil];
    // blue
    //    [self onTapVenue:nil];
}

// GoogleMap delegate
- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    NSInteger index = [self.markers indexOfObject:marker];
    if (self.markers.count == 0 || index == NSNotFound){
        return NO;
    }
    if ([marker.snippet isEqualToString:MARKER_BLUE]){
        PlaceModel *place = [self.placeArray objectAtIndex:index];
        [self onTapVenue:place];
    } else if ([marker.snippet isEqualToString:MARKER_STAR]){
        PFObject *obj = [self.placeArray objectAtIndex:index];
        [self onTapEvent:obj];
    } else if ([marker.snippet isEqualToString:MARKER_GREEN]) {
        PlaceModel *place = [self.placeArray objectAtIndex:index];
        [self onTapVenue:place];
    }
    return YES;
}

- (BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView{
//    distance_radius = 1.0;
    [self initData];
    return NO;
}

// Google Places Nearby Parsing
- (NSMutableArray *) getParsingData:(NSMutableArray *) jsonResult {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i=0;i<jsonResult.count;i++){
        NSMutableDictionary *dic = [jsonResult objectAtIndex:i];
        PlaceModel *item = [[PlaceModel alloc] init];
        NSDictionary *coordinate = dic[@"coordinates"];
        item.latitue = [coordinate[@"latitude"] doubleValue];
        item.longitude = [coordinate[@"longitude"] doubleValue];
        item.phoneNumber = dic[@"phone"];
        item.venueId = dic[@"venue_id"];
        item.imagUrl = dic[@"image_url"];
        item.placeId = dic[@"place_id"];
        int isparse = [dic[@"isParse"] intValue];
        item.isParse = (isparse == 1)?YES:NO;
        NSDictionary *location = dic[@"location"];
        item.vicinity = location[@"address1"];
        item.webSite = dic[@"url"];
        item.placeName = dic[@"name"];
        item.emailAddress = dic[@"email"];
        
        CLLocation *meLocation1 = [[CLLocation alloc] initWithLatitude:meLocation.latitude longitude:meLocation.longitude];
        CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:item.latitue longitude:item.longitude];
        CLLocationDistance distance = [meLocation1 distanceFromLocation:eventLocation];
        if (distance/1000 < distance_radius){
            [result addObject:item];
        }
        
    }
    return result;
}

- (NSMutableArray *) getParsingData:(NSMutableArray *) jsonResult latitude:(double)latitude longitude:(double) longitude{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i=0;i<jsonResult.count;i++){
        NSMutableDictionary *dic = [jsonResult objectAtIndex:i];
        PlaceModel *item = [[PlaceModel alloc] init];
        NSDictionary *coordinate = dic[@"coordinates"];
        item.latitue = [coordinate[@"latitude"] doubleValue];
        item.longitude = [coordinate[@"longitude"] doubleValue];
        item.phoneNumber = dic[@"phone"];
        item.imagUrl = dic[@"image_url"];
        item.venueId = dic[@"venue_id"];
        item.placeId = dic[@"place_id"];
        int isparse = [dic[@"isParse"] intValue];
        item.isParse = (isparse == 1)?YES:NO;
        NSDictionary *location = dic[@"location"];
        item.vicinity = location[@"address1"];
        item.webSite = dic[@"url"];
        item.placeName = dic[@"name"];
        item.emailAddress = dic[@"email"];
        
        CLLocation *meLocation1 = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:item.latitue longitude:item.longitude];
        CLLocationDistance distance = [meLocation1 distanceFromLocation:eventLocation];
        if (distance/1000 < distance_radius){
            [result addObject:item];
        }
        
    }
    return result;
}

// Google Map fit bounds
- (void)fitBounds {
    if ([self.markers count] == 0)
        return;
    
    CLLocationCoordinate2D firstPos = ((GMSMarker *)self.markers.firstObject).position;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:firstPos coordinate:firstPos];
    for (GMSMarker *marker in self.markers) {
        bounds = [bounds includingCoordinate:marker.position];
    }
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:50.0f];
    
//    [CATransaction begin];
//    [CATransaction setValue:[NSNumber numberWithFloat: 3] forKey:kCATransactionAnimationDuration];
    [mapGoogleView animateWithCameraUpdate:update];
//    [CATransaction commit];
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
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:place.coordinate zoom:10];
//    [CATransaction begin];
//    [CATransaction setValue:[NSNumber numberWithFloat: 3] forKey:kCATransactionAnimationDuration];
    [mapGoogleView animateWithCameraUpdate:updatedCamera];
//    [CATransaction commit];
    mapGoogleView.camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude zoom:10];
    
    [self loadDataLatitude:place.coordinate.latitude Longitude:place.coordinate.longitude];
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
