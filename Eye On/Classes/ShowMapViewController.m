//
//  ShowMapViewController.m
//  Eye On
//
//  Created by developer on 23/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "ShowMapViewController.h"

@interface ShowMapViewController ()
{
    IBOutlet UILabel *lblTitle;
    
    IBOutlet GMSMapView *mapViewgoogle;
}
@end

@implementation ShowMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // drwa route on Google
    [self loadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguage];
}

- (void) configureLanguage {
    lblTitle.text = LOCALIZATION(@"map");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadData {
    PFUser *me = [PFUser currentUser];
    PFGeoPoint *meLonLat = me[PARSE_USER_LOCATION];
    PFGeoPoint *eventLonLat = self.object[PARSE_EVENT_LOCATION];
    
    NSMutableArray *markers = [[NSMutableArray alloc] init];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(meLonLat.latitude, meLonLat.longitude);
    marker.map = mapViewgoogle;
    [markers addObject:marker];
    
    marker.position = CLLocationCoordinate2DMake(eventLonLat.latitude, eventLonLat.longitude);
    marker.icon = [Util image:[UIImage imageNamed:MARKER_STAR] scaledToSize:CGSizeMake(MARKER_SIZE_WIDTH, MARKER_STAR_HEIGHT)];
    marker.map = mapViewgoogle;
    [markers addObject:marker];
    
    GMSMutablePath *path = [GMSMutablePath path];
    [path addCoordinate:CLLocationCoordinate2DMake(meLonLat.latitude, meLonLat.longitude)];
    [path addCoordinate:CLLocationCoordinate2DMake(eventLonLat.latitude,eventLonLat.longitude)];
    
    GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
    rectangle.strokeWidth = 2.f;
    rectangle.map = mapViewgoogle;
 
    [self fitBounds:markers];
}

- (void)fitBounds:(NSMutableArray *) markers {
    if ([markers count] == 0)
        return;
    
    CLLocationCoordinate2D firstPos = ((GMSMarker *)markers.firstObject).position;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:firstPos coordinate:firstPos];
    for (GMSMarker *marker in markers) {
        bounds = [bounds includingCoordinate:marker.position];
    }
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:50.0f];
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat: 3] forKey:kCATransactionAnimationDuration];
    [mapViewgoogle animateWithCameraUpdate:update];
    [CATransaction commit];
}


- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
