//
//  VenusDetailViewController.m
//  Eye On
//
//  Created by developer on 26/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "VenusDetailViewController.h"
#import "EventListViewController.h"
#import "SearchResultsViewController.h"
#import "SearchModel.h"

@interface VenusDetailViewController ()
{
    IBOutlet UIButton *btnShowMap;
    IBOutlet UIButton *btnContact;
    IBOutlet UIButton *btnUnfollow;
    
    IBOutlet UILabel *lblEventName; // venue name
    IBOutlet UIImageView *imgEvent;
    IBOutlet UILabel *lblMute;
    IBOutlet UILabel *lblShareDesc;
    IBOutlet UILabel *lblShare;
    IBOutlet UITextView *txtAddress;
    IBOutlet UITextView *txtActiveEvent;
    IBOutlet UITextView *txtCompleteEvent;
    IBOutlet UILabel *lblOperatingHours;
    IBOutlet UILabel *lblEmail;
    IBOutlet UILabel *lblPhone;
    IBOutlet UILabel *lblwebsite;
    IBOutlet UILabel *lblActiveEvents;
    IBOutlet UILabel *lblCompletedEvents;
    
    NSDate *today;
    PFUser *me;
}
@end

@implementation VenusDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    me = [PFUser currentUser];
    
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                    fromDate:[NSDate date]];
    today = [[NSCalendar currentCalendar]
                         dateFromComponents:components];
    // query for active an completed events counts
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_EVENT];
    [query whereKey:PARSE_EVENT_END_DATE lessThan:today];
    [query whereKey:PARSE_EVENT_VENUE equalTo:self.object];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            lblCompletedEvents.text = [NSString stringWithFormat:@"%lu", (unsigned long)objects.count];
            PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_EVENT];
            [query1 whereKey:PARSE_EVENT_END_DATE greaterThanOrEqualTo:today];
            [query1 whereKey:PARSE_EVENT_VENUE equalTo:self.object];
            [query1 findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error){
                [SVProgressHUD dismiss];
                if (!error){
                    lblActiveEvents.text = [NSString stringWithFormat:@"%lu", (unsigned long)objs.count];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
        }
    }];
    
    [self loadData];
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
    [btnShowMap setTitle:LOCALIZATION(@"show_map") forState:UIControlStateNormal];
    [btnContact setTitle:LOCALIZATION(@"contact_venue") forState:UIControlStateNormal];
    [btnUnfollow setTitle:LOCALIZATION(@"unfollow") forState:UIControlStateNormal];
    lblMute.text = LOCALIZATION(@"mute");//Mute
    lblShareDesc.text = [NSString stringWithFormat:@"(%@)", LOCALIZATION(@"share_description")];
    lblShare.text = LOCALIZATION(@"share");
    txtActiveEvent.text = LOCALIZATION(@"active_events");
    txtCompleteEvent.text = LOCALIZATION(@"completed_events");
    
    NSMutableArray *users = self.object[PARSE_VENUE_FOLLOWERS];
    if (users.count == 0){
        [btnUnfollow setTitle:LOCALIZATION(@"follow") forState:UIControlStateNormal];
    } else {
        for (int i=0;i<users.count;i++){
            PFObject *ob = [users objectAtIndex:i];
            if ([ob.objectId isEqualToString:me.objectId]){
                [btnUnfollow setTitle:LOCALIZATION(@"unfollow") forState:UIControlStateNormal];
                break;
            }
        }
    }
    
    users = self.object[PARSE_VENUE_MUTE_LIST];
    if (users.count == 0){
        lblMute.text = LOCALIZATION(@"mute");
    } else {
        for (int i=0;i<users.count;i++){
            PFObject *ob = [users objectAtIndex:i];
            if ([ob.objectId isEqualToString:me.objectId]){
                lblMute.text = LOCALIZATION(@"unmute");
                break;
            }
        }
    }
}

- (void) loadData {
    lblEventName.text = self.object[PARSE_VENUE_NAME];
    txtAddress.text = self.object[PARSE_VENUE_LOCATION_ADDRESS];
    lblOperatingHours.text = self.object[PARSE_VENUE_OPERATING_HOURS];
    lblEmail.text = self.object[PARSE_VENUE_EMAIL];
    lblPhone.text = self.object[PARSE_VENUE_CONTACT_NUM];
    lblwebsite.text = self.object[PARSE_VENUE_WEB_SITE];
    [Util setImage:imgEvent imgFile:(PFFile *)self.object[PARSE_VENUE_IMAGE]];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onMute:(id)sender {
    NSMutableArray *mutelist = self.object[PARSE_VENUE_MUTE_LIST];
    if (!mutelist){
        mutelist = [[NSMutableArray alloc] init];
    }
    if ([lblMute.text isEqualToString:LOCALIZATION(@"mute")]){//mute
        [mutelist addObject:me];
    } else if ([lblMute.text isEqualToString:LOCALIZATION(@"unmute")]){//unmute
        for (int i=0;i<mutelist.count;i++){
            PFObject *obj = [mutelist objectAtIndex:i];
            if ([me.objectId isEqualToString:obj.objectId]){
                [mutelist removeObject:obj];
                break;
            }
        }
    }
    
    self.object[PARSE_VENUE_MUTE_LIST] = mutelist;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [self.object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            if ([lblMute.text isEqualToString:LOCALIZATION(@"mute")]){
                lblMute.text = LOCALIZATION(@"unmute");
            } else if ([lblMute.text isEqualToString:LOCALIZATION(@"unmute")]){
                lblMute.text = LOCALIZATION(@"mute");
            }
        }
    }];
}

- (IBAction)onTranslate:(id)sender {
    [self translate:txtAddress.text];
}
- (IBAction)onUnfollow:(id)sender {
    NSString *title = btnUnfollow.titleLabel.text;
    PFObject *venue = self.object;
    NSMutableArray *users = venue[PARSE_VENUE_FOLLOWERS];
    if ([title isEqualToString:LOCALIZATION(@"follow")]){
        if (!users){
            users = [[NSMutableArray alloc] init];
        }
        [users addObject:[PFUser currentUser]];
        venue[PARSE_VENUE_FOLLOWERS] = users;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [venue saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (succeed && !error){
                PFUser *owner = (PFUser *)venue[PARSE_VENUE_OWNER];
                owner = [owner fetchIfNeeded];
                NSString *myname = @"";
                if (me[PARSE_USER_FULL_NAME]){
                    myname = me[PARSE_USER_FULL_NAME];
                } else {
                    myname = me.username;
                }
                [Util saveNotification:owner Message:[NSString stringWithFormat:@"%@ %@", myname, LOCALIZATION(@"saved_venue")]  Type:NOTIFICATION_TYPE_TAGGED];
                [btnUnfollow setTitle:LOCALIZATION(@"unfollow") forState:UIControlStateNormal];
            } else {
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            }
        }];
    } else if ([title isEqualToString:LOCALIZATION(@"unfollow")]){
        for (int i=0;i<users.count;i++){
            PFObject *obj = [users objectAtIndex:i];
            if ([obj.objectId isEqualToString:me.objectId]){
                [users removeObject:obj];
                break;
            }
        }
        venue[PARSE_VENUE_FOLLOWERS] = users;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [venue saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (succeed && !error){
                [btnUnfollow setTitle:LOCALIZATION(@"follow") forState:UIControlStateNormal];
            } else {
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            }
        }];
    }
}
- (IBAction)onContact:(id)sender {
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"email") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self sendMail:[NSArray arrayWithObjects:self.object[PARSE_VENUE_EMAIL], nil] subject:nil message:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"phone") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self makeCallWithNumber:self.object[PARSE_VENUE_CONTACT_NUM]];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}

- (IBAction)onShowMap:(id)sender {
    [self showMap:self.object];
}

- (IBAction)onReport:(id)sender {
    [self onReport:self.object type:REPORT_TYPE_VENUE];
}

- (IBAction)onShare:(id)sender {
    NSString *msg = [NSString stringWithFormat:@"Hi! I'm using Dilly to find events. Check out %@ from Dilly", self.object[PARSE_VENUE_NAME]];
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"share_email") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self sendMail:nil subject:nil message:msg];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"share_sms") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self sendSMS:nil subject:nil message:msg];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}

- (IBAction)onEmail:(id)sender {
    NSArray *email = [NSArray arrayWithObjects:self.object[PARSE_VENUE_EMAIL], nil];
    [self sendMail:email subject:nil message:nil];
}

- (IBAction)onPhone:(id)sender {
    [self makeCallWithNumber:self.object[PARSE_VENUE_CONTACT_NUM]];
}

- (IBAction)onWebSite:(id)sender {
    [self openURL:self.object[PARSE_VENUE_WEB_SITE]];
}

- (IBAction)onActiveEvents:(id)sender {
    SearchModel *model = [[SearchModel alloc] init];
    model.isActive = YES;
    model.isComplete = NO;
    model.isPlanning = NO;
    model.isHereNow = NO;
    model.dateTo = today;
    [self gotoEventList:model];
}

- (IBAction)onCompletedEvents:(id)sender {
    SearchModel *model = [[SearchModel alloc] init];
    model.isActive = NO;
    model.isComplete = YES;
    model.isPlanning = NO;
    model.isHereNow = NO;
    model.dateFrom = today;
    [self gotoEventList:model];
}

- (void) gotoEventList:(SearchModel *)model {
    EventListViewController *vc = (EventListViewController *)[Util getUIViewControllerFromStoryBoard:@"EventListViewController"];
    vc.model = model;
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
