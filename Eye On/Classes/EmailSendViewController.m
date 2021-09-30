//
//  EmailSendViewController.m
//  Eye On
//
//  Created by developer on 05/05/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "EmailSendViewController.h"

@interface EmailSendViewController ()
{
    IBOutlet UITextField *txtEmail;
    IBOutlet UIButton *btnSend;
    IBOutlet UIPlaceHolderTextView *txtContent;
    PFUser *me;
}
@end

@implementation EmailSendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util setBorderView:txtContent color:[UIColor grayColor] width:0.5];
    [Util setCornerView:txtContent];
    
    txtEmail.text = ADMIN_EMAIL;
    me = [PFUser currentUser];
    txtEmail.enabled = NO;
    
#ifdef DEBUG
    txtEmail.enabled = YES;
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureLanguage];
}

- (void) configureLanguage {
    txtEmail.placeholder = LOCALIZATION(@"email");
    txtContent.placeholder = LOCALIZATION(@"input_email_description");
    [btnSend setTitle:LOCALIZATION(@"send") forState:UIControlStateNormal];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onsend:(id)sender {
    if (![self isValid]){
        return;
    }
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          me.username, @"sender",
                          txtEmail.text, @"email",
                          txtContent.text, @"message",
                          @"Report", @"subject",
                          nil];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [PFCloud callFunctionInBackground:@"sendEmail" withParameters:data block:^(id reponse, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_REPORT];
            obj[PARSE_REPORT_SENDER] = me;
            obj[PARSE_REPORT_MESSAGE] = txtContent.text;
            if (self.type == REPORT_TYPE_EVENT){
                obj[PARSE_REPORT_EVENT] = self.object;
                obj[PARSE_REPORT_OWNER] = self.object[PARSE_EVENT_OWNER];
            } else if (self.type == REPORT_TYPE_VENUE){
                obj[PARSE_REPORT_VENUE] = self.object;
                obj[PARSE_REPORT_OWNER] = self.object[PARSE_VENUE_OWNER];
            }
            [obj saveInBackground];
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"email_sent") finish:^(void){
                [self onback:nil];
            }];
        }
    }];
}

- (BOOL) isValid {
    txtEmail.text = [Util trim:txtEmail.text];
    txtContent.text = [Util trim:txtContent.text];
    NSString *email = txtEmail.text;
    NSString *content = txtContent.text;
    if (![email isEmail]){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"invalid_email") finish:^(void){
            [txtEmail becomeFirstResponder];
        }];
        return NO;
    }
    if (email.length == 0){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"invalid_email") finish:^(void){
            [txtEmail becomeFirstResponder];
        }];
        return NO;
    }
    if (content.length == 0){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"input_email_description") finish:^(void){
            [txtContent becomeFirstResponder];
        }];
        return NO;
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

@end
