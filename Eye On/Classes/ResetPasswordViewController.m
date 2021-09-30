//
//  ResetPasswordViewController.m
//  Eye On
//
//  Created by developer on 04/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "SignUpOneViewController.h"

@interface ResetPasswordViewController ()<UITextFieldDelegate>
{
    IBOutlet UITextField *txtEmail;
    IBOutlet UIButton *btnSubmit;
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblHeader;
    IBOutlet UITextField *txtRegistered;
    IBOutlet UIButton *btnCheck;
    
    IBOutlet UIView *viewEmail;
}
@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    btnCheck.selected = NO;
    txtEmail.delegate = self;
    
    [Util setBorderView:viewEmail color:[UIColor whiteColor] width:0.5];
    [Util setCornerView:viewEmail];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguage];
}

- (void) configureLanguage {
    txtEmail.placeholder = LOCALIZATION(@"email");
    txtRegistered.text = LOCALIZATION(@"registered_email");
    [btnSubmit setTitle:LOCALIZATION(@"button_submit") forState:UIControlStateNormal];
    [lblTitle setText:LOCALIZATION(@"forgot_password")];
    [lblHeader setText:LOCALIZATION(@"enter_email")];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSubmit:(id)sender {
    if (!btnCheck.isSelected){
        [Util showAlertTitle:self title:LOCALIZATION(@"email") message:LOCALIZATION(@"invalid_entry") finish:^{
            [txtEmail becomeFirstResponder];
        }];
        return;
    }
    NSString *email = txtEmail.text;
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded,NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [Util showAlertTitle:self
                           title:LOCALIZATION(@"success")
                         message: LOCALIZATION(@"reset_email_sent")
                          finish:^(void) {
                              [self onBack:nil];
                          }];
        } else {
            NSString *errorString = [error localizedDescription];
            [Util showAlertTitle:self
                           title:LOCALIZATION(@"error")                         message:errorString
                          finish:^(void) {
                          }];
        }
    }];
}

- (void) checkEmailAddress:(NSString *) email {
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_USERNAME equalTo:email];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            if (objects.count>0){
                btnCheck.selected = YES;
            } else {
                btnCheck.selected = NO;
                NSString *msg = LOCALIZATION(@"msg_not_email_registered");
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                alert.customViewColor = MAIN_COLOR;
                alert.horizontalButtons = YES;
                [alert addButton:LOCALIZATION(@"try_again") actionBlock:^(void) {
                }];
                [alert addButton:LOCALIZATION(@"sign_up") actionBlock:^(void) {
                    SignUpOneViewController *vc = (SignUpOneViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpOneViewController"];
                    [self.navigationController pushViewController:vc animated:YES];
                }];
                [alert showError:LOCALIZATION(@"sign_up") subTitle:msg closeButtonTitle:nil duration:0.0f];
            }
        }
    }];
}

- (IBAction)onCheck:(id)sender {
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    if ([email length]==0){
        [Util showAlertTitle:self title:LOCALIZATION(@"email") message:LOCALIZATION(@"no email") finish:^{
            [txtEmail becomeFirstResponder];
        }];
        return;
    }
    if (![email isEmail]){
        [Util showAlertTitle:self title:LOCALIZATION(@"resetpwd") message:LOCALIZATION(@"invalid_entry") finish:^{
            [txtEmail becomeFirstResponder];
        }];
        return;
    }
    [self checkEmailAddress:email];
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
    btnCheck.selected = NO;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    textField.text = [Util trim:textField.text];
//    NSString *email = textField.text;
//    if (![email isEmail]){
//        return;
//    }
//    [self checkEmailAddress:email];
}
@end
