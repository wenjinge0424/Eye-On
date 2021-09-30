//
//  ChoosePlaneViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "ChoosePlaneViewController.h"
#import "RegisterVenueOneViewController.h"
#import "MainViewController.h"
#import "StripeRest.h"
#import "StripeConnectionViewController.h"
#import "MyPaymentViewController.h"

@interface ChoosePlaneViewController ()
{
    IBOutlet UILabel *lblTitle;
 
    NSMutableArray *priceArray;
}
@end

@implementation ChoosePlaneViewController

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
    [self configureLanguage];
}

- (void) configureLanguage {
    lblTitle.text = LOCALIZATION(@"choose_plan");
}
- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onOneTime:(id)sender {
    [self gotoNext:PLAN_ONE_TIME];
}

- (IBAction)onMonthly:(id)sender {
    [self gotoNext:PLAN_MONTHLY];
}

- (IBAction)onYearly:(id)sender {
    [self gotoNext:PLAN_YEARLY];
}

- (void) gotoNext:(NSInteger) plan {
    RegisterVenueOneViewController *vc = (RegisterVenueOneViewController *)[Util getUIViewControllerFromStoryBoard:@"RegisterVenueOneViewController"];
    PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_VENUE];
    obj[PARSE_VENUE_PLAN] = [NSNumber numberWithInteger:plan];
    vc.venueObject = obj;
    [self.navigationController pushViewController:vc animated:YES];
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
