//
//  SignUpThreeViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SignUpThreeViewController.h"
#import "SignUpFourViewController.h"

@interface SignUpThreeViewController ()<UITextFieldDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblTitleStepThree;
    IBOutlet UITextField *txtRepassword;
    IBOutlet UIButton *btnNext;
    
    IBOutlet UIButton *chMatch;
    IBOutlet UITextField *lblMatch;
    IBOutlet UIView *viewPassword;
}
@end

@implementation SignUpThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    txtRepassword.delegate = self;
    
    chMatch.selected = NO;
    [Util setCornerView:viewPassword];
    [Util setBorderView:viewPassword color:COLOR_WHITE width:MAIN_BORDER_WIDTH];
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
    lblTitleStepThree.text = LOCALIZATION(@"sign_up_three");
    txtRepassword.placeholder = LOCALIZATION(@"re_enter_password");
    [btnNext setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    lblMatch.text = LOCALIZATION(@"match_password");
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onNext:(id)sender {
    if (![self validate:YES]){
        return;
    }
    SignUpFourViewController *vc = (SignUpFourViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpFourViewController"];
    vc.user = self.user;
    [self.navigationController pushViewController:vc animated:YES];
}
- (BOOL) validate:(BOOL) isNext {
    if (![self.user.password isEqualToString:txtRepassword.text]){
        chMatch.selected = NO;
        if (isNext){
            [Util showAlertTitle:self title:LOCALIZATION(@"sign_up") message:LOCALIZATION(@"not_match_password") finish:^{
                [txtRepassword becomeFirstResponder];
            }];
        } else {
            
        }
        return NO;
    }
    chMatch.selected = YES;
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
- (void) textFieldDidEndEditing:(UITextField *)textField {
    txtRepassword.text = [Util trim:txtRepassword.text];
    [self validate:NO];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    txtRepassword.text = @"";
    chMatch.selected = NO;
}

@end
