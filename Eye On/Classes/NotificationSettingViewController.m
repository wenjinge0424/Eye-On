//
//  NotificationSettingViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "NotificationSettingViewController.h"

@interface NotificationSettingViewController ()
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblHeader;
    
    IBOutlet UILabel *lblAll;
    IBOutlet UILabel *lblAttending;
    IBOutlet UILabel *lblAllowArea;
    
    PFUser *me;
    IBOutlet UIButton *btnAll;
    IBOutlet UIButton *btnAttending;
    IBOutlet UIButton *btnArea;
}
@end

@implementation NotificationSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    me = [PFUser currentUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguage];
}

- (void) configureLanguage {
    lblTitle.text = APP_NAME;
    lblHeader.text = LOCALIZATION(@"notification_header");
    lblAll.text = LOCALIZATION(@"allow_all");
    lblAttending.text = LOCALIZATION(@"allow_attending");
    lblAllowArea.text = LOCALIZATION(@"allow_area");
}

- (void) viewDidAppear:(BOOL)animated {
    btnAll.selected = [me[PARSE_USER_IS_VENUE_FOLLOW] boolValue];
    btnAttending.selected = [me[PARSE_USER_IS_EVENT_ATTEND] boolValue];
    btnArea.selected = [me[PARSE_USER_IS_VENUE_AREA] boolValue];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCheck:(id)sender {
    UIButton *button = (UIButton *) sender;
    button.selected = !button.selected;
    
    me[PARSE_USER_IS_VENUE_FOLLOW] = btnAll.selected?@YES:@NO;
    me[PARSE_USER_IS_EVENT_ATTEND] = btnAttending.selected?@YES:@NO;
    me[PARSE_USER_IS_VENUE_AREA] = btnArea.selected?@YES:@NO;
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    [SVProgressHUD show];
    [me saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
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
