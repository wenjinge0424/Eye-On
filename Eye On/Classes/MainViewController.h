//
//  MainViewController.h
//  Eye On
//
//  Created by developer on 24/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"
#import "MFSideMenu.h"

typedef enum {
    TAB_SEARCH = 1,
    TAB_VENUES,
    TAB_MAP,
    TAB_CONNECTIONS,
    TAB_PROFILE
} TAB_INDEX;

@interface MainViewController : SuperViewController<UITabBarControllerDelegate>
+ (MainViewController *)getInstance;
- (void) showSideMenu;
- (void) pushViewController:(UIViewController *) viewController;
- (void) pushViewController:(UIViewController *)viewController animation:(BOOL) animate;
- (void) presentViewController:(UIViewController *) viewController;

// Setting
- (void) onCurrency;
- (void) onLanguage;
- (void) onSendFeedBack;
- (void) onAbout;
- (void) onTermsConditions;
- (void) onPrivacyPolicy;
- (void) onReview;
@end
