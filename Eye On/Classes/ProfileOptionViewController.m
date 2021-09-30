//
//  ProfileOptionViewController.m
//  Eye On
//
//  Created by developer on 24/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "ProfileOptionViewController.h"
#import "MyPaidProfileViewController.h"
#import "MyProfileViewController.h"

@interface ProfileOptionViewController ()

@end

@implementation ProfileOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_VENUE];
    [query whereKey:PARSE_VENUE_OWNER equalTo:[PFUser currentUser]];
    [query whereKey:PARSE_VENUE_AVAILABLE equalTo:@YES];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            if (objects.count == 0){
                MyProfileViewController *vc = (MyProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"MyProfileViewController"];
                [self.navigationController pushViewController:vc animated:nil];
            } else {
                MyPaidProfileViewController *vc = (MyPaidProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"MyPaidProfileViewController"];
                [self presentViewController:vc animated:NO completion:nil];
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

@end
