//
//  RegisterVenueThreeViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "RegisterVenueThreeViewController.h"
#import "CreateEventOneViewController.h"
#import "StripeRest.h"
#import "StripeConnectionViewController.h"
#import "MyPaymentViewController.h"
#import "IQDropDownTextField.h"
#import "CountryListViewController.h"

@interface RegisterVenueThreeViewController ()<UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CountryListViewDelegate, IQDropDownTextFieldDelegate>
{
    
    IBOutlet UILabel *lblTitle;
    IBOutlet UITextView *txtHeader;
    IBOutlet UITextField *txtContactNumber;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtWebSite;
    IBOutlet UIPlaceHolderTextView *txtMessages;
    IBOutlet UIButton *btnUploadPhoto;
    IBOutlet UIButton *btnDone;
    NSMutableArray *priceArray;
    IBOutlet IQDropDownTextField *txtHourStart;
    IBOutlet IQDropDownTextField *txtHourEnd;
    
    UIImage *venueImage;
    IBOutlet UIButton *btnPhoneCode;
    NSString *phone_code;
}
@end

@implementation RegisterVenueThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util setBorderView:txtMessages color:[UIColor lightGrayColor] width:0.5];
    [Util setCornerView:txtMessages];
    
    txtContactNumber.delegate = self;
    txtEmail.delegate = self;
    txtWebSite.delegate = self;
    txtHourStart.dropDownMode = IQDropDownModeTimePicker;
    txtHourEnd.dropDownMode = IQDropDownModeTimePicker;
    txtHourStart.delegate = self;
    
    priceArray = [NSMutableArray arrayWithObjects:@"3.99", @"19.99", @"129.99", nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(PaySuccess:) name:NOTIFICATION_PAYSUCCESS object:nil];
    
    venueImage = nil;
    phone_code = @"+1";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) PaySuccess:(NSNotification *) notif {
    PFUser *me = [PFUser currentUser];
    self.venueObject[PARSE_VENUE_CONTACT_NUM] = [NSString stringWithFormat:@"%@ %@", phone_code, [Util trim:txtContactNumber.text]];
    self.venueObject[PARSE_VENUE_EMAIL] = [Util trim:txtEmail.text];
    self.venueObject[PARSE_VENUE_WEB_SITE] = [Util trim:txtWebSite.text];
    self.venueObject[PARSE_VENUE_OPERATING_HOURS] = [NSString stringWithFormat:@"%@ - %@", txtHourStart.selectedItem, txtHourEnd.selectedItem];
    self.venueObject[PARSE_VENUE_OWNER] = me;
    [SVProgressHUD showWithStatus:LOCALIZATION(@"saving") maskType:SVProgressHUDMaskTypeGradient];
    [self.venueObject saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (succeed && !error){
            int plan = [self.venueObject[PARSE_VENUE_PLAN] intValue];
            double price = [[priceArray objectAtIndex:plan] doubleValue];
            PFObject *history = [PFObject objectWithClassName:PARSE_TABLE_PAY_HISTORY];
            history[PARSE_PAYMENT_AMOUNT] = [NSNumber numberWithDouble:price];
            history[PARSE_PAYMENT_VENUE] = self.venueObject;
            history[PARSE_PAYMENT_DESCRIPTION] = @"plan";
            history[PARSE_PAYMENT_FROM_USER] = [PFUser currentUser];
            [history saveInBackground];
            
            me[PARSE_USER_HAS_VENUE] = @YES;
            [me saveInBackground];
            
            CreateEventOneViewController *vc = (CreateEventOneViewController *)[Util getUIViewControllerFromStoryBoard:@"CreateEventOneViewController"];
            vc.venueObeject = self.venueObject;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        }
    }];
}

- (void) dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:NOTIFICATION_PAYSUCCESS object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguage];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) configureLanguage {
    lblTitle.text = LOCALIZATION(@"register_venue");
    txtHeader.text = LOCALIZATION(@"register_header_three");
    txtContactNumber.placeholder = LOCALIZATION(@"contact_number");
    txtEmail.placeholder = LOCALIZATION(@"email_address");
    txtWebSite.placeholder = LOCALIZATION(@"website");
    txtMessages.placeholder = LOCALIZATION(@"leave_message");
    [btnDone setTitle:LOCALIZATION(@"done") forState:UIControlStateNormal];
    [btnUploadPhoto setTitle:LOCALIZATION(@"upload_photo") forState:UIControlStateNormal];
}

- (IBAction)onUploadPhoto:(id)sender {
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"camera") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onTakePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"gallery") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onChoosePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}

- (IBAction)onDone:(id)sender {

    if (![self validate]){
        return;
    }
    if (venueImage){
        NSData *imageData = UIImageJPEGRepresentation(venueImage, 0.8);
        self.venueObject[PARSE_VENUE_IMAGE] = [PFFile fileWithName:@"o.jpg" data:imageData];
    }
    [self onPay];
}

- (void) onPay {
    int plan = [self.venueObject[PARSE_VENUE_PLAN] intValue];
    double price = [[priceArray objectAtIndex:plan] doubleValue];
    NSString *amount = [NSString stringWithFormat:@"%d", (int)(price * 100)];
    
    MyPaymentViewController *vc = (MyPaymentViewController *)[Util getUIViewControllerFromStoryBoard:@"MyPaymentViewController"];
    PayModel *model = [[PayModel alloc] init];
    model.amount = amount;
    vc.payModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL) validate {
    txtContactNumber.text = [Util trim:txtContactNumber.text];
    txtEmail.text = [Util trim:txtEmail.text];
    txtWebSite.text = [Util trim:txtWebSite.text];
    txtMessages.text = [Util trim:txtMessages.text];
    txtEmail.text = [txtEmail.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    txtWebSite.text = [txtWebSite.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *contactNum = txtContactNumber.text;
    if (contactNum.length == 0){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_contact_num") finish:^{
            [txtContactNumber becomeFirstResponder];;
        }];
        return NO;
    }
    
    NSString *hourStart = txtHourStart.selectedItem;
    NSString *hourEnd = txtHourEnd.selectedItem;
    if (hourStart.length == 0 || hourEnd.length == 0){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_hours_num") finish:^{
            
        }];
        return NO;
    }
    
    NSString *email = txtEmail.text;
    if (email.length == 0){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_contact_num") finish:^{
            [txtEmail becomeFirstResponder];;
        }];
        return NO;
    }
    
    if (![email isEmail]){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"invalid_email") finish:^{
            [txtEmail becomeFirstResponder];;
        }];
        return NO;
    }
    
    NSString *website = txtWebSite.text;
    if (website.length == 0){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_website") finish:^{
            [txtWebSite becomeFirstResponder];;
        }];
        return NO;
    }

    NSString *messages = txtMessages.text;
    if (messages.length<1){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"short_message") finish:^{
            [txtMessages becomeFirstResponder];
        }];
        return NO;
    }
    if (messages.length>160){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"long_message") finish:^{
            [txtMessages becomeFirstResponder];
        }];
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = @"";
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    textView.text = @"";
}

- (void)onChoosePhoto:(id)sender {
    if (![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)onTakePhoto:(id)sender {
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    venueImage = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
//    if (![Util isPhotoAvaileble]){
//        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
//        return;
//    }
//    if (![Util isCameraAvailable]){
//        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
//        return;
//    }
}

- (IBAction)onGetPhoneCode:(id)sender {
    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    [self presentViewController:cv animated:YES completion:nil];
}

/* country code delegate */
- (void) didSelectCountry:(NSDictionary *)country{
//    [btnPhoneCode setTitle:[NSString stringWithFormat:@"%@ %@", country[@"code"], country[@"dial_code"]] forState:UIControlStateNormal];
    phone_code = country[@"dial_code"];
    [btnPhoneCode setTitle:phone_code forState:UIControlStateNormal];
}

- (void) textField:(IQDropDownTextField *)textField didSelectItem:(NSString *)item {
    if (textField == txtHourStart){
        txtHourEnd.selectedItem = txtHourStart.selectedItem;
    }
}

@end
