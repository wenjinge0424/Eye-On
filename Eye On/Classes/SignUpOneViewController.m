//
//  SignUpOneViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SignUpOneViewController.h"
#import "SignUpTwoViewController.h"

@interface SignUpOneViewController ()<UITextFieldDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblStepTitle;
    IBOutlet UITextField *txtEmail;
    IBOutlet UIButton *btnNext;
    
    BOOL validEmail, notUsedEmail;
    IBOutlet UITextField *txtValidEmail;
    IBOutlet UITextField *txtNotInUse;
    IBOutlet UIButton *chValidEmail;
    IBOutlet UIButton *chNotUseEmail;
    IBOutlet UIView *viewEmail;
}
@end

@implementation SignUpOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    txtEmail.delegate = self;
    validEmail = NO;
    notUsedEmail = NO;
    
    chNotUseEmail.selected = NO;
    chValidEmail.selected = NO;
    
    [Util setCornerView:viewEmail];
    [Util setBorderView:viewEmail color:COLOR_WHITE width:MAIN_BORDER_WIDTH];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // configure Lanuage
    lblTitle.text = LOCALIZATION(@"sign_up");
    lblStepTitle.text = LOCALIZATION(@"sign_up_one");
    txtEmail.placeholder = LOCALIZATION(@"enter_email");
    [btnNext setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    txtValidEmail.text = LOCALIZATION(@"valid_email");
    txtNotInUse.text = LOCALIZATION(@"not_in_use");
}

- (IBAction)onNext:(id)sender {
    if (!validEmail){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"invalid_email") finish:^{
            [txtEmail becomeFirstResponder];
        }];
        return;
    }
    if (!notUsedEmail){
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:LOCALIZATION(@"button_login") actionBlock:^(void) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert addButton:LOCALIZATION(@"try_again") actionBlock:^(void) {
            
        }];
        [alert showError:LOCALIZATION(@"error") subTitle:LOCALIZATION(@"registered_email") closeButtonTitle:nil duration:0.0f];
        
        return;
    }
    SignUpTwoViewController *vc = (SignUpTwoViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpTwoViewController"];
    PFUser *user = [PFUser user];
    user.email = txtEmail.text;
    user.username = txtEmail.text;
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) checkEmailUse:(NSString *)email {
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_USERNAME equalTo:email];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            if (objects.count>0){
                // this email is already used
                notUsedEmail = NO;
                chNotUseEmail.selected = NO;
            } else {
                // we can use this email
                notUsedEmail = YES;
                chNotUseEmail.selected = YES;
            }
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
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = @"";
    chValidEmail.selected = NO;
    chNotUseEmail.selected = NO;
    validEmail = NO;
    notUsedEmail = NO;
}
- (void) textFieldDidEndEditing:(UITextField *)textField {
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    if (email.length == 0){
        chNotUseEmail.selected = NO;
        return;
    }
    if (![email isEmail]) {
        validEmail = NO;
        return;
    }
    validEmail = YES;
    chValidEmail.selected = YES;
    [self checkEmailUse:email];
}
@end
