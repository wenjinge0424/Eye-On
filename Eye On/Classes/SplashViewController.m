//
//  SplashViewController.m
//  Eye On
//
//  Created by developer on 03/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SplashViewController.h"
#import "LoginViewController.h"
#import "ChooseLanguageViewController.h"
#import "PagerViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
#ifdef DEBUG
    [[Localisator sharedInstance] setLanguage:@"Thai_th"];
#endif
    [Util appDelegate].rootNavigationViewController = self.navigationController;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![Util isFirstUse]){
        PagerViewController *vc = (PagerViewController *)[Util getUIViewControllerFromStoryBoard:@"PagerViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        [Util setFirstUse:YES];
    } else {
        LoginViewController *vc = (LoginViewController *)[Util getUIViewControllerFromStoryBoard:@"LoginViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
