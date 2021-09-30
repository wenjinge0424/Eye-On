//
//  SignUpFourViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SignUpFourViewController.h"
#import "CircleImageView.h"
#import "CategoryViewController.h"
#import "AIDatePickerController.h"

@interface SignUpFourViewController ()<CircleImageAddDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblTitleStepFour;
    IBOutlet CircleImageView *imgAvatar;
    IBOutlet UILabel *lblUploadPhoto;
    IBOutlet UILabel *lblOptional;
    IBOutlet UITextField *txtUsername;
//    IBOutlet UITextField *txtBirthday;
    IBOutlet UIButton *btnAllDone;
    AIDatePickerController *datePickerViewController;
    IBOutlet UIView *viewUsername;
    IBOutlet UIView *viewBirthday;
    IBOutlet UIButton *chNotInUse;
    IBOutlet UIButton *chAgeRectrict;
    IBOutlet UITextField *txtNotinUse;
    IBOutlet UITextField *txtAboveAge;
    
    BOOL isNotUsed;
    BOOL isAvailableAge;
    BOOL hadPhoto;
    
    NSDate *birthday;
}
@end

@implementation SignUpFourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    txtUsername.delegate = self;
    isNotUsed = NO;
    isAvailableAge = NO;
    btnAllDone.enabled = NO;
    imgAvatar.delegate = self;
    hadPhoto = NO;
    
    [Util setBorderView:imgAvatar color:COLOR_WHITE width:2*MAIN_BORDER_WIDTH ];
    [Util setBorderView:viewUsername color:COLOR_WHITE width:MAIN_BORDER_WIDTH];
    [Util setCornerView:viewUsername];
    [Util setBorderView:viewBirthday color:COLOR_WHITE width:MAIN_BORDER_WIDTH];
    [Util setCornerView:viewBirthday];
    
    chNotInUse.selected = NO;
    chAgeRectrict.selected = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguage];
}

- (void) configureLanguage {
    lblTitle.text = LOCALIZATION(@"sign_up");
    lblTitleStepFour.text = LOCALIZATION(@"sign_up_four");
    lblUploadPhoto.text = LOCALIZATION(@"upload_photo");
    lblOptional.text = [NSString stringWithFormat:@"(%@)", LOCALIZATION(@"optional")];
    txtUsername.placeholder = LOCALIZATION(@"choose_username");
//    txtBirthday.placeholder = LOCALIZATION(@"birthday");
    [btnAllDone setTitle:LOCALIZATION(@"all_done") forState:UIControlStateNormal];
    txtNotinUse.text = LOCALIZATION(@"not_in_use");
    txtAboveAge.text = LOCALIZATION(@"above_age");
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onDone:(id)sender {
    if (![self Validate]){
        return;
    }
    // sign up user
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    
    if (hadPhoto){
        UIImage *profileImage = [Util getUploadingImageFromImage:imgAvatar.image];
        NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
        self.user[PARSE_USER_AVATAR] = [PFFile fileWithData:imageData];
    }
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
//    self.user[PARSE_USER_BIRTHDAY] = birthday;
    self.user[PARSE_USER_OWN_USERNAME] = txtUsername.text;
    
    if (self.user[PARSE_USER_FACEBOOK_ID]){
        [self.user saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            } else {
                [Util setLoginUserName:self.user.username password:self.user.password];
                [Util showAlertTitle:self title:LOCALIZATION(@"sign_up") message:LOCALIZATION(@"sign_up_success") finish:^(void) {
                    CategoryViewController *vc = (CategoryViewController *)[Util getUIViewControllerFromStoryBoard:@"CategoryViewController"];
                    vc.isFromTutorial = YES;
                    vc.isFromMap = NO;
                    [self.navigationController pushViewController:vc animated:YES];
                }];
            }
        }];
        return;
    }
    
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [Util setLoginUserName:self.user.username password:self.user.password];
            
            [Util showAlertTitle:self title:LOCALIZATION(@"sign_up") message:LOCALIZATION(@"sign_up_success") finish:^(void) {
                CategoryViewController *vc = (CategoryViewController *)[Util getUIViewControllerFromStoryBoard:@"CategoryViewController"];
                vc.isFromTutorial = YES;
                vc.isFromMap = NO;
                [self.navigationController pushViewController:vc animated:YES];         
            }];
        } else {
            NSString *message = [error localizedDescription];
            [Util showAlertTitle:self title:LOCALIZATION(@"sign_up") message:message];
        }
    }];
}

- (BOOL) Validate {
    if (!isNotUsed){
        return NO;
    }
    if (!isAvailableAge){
        return NO;
    }
    
    return YES;
}

- (void) checkUsername:(NSString *) username {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_OWN_USERNAME equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription] finish:^{
                
            }];
        } else {
            if (objects.count > 0){ // registered username
                isNotUsed = NO;
                chNotInUse.selected = NO;
                btnAllDone.enabled = NO;
            } else {
                isNotUsed = YES;
                chNotInUse.selected = YES;
//                if (isAvailableAge){
//                    btnAllDone.enabled = YES;
//                } else {
//                    btnAllDone.enabled = NO;
//                }
                btnAllDone.enabled = YES;
            }
        }
    }];
}

- (IBAction)onBirthDay:(id)sender {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [NSDate date];
    
    // Create an instance of the picker
    datePickerViewController = [AIDatePickerController pickerWithDate:date selectedBlock:^(NSDate *selectedDate) {
//        txtBirthday.text = [dateFormatter stringFromDate:selectedDate];
        isAvailableAge = (date.year - selectedDate.year>18)?YES:NO;
        chAgeRectrict.selected = isAvailableAge;
        if (isAvailableAge && isNotUsed){
            btnAllDone.enabled = YES;
            birthday = selectedDate;
        } else {
            btnAllDone.enabled = NO;
        }
        [datePickerViewController dismissViewControllerAnimated:YES completion:nil];
    } cancelBlock:^{
        [datePickerViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    // Present it
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) tapCircleImageView { // tapped Avatar
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
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    hadPhoto = YES;
    [imgAvatar setImage:image];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    txtUsername.text = @"";
    if (textField == txtUsername){
        chNotInUse.selected = NO;
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (textField == txtUsername){
        txtUsername.text = [Util trim:txtUsername.text];
        [self checkUsername:txtUsername.text];
    }
}

@end
