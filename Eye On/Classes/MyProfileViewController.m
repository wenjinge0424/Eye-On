//
//  MyProfileViewController.m
//  Eye On
//
//  Created by developer on 26/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "MyProfileViewController.h"
#import "MainViewController.h"
#import "EditProfileViewController.h"
#import "MyTicketsViewController.h"
#import "PrivateEventsViewController.h"
#import "ChoosePlaneViewController.h"
#import "CircleImageView.h"
#import "LoginViewController.h"
#import "SplashViewController.h"
#import "NotificatinsViewController.h"
#import "MyPaidProfileViewController.h"
#import "PhotoViewController.h"

@interface MyProfileViewController ()<CircleImageAddDelegate>
{
    IBOutlet UILabel *lblTitile;
    IBOutlet CircleImageView *imgProfile;
    
    IBOutlet UITextView *txtEventsAttending;
    IBOutlet UITextView *txtOffersRedeem;
    IBOutlet UIButton *btnCreateEvent;
    IBOutlet UIButton *btnMyTickets;
    IBOutlet UIButton *btnMyEvents;
    IBOutlet UIButton *btnLogout;
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblPhone;
    IBOutlet UILabel *lblAttend;
    IBOutlet UILabel *lblOffers;
    
    PFUser *me;
    NSDate *today;
}
@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util setBorderView:imgProfile color:COLOR_WHITE width:1.0];
    imgProfile.delegate = self;
    me = [PFUser currentUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    me = [me fetchIfNeeded];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_VENUE];
    [query whereKey:PARSE_VENUE_OWNER equalTo:me];
    [query whereKey:PARSE_VENUE_AVAILABLE equalTo:@YES];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            if (objects.count > 0){
                [SVProgressHUD dismiss];
                me[PARSE_USER_HAS_VENUE] = @YES;
                MyPaidProfileViewController *vc = (MyPaidProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"MyPaidProfileViewController"];
                [self.navigationController pushViewController:vc animated:NO];
            } else {
                me[PARSE_USER_HAS_VENUE] = @NO;
                [self setInfo];
            }
            [me saveInBackground];
        }
    }];
    
    [self configureLanguage];
}

- (void) configureLanguage {
    lblTitle.text = LOCALIZATION(@"my_profile");
    txtEventsAttending.text = LOCALIZATION(@"events_attending");
    txtOffersRedeem.text = LOCALIZATION(@"offers_redeemed");
    [btnCreateEvent setTitle:LOCALIZATION(@"create_event") forState:UIControlStateNormal];
    [btnMyTickets setTitle:LOCALIZATION(@"my_ticket") forState:UIControlStateNormal];
    [btnMyEvents setTitle:LOCALIZATION(@"PrivateEvents") forState:UIControlStateNormal];
    [btnLogout setTitle:LOCALIZATION(@"logout") forState:UIControlStateNormal];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) setInfo {
    [Util setImage:imgProfile imgFile:(PFFile *)me[PARSE_USER_AVATAR]];
    NSString *fullname = me[PARSE_USER_FULL_NAME];
    NSString *firsname = me[PARSE_USER_FIRST_NAME];
    NSString *lastname = me[PARSE_USER_LAST_NAME];
    if (firsname.length == 0){
        firsname = @"";
    }
    if (lastname.length == 0){
        lastname = @"";
    }
    lblName.text = [NSString stringWithFormat:@"%@ %@", firsname, lastname];
    
    if (fullname.length == 0){
        fullname = [NSString stringWithFormat:@"%@ %@", firsname, lastname];
        if (fullname.length == 0){
            lblName.text = me.username;
        } else {
            lblName.text = fullname;
        }
    } else {
        lblName.text = fullname;
    }
    
    lblPhone.text = me[PARSE_USER_CONTACT_NUMBER];
    
    // get joining events count
    today = [NSDate date];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_EVENT];
    [query whereKey:PARSE_EVENT_AMOUNT notEqualTo:[NSNumber numberWithInt:0]];
    [query whereKey:PARSE_EVENT_GOING_USERS equalTo:me];
    [query whereKey:PARSE_EVENT_END_DATE greaterThan:today];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_OFFER];
            [query1 whereKey:PARSE_OFFER_REDEEM_USERS equalTo:me];
            [query1 findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error){
                [SVProgressHUD dismiss];
                if (error){
                    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                } else {
                    lblOffers.text = [NSString stringWithFormat:@"%lu", (unsigned long)objs.count];
                    lblAttend.text = [NSString stringWithFormat:@"%lu", (unsigned long)objects.count];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        }
    }];
}

- (IBAction)onMenu:(id)sender {
    [[MainViewController getInstance] showSideMenu];
}

- (IBAction)onEdit:(id)sender {
    EditProfileViewController *vc = (EditProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"EditProfileViewController"];
    [[MainViewController getInstance] pushViewController:vc];
}

- (IBAction)onNotifications:(id)sender {
    NotificatinsViewController *vc = (NotificatinsViewController *)[Util getUIViewControllerFromStoryBoard:@"NotificatinsViewController"];
    [[MainViewController getInstance] pushViewController:vc];
}

- (IBAction)onCreateEvent:(id)sender {
    ChoosePlaneViewController *vc = (ChoosePlaneViewController *)[Util getUIViewControllerFromStoryBoard:@"ChoosePlaneViewController"];
    [[MainViewController getInstance] pushViewController:vc];
}
- (IBAction)onMyTickets:(id)sender {
    MyTicketsViewController *vc = (MyTicketsViewController *)[Util getUIViewControllerFromStoryBoard:@"MyTicketsViewController"];
    [[MainViewController getInstance] pushViewController:vc];
}
- (IBAction)onPrivateTickets:(id)sender {
    PrivateEventsViewController *vc = (PrivateEventsViewController *)[Util getUIViewControllerFromStoryBoard:@"PrivateEventsViewController"];
    [[MainViewController getInstance] pushViewController:vc];
}
- (IBAction)onLogout:(id)sender {
    PFUser *me = [PFUser currentUser];
    if (me){
        [SVProgressHUD showWithStatus:LOCALIZATION(@"logging_out") maskType:SVProgressHUDMaskTypeGradient];
        [PFUser logOutInBackgroundWithBlock:^(NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:LOCALIZATION(@"logout") message:[error localizedDescription]];
            } else {
                [Util setLoginUserName:@"" password:@""];
                for (UIViewController *vc in [Util appDelegate].rootNavigationViewController.viewControllers){
                    if ([vc isKindOfClass:[LoginViewController class]]){
                        [[Util appDelegate].rootNavigationViewController popToViewController:vc animated:YES];
                        break;
                    }
                }
            }
        }];
    } else {
        for (UIViewController *vc in [Util appDelegate].rootNavigationViewController.viewControllers){
            if ([vc isKindOfClass:[SplashViewController class]]){
                [[Util appDelegate].rootNavigationViewController popToViewController:vc animated:YES];
                break;
            }
        }
    }    
}

- (void) tapCircleImageView {
    PhotoViewController *vc = (PhotoViewController *)[Util getUIViewControllerFromStoryBoard:@"PhotoViewController"];
    vc.user = me;
    [[MainViewController getInstance] pushViewController:vc];
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
