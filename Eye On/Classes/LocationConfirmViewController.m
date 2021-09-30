//
//  LocationConfirmViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "LocationConfirmViewController.h"
#import "RegisterVenueThreeViewController.h"
#import "PlaceModel.h"
@interface LocationConfirmViewController ()
{
    IBOutlet UILabel *lblHeader;
    IBOutlet UILabel *lblFooter;
    IBOutlet UIButton *btnYes;
    IBOutlet UIButton *btnNo;
    IBOutlet UILabel *lblPlaceName;
    IBOutlet UITextView *txtAddress;
    
    IBOutlet UIImageView *imgPlace;
}
@end

@implementation LocationConfirmViewController
@synthesize place;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadVenueLocation:place];
    if ([place isKindOfClass:[GMSPlace class]]){
        GMSPlace *place1 = (GMSPlace *) place;
        lblPlaceName.text = place1.name;
        txtAddress.text = place1.formattedAddress;
    } else {
        PlaceModel *place2 = (PlaceModel *)place;
        lblPlaceName.text = place2.placeName;
        txtAddress.text = place2.vicinity;
    }
    
    [Util setBorderView:btnYes color:[UIColor lightGrayColor] width:0.5];
    [Util setBorderView:btnNo color:[UIColor lightGrayColor] width:0.5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguage];
}

- (void) loadVenueLocation:(NSObject *)venuePlace{
    NSString *placeId = @"";
    if ([venuePlace isKindOfClass:[GMSPlace class]]){
        GMSPlace *place1 = (GMSPlace *) venuePlace;
        placeId = place1.placeID;
    } else {
        PlaceModel *place1 = (PlaceModel *) venuePlace;
        placeId = place1.placeId;
    }
    
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[GMSPlacesClient sharedClient] lookUpPhotosForPlaceID:placeId callback:^(GMSPlacePhotoMetadataList *_Nullable photos, NSError *_Nullable error) {
        if (error) {
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            GMSPlacePhotoMetadata *firstPhoto;
            if (photos.results.count > 0) {
                firstPhoto = photos.results.firstObject;
                [self loadPhoto:firstPhoto];
            } else {
                [SVProgressHUD dismiss];
                firstPhoto = nil;
            }
        }
    }];
}

- (void) loadPhoto:(GMSPlacePhotoMetadata *) data {
    [[GMSPlacesClient sharedClient] loadPlacePhoto:data callback:^(UIImage *photo, NSError *error) {
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            imgPlace.image = photo;
            NSData *imageData = UIImageJPEGRepresentation(photo, 0.8);
            self.venueObject[PARSE_VENUE_IMAGE] = [PFFile fileWithName:@"o.jpg" data:imageData];
        }
    }];
}

- (IBAction)onYes:(id)sender {
    if ([self.place isKindOfClass:[GMSPlace class]]){
        GMSPlace *place1 = (GMSPlace *) self.place;
        self.venueObject[PARSE_VENUE_LOCATION_NAME] = place1.name;
        self.venueObject[PARSE_VENUE_LOCATION_ADDRESS] = place1.formattedAddress;
        self.venueObject[PARSE_VENUE_LOCATION] = [PFGeoPoint geoPointWithLatitude:place1.coordinate.latitude longitude:place1.coordinate.longitude];
        self.venueObject[PARSE_VENUE_LOCATION_ID] = place1.placeID;
    } else {
        PlaceModel *place1 = (PlaceModel *) self.place;
        self.venueObject[PARSE_VENUE_LOCATION_NAME] = place1.placeName;
        self.venueObject[PARSE_VENUE_LOCATION_ADDRESS] = place1.vicinity;
        self.venueObject[PARSE_VENUE_LOCATION] = [PFGeoPoint geoPointWithLatitude:place1.latitue longitude:place1.longitude];
        self.venueObject[PARSE_VENUE_LOCATION_ID] = place1.placeId;
    }
    
    RegisterVenueThreeViewController *vc = (RegisterVenueThreeViewController *)[Util getUIViewControllerFromStoryBoard:@"RegisterVenueThreeViewController"];
    vc.venueObject = self.venueObject;
    [self.navigationController pushViewController:vc animated:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)onNO:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void) configureLanguage {
    lblHeader.text = LOCALIZATION(@"you_chosen");
    lblFooter.text = LOCALIZATION(@"is_establishment?");
    [btnYes setTitle:LOCALIZATION(@"yes") forState:UIControlStateNormal];
    [btnNo setTitle:LOCALIZATION(@"no") forState:UIControlStateNormal];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
