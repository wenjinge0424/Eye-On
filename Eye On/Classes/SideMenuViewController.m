//
//  SideMenuViewController.m
//  Eye On
//
//  Created by developer on 26/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SideMenuViewController.h"
#import "NotificationSettingViewController.h"
#import "MainViewController.h"

@interface SideMenuViewController ()
{
    IBOutlet UILabel *lblNotifications;
    IBOutlet UILabel *lblCurrency;
    IBOutlet UILabel *lblLanguage;
    IBOutlet UILabel *lblSendFeedback;
    IBOutlet UILabel *lblAbout;
    IBOutlet UILabel *lblTermsConditions;
    IBOutlet UILabel *lblPrivacy;
    IBOutlet UILabel *lblReview;
    
}
@end

@implementation SideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLanguageChangedNotification:)
                                                 name:kNotificationLanguageChanged
                                               object:nil];
}

- (void) receiveLanguageChangedNotification:(NSNotification *) notification
{
    if ([notification.name isEqualToString:kNotificationLanguageChanged])
    {
        [self configureLanguage];
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLanguageChanged object:nil];
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
    lblNotifications.text = LOCALIZATION(@"notifications");
    lblCurrency.text = LOCALIZATION(@"currency");
    lblLanguage.text = LOCALIZATION(@"language");
    lblSendFeedback.text = LOCALIZATION(@"sendfeedback");
    lblAbout.text = LOCALIZATION(@"about");
    lblTermsConditions.text = LOCALIZATION(@"termsconditions");
    lblPrivacy.text = LOCALIZATION(@"privacy");
    lblReview.text = LOCALIZATION(@"review_app");
}


- (IBAction)onNotifications:(id)sender {
    NotificationSettingViewController *vc = (NotificationSettingViewController *)[Util getUIViewControllerFromStoryBoard:@"NotificationSettingViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    [[MainViewController getInstance] showSideMenu];
}

- (IBAction)onCurrency:(id)sender {
    [[MainViewController getInstance] onCurrency];
}

- (IBAction)onLanguage:(id)sender {
    [[MainViewController getInstance] onLanguage];
}

- (IBAction)onSendFeedback:(id)sender {
    [[MainViewController getInstance] onSendFeedBack];
}

- (IBAction)onAbout:(id)sender {
    [[MainViewController getInstance] onAbout];
}

- (IBAction)onTerms:(id)sender {
    [[MainViewController getInstance] onTermsConditions];
}

- (IBAction)onPrivacy:(id)sender {
    [[MainViewController getInstance] onPrivacyPolicy];
}

- (IBAction)onReview:(id)sender {
    [[MainViewController getInstance] onReview];
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
