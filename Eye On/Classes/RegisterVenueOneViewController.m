//
//  RegisterVenueOneViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "RegisterVenueOneViewController.h"
#import "RegisterVenueTwoViewController.h"

@interface RegisterVenueOneViewController ()
{
    IBOutlet UILabel *lblTitile;
    IBOutlet UITextView *txtHeader;
    IBOutlet UITextField *txtVenueName;
    IBOutlet UIButton *btnNext;
    
}
@end

@implementation RegisterVenueOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configureLanguage {
    lblTitile.text = LOCALIZATION(@"register_venue");
    txtHeader.text = LOCALIZATION(@"register_header_one");
    txtVenueName.placeholder = LOCALIZATION(@"venue_name");
    [btnNext setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureLanguage];
}

- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    self.venueObject[PARSE_VENUE_NAME] = txtVenueName.text;
    self.venueObject[PARSE_VENUE_AVAILABLE] = @YES;
    self.venueObject[PARSE_VENUE_FOLLOWERS] = [[NSMutableArray alloc] init];
    self.venueObject[PARSE_VENUE_MUTE_LIST] = [[NSMutableArray alloc] init];
    RegisterVenueTwoViewController *vc = (RegisterVenueTwoViewController *)[Util getUIViewControllerFromStoryBoard:@"RegisterVenueTwoViewController"];
    vc.venueObject = self.venueObject;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) isValid {
    txtVenueName.text = [Util trim:txtVenueName.text];
    NSString *name = txtVenueName.text;
    if (name.length < 1){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"short_venue_name") finish:^{
            [txtVenueName becomeFirstResponder];
        }];
        return NO;
    }
    if (name.length>50){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"long_venue_name") finish:^{
            [txtVenueName becomeFirstResponder];
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
