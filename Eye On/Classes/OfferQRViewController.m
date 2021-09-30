//
//  OfferQRViewController.m
//  Eye On
//
//  Created by developer on 19/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "OfferQRViewController.h"
#import "UIImage+MDQRCode.h"

@interface OfferQRViewController ()
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblSubtitle;
    
    IBOutlet UIImageView *imgQR;
}
@end

@implementation OfferQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.object fetchIfNeeded];
    lblSubtitle.text = self.object[PARSE_EVENT_NAME];
    [self loadQR];
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
    lblTitle.text = LOCALIZATION(@"view_offer");
}

- (void) loadQR {
    NSString *data = self.object[PARSE_EVENT_NAME];
    [imgQR setImage:[UIImage mdQRCodeForString:data size:imgQR.bounds.size.width fillColor:[UIColor blackColor]]];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onReport:(id)sender {
    [self onReport:self.object type:REPORT_TYPE_EVENT];
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
