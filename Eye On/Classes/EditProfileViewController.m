//
//  EditProfileViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "EditProfileViewController.h"
#import "AIDatePickerController.h"
#import "LoginViewController.h"
#import "CircleImageView.h"
#import "ChangePasswordViewController.h"

@interface EditProfileViewController ()<CircleImageAddDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UITextField *txtFirstname;
    IBOutlet UITextField *txtLastName;
//    IBOutlet UITextField *txtBirthday;
    IBOutlet UITextField *txtContactNumber;
    IBOutlet UIButton *btnChangePassword;
    IBOutlet UIButton *btnDelect;
    
    NSDate *birthday;
    PFUser *me;
    AIDatePickerController *datePickerViewController;
    IBOutlet CircleImageView *imgAvatar;
    
    BOOL isAvailable;
    
    NSString *first_name;
    NSString *last_name;
    NSString *birth_day;
    NSString *phone_num;
    NSData *image_avatar;
}
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    me = [PFUser currentUser];
    
    txtFirstname.text = me[PARSE_USER_FIRST_NAME];
    txtLastName.text = me[PARSE_USER_LAST_NAME];
//    txtBirthday.text = [Util getExpireDateString:me[PARSE_USER_BIRTHDAY]];
    txtContactNumber.text = me[PARSE_USER_CONTACT_NUMBER];
    [Util setImage:imgAvatar imgFile:(PFFile *)me[PARSE_USER_AVATAR]];
    imgAvatar.delegate = self;
    
    first_name = txtFirstname.text;
    last_name = txtLastName.text;
//    birth_day = txtBirthday.text;
    phone_num = txtContactNumber.text;
    image_avatar = UIImagePNGRepresentation(imgAvatar.image);
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
    lblTitle.text = LOCALIZATION(@"edit_profile");
    txtFirstname.placeholder = LOCALIZATION(@"first_name");
    txtLastName.placeholder = LOCALIZATION(@"last_name");
//    txtBirthday.placeholder = LOCALIZATION(@"birthday");
    [btnChangePassword setTitle:LOCALIZATION(@"change_password") forState:UIControlStateNormal];
    [btnDelect setTitle:LOCALIZATION(@"delete_account") forState:UIControlStateNormal];
}

- (BOOL) valid {
    txtFirstname.text = [Util trim:txtFirstname.text];
    txtLastName.text = [Util trim:txtLastName.text];
    txtContactNumber.text = [Util trim:txtContactNumber.text];
    
    return YES;
}

- (BOOL) ischanged {
    NSString *value = txtFirstname.text;
    if (![value isEqualToString:first_name]){
        return YES;
    }
    value = txtLastName.text;
    if (![value isEqualToString:last_name]){
        return YES;
    }
//    value = txtBirthday.text;
//    if (![value isEqualToString:birth_day]){
//        return YES;
//    }
    value = txtContactNumber.text;
    if (![value isEqualToString:phone_num]){
        return YES;
    }
    NSData *data = UIImagePNGRepresentation(imgAvatar.image);
    if (![image_avatar isEqual:data]){
        return YES;
    }
    return NO;
}

- (IBAction)onBack:(id)sender {
    if ([self ischanged]){
        NSString *msg = LOCALIZATION(@"msg_save_required");
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:LOCALIZATION(@"yes") actionBlock:^(void) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert addButton:LOCALIZATION(@"no") actionBlock:^(void) {
            
        }];
        [alert showError:LOCALIZATION(@"") subTitle:msg closeButtonTitle:nil duration:0.0f];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSave:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    if (![self valid]){
        return;
    }
    if (![self ischanged]){
        [Util showAlertTitle:self title:LOCALIZATION(@"") message:LOCALIZATION(@"no_changed")];
        return;
    }
    NSString *firstName = txtFirstname.text;
    NSString *lastName = txtLastName.text;
    NSString *phone = txtContactNumber.text;
    if (firstName.length>0){
        me[PARSE_USER_FIRST_NAME] = firstName;
    }
    if (lastName.length>0){
        me[PARSE_USER_LAST_NAME] = lastName;
    }
    if (firstName.length>0 || lastName.length>0){
        me[PARSE_USER_FULL_NAME] = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    
    if (phone.length>0){
        me[PARSE_USER_CONTACT_NUMBER] = phone;
    }
    if (birthday){
//        me[PARSE_USER_BIRTHDAY] = birthday;
    }
    NSData *data = UIImagePNGRepresentation(imgAvatar.image);
    if (![image_avatar isEqual:data]){
        me[PARSE_USER_AVATAR] = [Util getUploadingImageFromImage:imgAvatar.image];
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [me saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)onBirthday:(id)sender {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [NSDate date];
    
    // Create an instance of the picker
    datePickerViewController = [AIDatePickerController pickerWithDate:date selectedBlock:^(NSDate *selectedDate) {
        [datePickerViewController dismissViewControllerAnimated:YES completion:nil];
        isAvailable = (date.year - selectedDate.year>AGE_LIMIT)?YES:NO;
        if (isAvailable){
//            txtBirthday.text = [dateFormatter stringFromDate:selectedDate];
            birthday = selectedDate;
        }
        else {
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"invalid_birthday")];
        }
    } cancelBlock:^{
        [datePickerViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    // Present it
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}

- (IBAction)onChangePassword:(id)sender {
    ChangePasswordViewController *vc = (ChangePasswordViewController *)[Util getUIViewControllerFromStoryBoard:@"ChangePasswordViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onDeleteAccount:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }

    NSString *msg = LOCALIZATION(@"msg_delete_account");
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:LOCALIZATION(@"yes") actionBlock:^(void) {
        SCLAlertView *confirm = [[SCLAlertView alloc] initWithNewWindow];
        confirm.customViewColor = MAIN_COLOR;
        confirm.horizontalButtons = YES;
        [confirm addButton:LOCALIZATION(@"confirm") actionBlock:^(void) {
            [SVProgressHUD show];
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation deleteInBackgroundWithBlock:^(BOOL succed, NSError *error){
                if (error){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"" message:[error localizedDescription]];
                } else {
                    [me deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                        if (succeed && !error){
                            [PFUser logOutInBackgroundWithBlock:^(NSError *error){
                                [SVProgressHUD dismiss];
                                if (error){
                                    [Util showAlertTitle:self title:LOCALIZATION(@"logout") message:[error localizedDescription]];
                                } else {
                                    [Util setLoginUserName:@"" password:@""];
                                    for (UIViewController *vc in [Util appDelegate].rootNavigationViewController.viewControllers){
                                        if ([vc isKindOfClass:[LoginViewController class]]){
                                            [[Util appDelegate].rootNavigationViewController popToViewController:vc animated:YES];
                                            break;
                                        }
                                    }
                                }
                            }];
                        } else {
                            [SVProgressHUD dismiss];
                            [Util showAlertTitle:self title:@"" message:[error localizedDescription]];
                        }
                    }];
                }
            }];
        }];
        [confirm addButton:LOCALIZATION(@"cancel") actionBlock:^(void){
            
        }];
        [confirm showQuestion:@"" subTitle:LOCALIZATION(@"msg_irreversible") closeButtonTitle:nil duration:0.0f];
    }];
    [alert addButton:LOCALIZATION(@"no") actionBlock:^(void) {
        
    }];
    [alert showError:LOCALIZATION(@"") subTitle:msg closeButtonTitle:nil duration:0.0f];
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
    if (![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
// CircleImage delegate
- (void) tapCircleImageView {
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
@end
