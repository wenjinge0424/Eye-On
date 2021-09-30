//
//  VenueViewController.m
//  Eye On
//
//  Created by developer on 12/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "VenueViewController.h"
#import <MessageUI/MessageUI.h>

@interface VenueViewController ()<MFMailComposeViewControllerDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UIImageView *imgVenue;
    IBOutlet UITextView *txtLocation;
    IBOutlet UIButton *btnSendInvite;
    IBOutlet UITextView *txtDescription;
    
    IBOutlet UILabel *lblShare;
    IBOutlet UILabel *lblShareDescription;
}
@end

@implementation VenueViewController
@synthesize object;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // load data
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanuguage];
}

- (void) configureLanuguage {
    [btnSendInvite setTitle:LOCALIZATION(@"send_invite") forState:UIControlStateNormal];
    txtDescription.text = LOCALIZATION(@"establish_description");
    lblShare.text = LOCALIZATION(@"share");
    lblShareDescription.text = [NSString stringWithFormat:@"(%@)", LOCALIZATION(@"share_description")];
    
}

- (void) loadData {
    lblTitle.text = self.object.placeName;
    txtLocation.text = self.object.vicinity;
    NSString *placeId = self.object.placeId;
    NSString *venueId = self.object.venueId;
    
    if (placeId.length > 0){
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
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
    } else if (venueId.length>0) {
//        [imgVenue setImageWithURL:[NSURL URLWithString:self.object.imagUrl]];
//        [SVProgressHUD dismiss];
        // get image from Foursquare
        [UXRFourSquareNetworkingEngine registerFourSquareEngineWithClientId:@"OJJ1FFB00PFLFDVSZSLTSONSWS2YLHD3NYUBK0Q0KWLSI04P" andSecret:@"05LHCABJLVXIYIZGYKKJHEWC4BHDRDZHVB33V5QGMZDM4IKG" andCallBackURL:@"dilly://foursquare"];
        self.fourSquareEngine = [UXRFourSquareNetworkingEngine sharedInstance];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self.fourSquareEngine getPhotosForRestaurantWithId:venueId
                                        withCompletionBlock:^(NSArray *photos) {
                                            if (photos.count > 0){
                                                UXRFourSquarePhotoModel *photoModel = (UXRFourSquarePhotoModel *)photos[0];
                                                // Download the image to your image view
                                                NSURL *fullPhotoURL = [photoModel fullPhotoURL];
                                                [imgVenue setImageWithURL:fullPhotoURL];
                                            }
                                            [SVProgressHUD dismiss];
                                        } failureBlock:^(NSError *error) {
                                            [SVProgressHUD dismiss];
                                            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                                        }];
    }
}

- (void) loadPhoto:(GMSPlacePhotoMetadata *) data {
    [[GMSPlacesClient sharedClient] loadPlacePhoto:data callback:^(UIImage *photo, NSError *error) {
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            imgVenue.image = photo;
        }
    }];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onReport:(id)sender {
//    [self onReport];
}

- (IBAction)onShare:(id)sender {
//    NSArray *activityItems = [NSArray arrayWithObjects:nil];
//    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
//    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    
//    [self presentViewController:activityViewController animated:YES completion:nil];
    NSString *msg = [NSString stringWithFormat:@"Hi! I'm using Dilly to find events. Check out %@ at %@ from Dilly", object.placeName];
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"share_email") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self sendMail:nil subject:nil message:msg];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"share_sms") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self sendSMS:nil subject:nil message:msg];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}

- (IBAction)onSendInvite:(id)sender {
    if (self.object.webSite.length > 0){
        [self openURL:self.object.webSite];
    } else {
        [self openMailBox];
    }
}

- (void) openMailBox {
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    if([MFMailComposeViewController canSendMail])
    {
        NSArray *toRecipients = [NSArray arrayWithObjects:self.object.emailAddress,nil];
        [controller setToRecipients:toRecipients];
        controller.mailComposeDelegate = self;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self presentViewController:controller animated:YES completion:^{
            [SVProgressHUD dismiss];
        }];
    } else {
        [Util showAlertTitle:self title:LOCALIZATION(@"send_invite") message:LOCALIZATION(@"err_send_email")];
    }
}

- (IBAction)onTranslate:(id)sender {
    [self translate:txtLocation.text];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MFMailcomposer
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {
            NSLog(@"mail sent");
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"invite_sent")];
        } else if (result == MFMailComposeResultFailed){
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"invite_failed")];
            NSLog(@"mail failed");
        } else if (result == MFMailComposeResultSaved){
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"invite_saved")];
            NSLog(@"mail saved");
        } else if (result == MFMailComposeResultCancelled){
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"invite_cancelled")];
            NSLog(@"mail cancelled");
        }
    }];
}


@end
