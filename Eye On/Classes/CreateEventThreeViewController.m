//
//  CreateEventThreeViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "CreateEventThreeViewController.h"
#import "CategoryViewController.h"
#import "MainViewController.h"
#import "StripeRest.h"
#import "StripeConnectionViewController.h"

@interface CreateEventThreeViewController ()<UITextFieldDelegate>
{
    IBOutlet UISwitch *swithFreeEntry;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtContactNumber;
    
    IBOutlet UILabel *lblFreeEntry;
    IBOutlet UIButton *btnSubmit;
    IBOutlet UITextField *txtAmount;
    IBOutlet UILabel *lblEventCategory;
    IBOutlet UIPlaceHolderTextView *txtDescription;
    
}
@end

@implementation CreateEventThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setBorderView:txtDescription color:[UIColor lightTextColor] width:0.5];
    txtEmail.delegate = self;
    txtContactNumber.delegate = self;
    txtDescription.delegate = self;
    
    [Util setBorderView:txtDescription color:MAIN_BORDER_COLOR width:MAIN_BORDER_WIDTH];
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
    [btnSubmit setTitle:LOCALIZATION(@"button_submit") forState:UIControlStateNormal];
    lblFreeEntry.text = LOCALIZATION(@"free_entry");
    lblEventCategory.text = LOCALIZATION(@"event_category");
    txtEmail.placeholder = LOCALIZATION(@"email");
    txtContactNumber.placeholder = LOCALIZATION(@"contact_number");
    txtDescription.placeholder = LOCALIZATION(@"write_event_desc");
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSubmit:(id)sender {
    if (![self isValid]){
        return;
    }
    self.eventObject[PARSE_EVENT_CATEGORY] = [AppStateManager sharedInstance].category;
    [AppStateManager sharedInstance].category = @"";
    if (swithFreeEntry.isOn && txtAmount.text.length > 0){
        self.eventObject[PARSE_EVENT_AMOUNT] = [NSNumber numberWithFloat:[txtAmount.text floatValue]];
    }
    self.eventObject[PARSE_EVENT_IS_FREE] = swithFreeEntry.isOn?@YES:@NO;
    if (txtEmail.text.length > 0){
        self.eventObject[PARSE_EVENT_EMAIL] = txtEmail.text;
    }
    if (txtContactNumber.text.length > 0){
        self.eventObject[PARSE_EVENT_CONTACT_NUM] = txtContactNumber.text;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    PFUser *me = [PFUser currentUser];
    [me fetchInBackgroundWithBlock:^(PFObject *obj, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription] finish:nil];
        } else {
            [StripeRest getAccount:me[PARSE_USER_STRIPE_ACCOUNT_ID] completionBlock:^(id data, NSError *error) {
                if (error) {
                    [SVProgressHUD dismiss];
                    NSString *confirmStr = LOCALIZATION(@"connect_stripe_msg");
                    [Util showAlertTitle:self title:@"" message:confirmStr finish:^(void){
                        StripeConnectionViewController *vc = (StripeConnectionViewController *)[Util getUIViewControllerFromStoryBoard:@"StripeConnectionViewController"];
                        [self.navigationController pushViewController:vc animated:YES];
                    }];
                } else {
                    [self saveObject];
                }
            }];
        }
    }];
}

- (void) saveObject {
    [self.eventObject saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if (succeed && !error){
            if (_titleArray.count>0){
                [self saveOffers];
            } else {
                [SVProgressHUD dismiss];
                PFObject *venue = self.eventObject[PARSE_EVENT_VENUE];
                int type = [venue[PARSE_VENUE_PLAN] intValue];
                if (type == PLAN_ONE_TIME){
                    venue[PARSE_VENUE_AVAILABLE] = @NO;
                    [venue saveInBackground];
                    PFUser *me = [PFUser currentUser];
                    me[PARSE_USER_HAS_VENUE] = @NO;
                    [me saveInBackground];
                }
                [self gotoRootViewController];
            }
        } else {
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription] finish:^{
                
            }];
        }
    }];
}

- (void) saveOffers {
    [self.eventObject fetchInBackgroundWithBlock:^(PFObject *obj, NSError *error){
        if (!error){
            self.eventObject = obj;
            for (int i=0;i<_titleArray.count;i++){
                PFObject *offer = [PFObject objectWithClassName:PARSE_TABLE_OFFER];
                offer[PARSE_OFFER_TITLE] = [_titleArray objectAtIndex:i];
                NSString *qty = [_qtyArray objectAtIndex:i];
                offer[PARSE_OFFER_QUANTY] = [NSNumber numberWithInt:[qty intValue]] ;
                offer[PARSE_OFFER_EVENT] = self.eventObject;
                [offer saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                    if (succeed && i==_titleArray.count -1){
                        [SVProgressHUD dismiss];
                        [self gotoRootViewController];
                    }
                    if (!succeed){
                        [SVProgressHUD dismiss];
                        [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                    }
                }];
            }
        }
        
    }];
    
}

- (BOOL) isValid {
    txtEmail.text = [Util trim:txtEmail.text];
    txtContactNumber.text = [Util trim:txtContactNumber.text];
    txtDescription.text = [Util trim:txtDescription.text];
    NSString *email = txtEmail.text;
    if (email.length>0 && ![email isEmail]){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"invalid_email") finish:^{
            [txtEmail becomeFirstResponder];
        }];
        return NO;
    }
    if ([AppStateManager sharedInstance].category.length == 0){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_category") finish:^{
            [self onCategory:nil];
        }];
        return NO;
    }
    return YES;
}
- (IBAction)onCategory:(id)sender {
    CategoryViewController *vc = (CategoryViewController *)[Util getUIViewControllerFromStoryBoard:@"CategoryViewController"];
    vc.isFromMap = YES;
    vc.isFromTutorial = NO;
    [AppStateManager sharedInstance].isCreate = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)OnSwitchFree:(id)sender {
    txtAmount.enabled = !swithFreeEntry.isOn;
}

- (void) gotoRootViewController {
    for (UIViewController *vc in self.navigationController.viewControllers){
        if ([vc isKindOfClass:[MainViewController class]]){
            [self.navigationController popToViewController:vc animated:YES];
        }
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
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = @"";
}
@end
