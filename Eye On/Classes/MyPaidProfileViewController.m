//
//  MyPaidProfileViewController.m
//  Eye On
//
//  Created by developer on 24/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "MyPaidProfileViewController.h"
#import "CircleImageView.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "NotificatinsViewController.h"
#import "EventViewController.h"
#import "VenusDetailViewController.h"
#import "SearchResultsViewController.h"
#import "MyTicketsViewController.h"
#import "CreateEventOneViewController.h"
#import "NotificatinsViewController.h"
#import "SendPushViewController.h"
#import "EditProfileViewController.h"
#import "PhotoViewController.h"

@interface MyPaidProfileViewController ()<CircleImageAddDelegate>
{
    IBOutlet CircleImageView *imgAvatar;
    IBOutlet UILabel *lblContactNum;
    IBOutlet UILabel *lblName;
    
    IBOutlet UILabel *lblAmount;
    IBOutlet UILabel *lblEventsAttended;
    IBOutlet UILabel *lblOfferRedeemed;
    IBOutlet UILabel *lblEventsCreated;
    IBOutlet UILabel *lblTicketsSold;
    IBOutlet UILabel *lblDealOffered;
    IBOutlet UILabel *lblVenueFollowed;
    
    IBOutlet UIButton *btnVenueProfile;
    IBOutlet UIButton *btnCreateEvent;
    IBOutlet UIButton *btnMyEvents;
    IBOutlet UIButton *btnMyTickets;
    IBOutlet UIButton *btnLogout;
    
    IBOutlet UILabel *lblTitle;
    IBOutlet UITextView *txtEventAttending;
    IBOutlet UITextView *txtOffersRedeem;
    IBOutlet UITextView *txtEventCreated;
    IBOutlet UITextView *txtTicketSold;
    IBOutlet UITextView *txtDealOffer;
    IBOutlet UITextView *txtVenueFollowed;
    
    PFUser *me;
    PFObject *venue;
}
@end

@implementation MyPaidProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    me = [PFUser currentUser];
    imgAvatar.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    me = [me fetchIfNeeded];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_VENUE];
    [query whereKey:PARSE_VENUE_OWNER equalTo:[PFUser currentUser]];
    [query whereKey:PARSE_VENUE_AVAILABLE equalTo:@YES];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            if (objects.count == 0){
                me[PARSE_USER_HAS_VENUE] = @NO;
                [self.navigationController popViewControllerAnimated:NO];
            } else {
                me[PARSE_USER_HAS_VENUE] = @YES;
                venue = [objects objectAtIndex:0];
                [self setInfo];
            }
            [me saveInBackground];
        }
    }];
    
    [self configureLanguage];
}

- (void) configureLanguage {
    lblTitle.text = LOCALIZATION(@"my_profile");
    txtEventAttending.text = LOCALIZATION(@"events_attending_low");
    txtOffersRedeem.text = LOCALIZATION(@"offers_redeemed_low");
    txtEventCreated.text = LOCALIZATION(@"events_created");
    txtTicketSold.text = LOCALIZATION(@"ticket_sold");
    txtDealOffer.text = LOCALIZATION(@"deal_offer");
    txtVenueFollowed.text = LOCALIZATION(@"venue_followers");
    
    [btnVenueProfile setTitle:LOCALIZATION(@"venue_profile") forState:UIControlStateNormal];
    [btnCreateEvent setTitle:LOCALIZATION(@"create_event") forState:UIControlStateNormal];
    [btnMyEvents setTitle:LOCALIZATION(@"my_events") forState:UIControlStateNormal];
    [btnMyTickets setTitle:LOCALIZATION(@"my_ticket") forState:UIControlStateNormal];
    [btnLogout setTitle:LOCALIZATION(@"logout") forState:UIControlStateNormal];
}

- (void) setInfo {
    NSString *name = me[PARSE_USER_FULL_NAME];
    lblName.text = (name.length > 0)?name:me.username;
    [Util setImage:imgAvatar imgFile:(PFFile *)me[PARSE_USER_AVATAR]];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_EVENT];
    [query whereKey:PARSE_EVENT_GOING_USERS equalTo:me];
    [query whereKey:PARSE_EVENT_CALC_END_DATE lessThan:[NSDate date]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            lblEventsAttended.text = [NSString stringWithFormat:@"%lu", (unsigned long)array.count];
            PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_OFFER];
            [query1 whereKey:PARSE_OFFER_REDEEM_USERS equalTo:me];
            [query1 findObjectsInBackgroundWithBlock:^(NSArray *array1, NSError *error){
                if (error){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                } else {
                    lblOfferRedeemed.text = [NSString stringWithFormat:@"%lu", array1.count];
                    PFQuery *query2 = [PFQuery queryWithClassName:PARSE_TABLE_EVENT];
                    [query2 whereKey:PARSE_EVENT_OWNER equalTo:me];
                    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                        if (error){
                            [SVProgressHUD dismiss];
                            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                        } else {
                            int tickets = 0;
                            lblEventsCreated.text = [NSString stringWithFormat:@"%lu", objects.count];
                            for (int i=0;i<objects.count;i++){
                                PFObject *obj = [objects objectAtIndex:i];
                                NSArray *ticketUsers = obj[PARSE_EVENT_GOING_USERS];
                                if (ticketUsers.count>0){
                                    tickets++;
                                }
                            }
                            lblTicketsSold.text = [NSString stringWithFormat:@"%d", tickets];
                            PFQuery *query3 = [PFQuery queryWithClassName:PARSE_TABLE_OFFER];
                            [query3 whereKey:PARSE_EVENT_OWNER equalTo:me];
                            [query3 findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *err){
                                if (err){
                                    [SVProgressHUD dismiss];
                                    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                                } else {
                                    lblDealOffered.text = [NSString stringWithFormat:@"%lu", objs.count];
                                    PFQuery *query4 = [PFQuery queryWithClassName:PARSE_TABLE_VENUE];
                                    [query4 whereKey:PARSE_VENUE_OWNER equalTo:me];
                                    [query4 findObjectsInBackgroundWithBlock:^(NSArray *obs, NSError *ero){
                                        if (ero){
                                            [SVProgressHUD dismiss];
                                            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                                        } else {
                                            int count = 0;
                                            for (int i=0;i<obs.count;i++){
                                                PFObject *obj = [obs objectAtIndex:i];
                                                NSArray *followers = obj[PARSE_VENUE_FOLLOWERS];
                                                count += followers.count;
                                            }
                                            lblVenueFollowed.text = [NSString stringWithFormat:@"%d", count];
                                            PFQuery *query5 = [PFQuery queryWithClassName:PARSE_TABLE_EVENT];
                                            [query5 whereKey:PARSE_EVENT_GOING_USERS equalTo:me];
                                            [query5 whereKey:PARSE_EVENT_CALC_END_DATE lessThan:[NSDate date]];
                                            [query5 findObjectsInBackgroundWithBlock:^(NSArray *arry, NSError *eror){
                                                [SVProgressHUD dismiss];
                                                if (eror){
                                                    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[eror localizedDescription]];
                                                } else {
                                                    double sum = 0;
                                                    for (int i=0;i<arry.count;i++){
                                                        PFObject *event = [arry objectAtIndex:i];
                                                        double price = [event[PARSE_EVENT_AMOUNT] doubleValue];
                                                        sum += price;
                                                    }
                                                    lblAmount.text = [NSString stringWithFormat:@"US$ %.2f", sum];
                                                }
                                                
                                            }];
                                        }
                                    }];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];
}

- (IBAction)onVenueProfile:(id)sender {
    VenusDetailViewController *vc = (VenusDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"VenusDetailViewController"];
    vc.object = venue;
    [[MainViewController getInstance] pushViewController:vc];
}

- (IBAction)onCreateEvent:(id)sender {
    CreateEventOneViewController *vc = (CreateEventOneViewController *)[Util getUIViewControllerFromStoryBoard:@"CreateEventOneViewController"];
    vc.venueObeject = venue;
    [[MainViewController getInstance] pushViewController:vc];
}

- (IBAction)onMyEvents:(id)sender {
    SearchResultsViewController *vc = (SearchResultsViewController *)[Util getUIViewControllerFromStoryBoard:@"SearchResultsViewController"];
    [[MainViewController getInstance] pushViewController:vc];
}

- (IBAction)onMyTickets:(id)sender {
    MyTicketsViewController *vc = (MyTicketsViewController *)[Util getUIViewControllerFromStoryBoard:@"MyTicketsViewController"];
    [[MainViewController getInstance] pushViewController:vc];
}

- (IBAction)onLogout:(id)sender {
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
}

- (IBAction)onMenu:(id)sender {
    [[MainViewController getInstance] showSideMenu];
}
- (IBAction)onNotifications:(id)sender {
    NotificatinsViewController *vc = (NotificatinsViewController *)[Util getUIViewControllerFromStoryBoard:@"NotificatinsViewController"];
    [[MainViewController getInstance] pushViewController:vc];
}
- (IBAction)onSendPush:(id)sender {
    SendPushViewController *vc = (SendPushViewController *)[Util getUIViewControllerFromStoryBoard:@"SendPushViewController"];
    vc.venus = venue;
    [[MainViewController getInstance] pushViewController:vc];
}
- (IBAction)EditProfile:(id)sender {
    EditProfileViewController *vc = (EditProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"EditProfileViewController"];
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
- (void) tapCircleImageView {
    PhotoViewController *vc = (PhotoViewController *)[Util getUIViewControllerFromStoryBoard:@"PhotoViewController"];
    vc.user = me;
    [[MainViewController getInstance] pushViewController:vc];
}

@end
