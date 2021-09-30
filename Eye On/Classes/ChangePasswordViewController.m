//
//  ChangePasswordViewController.m
//  Eye On
//
//  Created by developer on 23/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "CircleImageView.h"

@interface ChangePasswordViewController ()
{
    IBOutlet UILabel *lblTitle;
    IBOutlet CircleImageView *imgAvatar;
    
    IBOutlet UITextField *txtCurrentPassword;
    IBOutlet UITextField *txtNewPassword;
    IBOutlet UITextField *txtConfirmPassword;
    IBOutlet UIButton *btnChange;
    
    PFUser *me;
}
@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    me = [PFUser currentUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lblTitle.text = LOCALIZATION(@"change_pwd");
    [btnChange setTitle:LOCALIZATION(@"change_password") forState:UIControlStateNormal];
    txtCurrentPassword.placeholder = LOCALIZATION(@"current_password");
    txtNewPassword.placeholder = LOCALIZATION(@"new_password");
    txtConfirmPassword.placeholder = LOCALIZATION(@"confirm_password");
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onChange:(id)sender {
    txtCurrentPassword.text = [Util trim:txtCurrentPassword.text];
    txtNewPassword.text = [Util trim:txtNewPassword.text];
    txtConfirmPassword.text = [Util trim:txtConfirmPassword.text];
    NSString *password = txtCurrentPassword.text;
    NSString *newPwd = txtNewPassword.text;
    NSString *confirmPwd = txtConfirmPassword.text;
    if (password.length == 0){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_password") finish:^{
            [txtCurrentPassword becomeFirstResponder];
        }];
        return;
    }
    if (newPwd.length == 0){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_password") finish:^{
            [txtCurrentPassword becomeFirstResponder];
        }];
        return;
    }
    if (confirmPwd.length == 0){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_password") finish:^{
            [txtCurrentPassword becomeFirstResponder];
        }];
        return;
    }
    if (![[Util getLoginUserPassword] isEqualToString:password]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"incorrect_password") finish:^{
            [txtCurrentPassword becomeFirstResponder];
        }];
        return;
    }
    if (![newPwd isEqualToString:confirmPwd]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"not_match_password") finish:^{
            [txtCurrentPassword becomeFirstResponder];
        }];
        return;
    }
    if (![Util isContainsUpperCase:newPwd]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_upper_case") finish:^{
            [txtNewPassword becomeFirstResponder];
        }];
        return;
    }
    if (![Util isContainsNumber:newPwd]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_lower_case") finish:^{
            [txtNewPassword becomeFirstResponder];
        }];
        return;
    }
    if (![Util isContainsLowerCase:newPwd]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_number") finish:^{
            [txtNewPassword becomeFirstResponder];
        }];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [me saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription] finish:nil];
        } else {
            me.password = newPwd;
            [Util setLoginUserName:[Util getLoginUserPassword] password:newPwd];
            [self onBack:nil];
        }
    }];
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
