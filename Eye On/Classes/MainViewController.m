//
//  MainViewController.m
//  Eye On
//
//  Created by developer on 24/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "MainViewController.h"
#import "TabbarViewController.h"
#import "MapViewController.h"
#import "ProfileOptionViewController.h"
#import "SplashViewController.h"
#import "CategoryViewController.h"
#import "InformViewController.h"
#import "CustomNavigationController.h"
#import "ChooseLanguageViewController.h"
#import "CurrencyViewController.h"

static MainViewController *_sharedViewController = nil;

@interface MainViewController ()
{
    IBOutlet UIView *containerView;
    
    TabbarViewController *tabbarController;
    NSInteger currentTabIndex;
    
    
    IBOutlet UIButton *btnSearch;
    IBOutlet UIButton *btnFollows;
    IBOutlet UIButton *btnMap;
    IBOutlet UIButton *btnConnections;
    IBOutlet UIButton *btnProfile;
}
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sharedViewController = self;
    
    tabbarController.delegate = self;
    currentTabIndex = TAB_MAP - 1; // goto MAP view
    [tabbarController setSelectedIndex:currentTabIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (MainViewController *)getInstance {
    return _sharedViewController;
}

- (IBAction)selectTab:(id)sender {
//    NSMutableArray *list = [NSMutableArray arrayWithObjects:@"bars", @"french", nil];
//    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                 list, @"categories",
//                                 [NSNumber numberWithDouble:40.7303429], @"latitude",
//                                 [NSNumber numberWithDouble:-73.9910126], @"longitude",
//                                 nil];
//    [PFCloud callFunctionInBackground:@"searchYelp" withParameters:data block:^(id object, NSError *error){
//        NSLog(@"sfs");
//    }];
//    return;
    NSInteger tag = [sender tag];
    PFUser *me = [PFUser currentUser];
    if (!me){
        for (UIViewController *vc in [Util appDelegate].rootNavigationViewController.viewControllers){
            if ([vc isKindOfClass:[SplashViewController class]]){
                [[Util appDelegate].rootNavigationViewController popToViewController:vc animated:YES];
                break;
            }
        }
        return;
    }
    currentTabIndex = tag - 1;
    if (tag == TAB_SEARCH || tag == TAB_VENUES || tag == TAB_MAP || tag == TAB_CONNECTIONS ){
        [tabbarController setSelectedIndex:currentTabIndex];
    } else if (tag == TAB_PROFILE) {
        [tabbarController setSelectedIndex:currentTabIndex];
    }
    if (tag == TAB_MAP){
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHANGED_CATEGORY object:nil];
    }
    [self selectTabButton:tag];
}

- (void) selectTabButton:(NSInteger)tag {
    btnSearch.selected = NO;
    btnFollows.selected = NO;
    btnMap.selected = NO;
    btnConnections.selected = NO;
    btnProfile.selected = NO;
    switch (tag) {
        case TAB_SEARCH:
            btnSearch.selected = YES;
            break;
        case TAB_VENUES:
            btnFollows.selected = YES;
            break;
        case TAB_CONNECTIONS:
            btnConnections.selected = YES;
            break;
        case TAB_PROFILE:
            btnProfile.selected = YES;
            break;
        default:
            btnMap.selected = YES;
            break;
    }
}

- (void) pushViewController:(UIViewController *)viewController {
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void) pushViewController:(UIViewController *)viewController animation:(BOOL) animate {
    [self.navigationController pushViewController:viewController animated:NO];
}

- (void) presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:^(void){
        
    }];
}

- (void) showSideMenu {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}

- (void) onCurrency {
    CurrencyViewController *vc = (CurrencyViewController *)[Util getUIViewControllerFromStoryBoard:@"CurrencyViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    [self showSideMenu];
}

- (void) onLanguage {
    ChooseLanguageViewController *vc = (ChooseLanguageViewController *)[Util getUIViewControllerFromStoryBoard:@"ChooseLanguageViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    [self showSideMenu];
}

- (void) onSendFeedBack {
    [self sendMail:nil subject:nil message:nil];
    [self showSideMenu];
}

- (void) onAbout {
    [self gotoInformScene:INFORM_ABOUT];
}

- (void) onTermsConditions {
    [self gotoInformScene:INFORM_TERMS];
}

- (void) onPrivacyPolicy {
    [self gotoInformScene:INFORM_PRIVACY];
}

- (void) gotoInformScene:(int) type {
    InformViewController *vc = (InformViewController *)[Util getUIViewControllerFromStoryBoard:@"InformViewController"];
    vc.type = type;
    [self.navigationController pushViewController:vc animated:YES];
    [self showSideMenu];
}

- (void) onReview {
    [self showSideMenu];
    NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
    str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str];
    str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
    
    // Here is the app id from itunesconnect
    str = [NSString stringWithFormat:@"%@1028498728", str];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"]) {
        tabbarController = segue.destinationViewController;
        [tabbarController setHidesBottomBarWhenPushed:YES];
    }
}

#pragma mark - TabbarViewController delegate
- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == TAB_MAP){
        UINavigationController *navController = (UINavigationController *)viewController;
        [navController popToRootViewControllerAnimated:YES];
    }
}
@end
