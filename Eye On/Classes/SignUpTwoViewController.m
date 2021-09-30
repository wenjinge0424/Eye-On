//
//  SignUpTwoViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SignUpTwoViewController.h"
#import "SignUpThreeViewController.h"

@interface SignUpTwoViewController ()<UITextFieldDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UITextField *txtPassword;
    IBOutlet UIButton *btnNext;
    
    IBOutlet UILabel *lblStepTwo;
    IBOutlet UIView *viewEmail;
    
    // validation
    IBOutlet UIButton *chLength;
    IBOutlet UITextField *lblLength;
    IBOutlet UIButton *chUpper;
    IBOutlet UITextField *lblUpper;
    IBOutlet UIButton *chLower;
    IBOutlet UITextField *lblLower;
    IBOutlet UIButton *chNumber;
    IBOutlet UITextField *lblNumber;
    
}
@end

@implementation SignUpTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    txtPassword.delegate = self;
    [Util setBorderView:viewEmail color:COLOR_WHITE width:MAIN_BORDER_WIDTH];
    [Util setCornerView:viewEmail];
    
    [self initValidation];
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
    lblStepTwo.text = LOCALIZATION(@"sign_up_two");
    txtPassword.placeholder = LOCALIZATION(@"choose_password");
    [btnNext setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    
    lblLength.text = LOCALIZATION(@"password_length_validation");
    lblUpper.text = LOCALIZATION(@"password_upper_validation");
    lblLower.text = LOCALIZATION(@"password_lower_validation");
    lblNumber.text = LOCALIZATION(@"password_number_validation");
}

- (void) initValidation {
    chLength.selected = NO;
    chUpper.selected = NO;
    chLower.selected = NO;
    chNumber.selected = NO;
}

- (IBAction)onNext:(id)sender {
    if (![self validate:YES]){
        return;
    }
    self.user.password = txtPassword.text;
    SignUpThreeViewController *vc = (SignUpThreeViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpThreeViewController"];
    vc.user = self.user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL) validate:(BOOL) isNext {
    txtPassword.text = [Util trim:txtPassword.text];
    NSString *password = txtPassword.text;
    if (password.length < 6){
        if (isNext){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"short_password") finish:^{
                [txtPassword becomeFirstResponder];
            }];
        } else {
            chLength.selected = NO;
        }
        if (isNext)
            return NO;
    } else if (password.length > 30){
        if (isNext){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"long_password") finish:^{
                [txtPassword becomeFirstResponder];
            }];
        } else {
            
        }
        if (isNext)
            return NO;
    } else {
        chLength.selected = YES;
    }
    
    if (![Util isContainsUpperCase:password]){
        if (isNext){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_upper_case") finish:^{
                [txtPassword becomeFirstResponder];
            }];
        } else {
            chUpper.selected = NO;
        }
        if (isNext)
            return NO;
    } else {
        chUpper.selected = YES;
    }
    
    if (![Util isContainsLowerCase:password]){
        if (isNext){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_lower_case") finish:^{
                [txtPassword becomeFirstResponder];
            }];
        } else {
            chLower.selected = NO;
        }
        if (isNext)
            return NO;
    } else {
        chLower.selected = YES;
    }
    
    if (![Util isContainsNumber:password]){
        if (isNext){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_number") finish:^{
                [txtPassword becomeFirstResponder];
            }];
        } else {
            chNumber.selected = NO;
        }
        if (isNext)
            return NO;
    } else {
        chNumber.selected = YES;
    }
    
    return chLength.isSelected && chUpper.isSelected && chLower.isSelected && chNumber.isSelected;
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
    [self initValidation];
}
- (void) textFieldDidEndEditing:(UITextField *)textField {
    [self validate:NO];
}
@end
