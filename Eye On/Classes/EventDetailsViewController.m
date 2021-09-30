//
//  EventDetailsViewController.m
//  Eye On
//
//  Created by developer on 27/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "VenusDetailViewController.h"
#import "ViewOffersViewController.h"
#import <EventKit/EventKit.h>

@interface EventDetailsViewController ()
{
    IBOutlet UIButton *btnMap;
    IBOutlet UIButton *btnContact;
    IBOutlet UIButton *btnFollow;
    
    IBOutlet UIButton *btnViewOffers;
    IBOutlet UIButton *btnJoinEvent;
    
    IBOutlet UIImageView *imgEvent;
    IBOutlet UILabel *lblShare;
    IBOutlet UILabel *lblShareDescription;
    IBOutlet UIButton *btnAddCalendar;
    IBOutlet UILabel *lblAddCalendar;
    IBOutlet UILabel *lblGetThere;
    IBOutlet UILabel *lblRideTime;
    IBOutlet UILabel *lblTickets;
    IBOutlet UILabel *lblAvailablePurchase;
    IBOutlet UILabel *lblEverything;
    
    
    IBOutlet UILabel *lblEventName;
    IBOutlet UILabel *lblVenueName;
    IBOutlet UITextView *txtAddress;
    IBOutlet UILabel *lblDate;
    IBOutlet UITextView *lblWeekday;
    IBOutlet UILabel *lblGoingCount;
    IBOutlet UILabel *lblSave;
    
    PFObject *venue;
    PFUser *me;
    
    NSMutableArray *users;
}
@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    me = [PFUser currentUser];
    self.object = [self.object fetchIfNeeded];
    venue = self.object[PARSE_EVENT_VENUE];
    venue = [venue fetchIfNeeded];
    users = self.object[PARSE_EVENT_GOING_USERS];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(PaySuccess:) name:NOTIFICATION_PAY_SUCCESS_EVENT object:nil];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguage];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadData];
}

- (BOOL) containsMe:(NSMutableArray *)array{
    for (int i=0;i<array.count;i++){
        PFObject *obj = [array objectAtIndex:i];
        if ([obj.objectId isEqualToString:me.objectId]){
            return YES;
        }
    }
    return NO;
}

- (void) PaySuccess:(NSNotification *) notif {
    NSLog(@"purchased event");
    // increase going count
    if (!users){
        users = [[NSMutableArray alloc] init];
    }
    if (![self containsMe:users])
        [users addObject:me];
    self.object[PARSE_EVENT_GOING_USERS] = users;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [self.object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            // send push notification and make payment history
            PFUser *receiver = self.object[PARSE_EVENT_OWNER];
            receiver = [receiver fetchIfNeeded];
            NSString *myname = me[PARSE_USER_FULL_NAME];
            if (myname.length == 0){
                myname = me.username;
            }
            NSString *msg = [NSString stringWithFormat:@"%@ %@", myname, LOCALIZATION(@"purchased_ticket")];
            [Util saveNotification:receiver Message:msg  Type:NOTIFICATION_TYPE_TICKET];
            PFObject *history = [PFObject objectWithClassName:PARSE_TABLE_PAY_HISTORY];
            history[PARSE_PAYMENT_FROM_USER] = me;
            history[PARSE_PAYMENT_TO_USER] = receiver;
            history[PARSE_PAYMENT_EVENT] = self.object;
            history[PARSE_PAYMENT_VENUE] = venue;
            history[PARSE_PAYMENT_DESCRIPTION] = msg;
            history[PARSE_PAYMENT_AMOUNT] = self.object[PARSE_EVENT_AMOUNT];
            [history saveInBackground];
            // reload data
            [self loadData];
        }
    }];
}

- (void) configureLanguage {
    [btnMap setTitle:LOCALIZATION(@"show_map") forState:UIControlStateNormal];
    [btnContact setTitle:LOCALIZATION(@"contact_venue") forState:UIControlStateNormal];
    [btnFollow setTitle:LOCALIZATION(@"follow") forState:UIControlStateNormal];
    [btnViewOffers setTitle:LOCALIZATION(@"view_offer") forState:UIControlStateNormal];
    
    [btnJoinEvent setTitle:LOCALIZATION(@"join_event") forState:UIControlStateNormal];
    for (int i=0;i<users.count;i++){
        PFObject *ob = [users objectAtIndex:i];
        if ([ob.objectId isEqualToString:me.objectId]){
            [btnJoinEvent setTitle:LOCALIZATION(@"btn_cancel") forState:UIControlStateNormal];
            break;
        }
    }
    
    lblShare.text = LOCALIZATION(@"share");
    lblShareDescription.text = [NSString stringWithFormat:@"(%@)", LOCALIZATION(@"share_description")];
    lblAddCalendar.text = LOCALIZATION(@"add_to_calendar");
    lblGetThere.text = LOCALIZATION(@"get_there_with_uber");
    lblRideTime.text = LOCALIZATION(@"ride_time");
    lblTickets.text = LOCALIZATION(@"tickets");
}

- (void) loadData {
    lblEventName.text = self.object[PARSE_EVENT_NAME];
    lblEverything.text = self.object[PARSE_EVENT_DESCRIPTION];
    lblGoingCount.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)users.count, LOCALIZATION(@"going")];
    [Util setImage:imgEvent imgFile:(PFFile *)self.object[PARSE_EVENT_IMAGE]];
    lblVenueName.text = venue[PARSE_VENUE_NAME];
    BOOL isRepeat = [self.object[PARSE_EVENT_IS_REPEAT] boolValue];
    if (isRepeat){
        lblWeekday.text = [self getWeekDays];
    } else {
        lblWeekday.text = [Util getParseDate:self.object[PARSE_EVENT_START_DATE]];
    }
    txtAddress.text = self.object[PARSE_EVENT_ADDRESS];
    // check price
    if (self.object[PARSE_EVENT_AMOUNT]){
        double amount = [self.object[PARSE_EVENT_AMOUNT] doubleValue];
        if (amount == 0){
            lblAvailablePurchase.text = LOCALIZATION(@"free_event");
        } else {
            NSDate *date = self.object[PARSE_EVENT_CALC_END_DATE];
            NSDate *today = [NSDate date];
            if ([date compare:today] == NSOrderedAscending){
                lblAvailablePurchase.text = LOCALIZATION(@"no_tickets");
            } else {
                lblAvailablePurchase.text = LOCALIZATION(@"available_purchase");
            }
        }
    } else {
        lblAvailablePurchase.text = LOCALIZATION(@"free_event");
    }
    // check saved
    lblSave.text = LOCALIZATION(@"save");
    NSMutableArray *saveUsers = self.object[PARSE_EVENT_SAVER_UESRS];
    for (int i=0;i<saveUsers.count;i++){
        PFObject *obj = [saveUsers objectAtIndex:i];
        if ([obj.objectId isEqualToString:me.objectId]){
            lblSave.text = LOCALIZATION(@"unsave");
        }
    }
    // check followed
    [btnFollow setTitle:LOCALIZATION(@"follow") forState:UIControlStateNormal];
    NSMutableArray *followers = venue[PARSE_VENUE_FOLLOWERS];
    for (int i=0;i<followers.count;i++){
        PFObject *obj = [followers objectAtIndex:i];
        if ([obj.objectId isEqualToString:me.objectId]){
            [btnFollow setTitle:LOCALIZATION(@"unfollow") forState:UIControlStateNormal];
        }
    }
    
    // going count
    lblGoingCount.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)users.count, LOCALIZATION(@"going")];
}

- (NSString *) getWeekDays {
    NSString *result = LOCALIZATION(@"occurs");
    int count = 0;
    if ([self.object[PARSE_EVENT_IS_MONDAY] boolValue]){
        result = [NSString stringWithFormat:@"%@ %@", result, LOCALIZATION(@"monday")];
        count++;
    }
    if ([self.object[PARSE_EVENT_IS_TUESDAY] boolValue]){
        result = (result.length>0)?[NSString stringWithFormat:@"%@ & %@", result, LOCALIZATION(@"tuesday")]:[NSString stringWithFormat:@"%@", LOCALIZATION(@"tuesday")];
        count++;
    }
    if ([self.object[PARSE_EVENT_IS_WEDNESDAY] boolValue]){
        result = (result.length>0)?[NSString stringWithFormat:@"%@ & %@", result, LOCALIZATION(@"wednesday")]:[NSString stringWithFormat:@"%@", LOCALIZATION(@"wednesday")];
        count++;
    }
    if ([self.object[PARSE_EVENT_IS_THURSDAY] boolValue]){
        result = (result.length>0)?[NSString stringWithFormat:@"%@ & %@", result, LOCALIZATION(@"thursday")]:[NSString stringWithFormat:@"%@", LOCALIZATION(@"thursday")];
        count++;
    }
    if ([self.object[PARSE_EVENT_IS_FRIDAY] boolValue]){
        result = (result.length>0)?[NSString stringWithFormat:@"%@ & %@", result, LOCALIZATION(@"friday")]:[NSString stringWithFormat:@"%@", LOCALIZATION(@"friday")];
        count++;
    }
    if ([self.object[PARSE_EVENT_IS_SATURDAY] boolValue]){
        result = (result.length>0)?[NSString stringWithFormat:@"%@ & %@", result, LOCALIZATION(@"saturday")]:[NSString stringWithFormat:@"%@", LOCALIZATION(@"saturday")];
        count++;
    }
    if ([self.object[PARSE_EVENT_IS_SUNDAY] boolValue]){
        result = (result.length>0)?[NSString stringWithFormat:@"%@ & %@", result, LOCALIZATION(@"sunday")]:[NSString stringWithFormat:@"%@", LOCALIZATION(@"sunday")];
        count++;
    }
    if (count == 7)
        result = LOCALIZATION(@"occurs_daily");
    return result;
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTranslate:(id)sender {
    [self translate:txtAddress.text];
}

- (IBAction)onReport:(id)sender {
    [self onReport:self.object type:REPORT_TYPE_EVENT];
}

- (IBAction)onBook:(id)sender {
    
}

- (IBAction)onPurchase:(id)sender {
    if ([lblAvailablePurchase.text isEqualToString:LOCALIZATION(@"available_purchase")]){
        [self buyEvent];
    }
}

- (IBAction)onAddCalendar:(id)sender {
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = lblTitle.text;
        event.startDate = self.object[PARSE_EVENT_START_DATE]; //today
//        event.endDate = [event.startDate dateByAddingTimeInterval:60*60];  //set 1 hour meeting
        event.endDate = self.object[PARSE_EVENT_END_DATE];
        event.calendar = [store defaultCalendarForNewEvents];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
//        self.savedEventId = event.eventIdentifier;  //save the event id if you want to access this later
    }];
}
- (IBAction)onSave:(id)sender {
    if ([lblSave.text isEqualToString:LOCALIZATION(@"save")]){ // save
        NSMutableArray *saveUsers = self.object[PARSE_EVENT_SAVER_UESRS];
        if (!saveUsers){
            saveUsers = [[NSMutableArray alloc] init];
        }
        [saveUsers addObject:me];
        self.object[PARSE_EVENT_SAVER_UESRS] = saveUsers;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self.object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            } else {
                PFUser *toUser = venue[PARSE_VENUE_OWNER];
                toUser = [toUser fetchIfNeeded];
                NSString *myname = me[PARSE_USER_FULL_NAME];
                if (myname.length == 0){
                    myname = me.username;
                }
                [Util saveNotification:toUser Message:[NSString stringWithFormat:@"%@ %@", myname, LOCALIZATION(@"started_following_venue")]  Type:NOTIFICATION_TYPE_FOLLOW];
                lblSave.text = LOCALIZATION(@"unsave");
            }
        }];
    } else { // unsave
        NSMutableArray *saveUsers = self.object[PARSE_EVENT_SAVER_UESRS];
        for (int i=0;i<saveUsers.count;i++){
            PFObject *obj = [saveUsers objectAtIndex:i];
            if ([obj.objectId isEqualToString:me.objectId]){
                [saveUsers removeObject:obj];
                break;
            }
        }
        self.object[PARSE_EVENT_SAVER_UESRS] = saveUsers;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self.object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            } else {
                lblSave.text = LOCALIZATION(@"save");
            }
        }];
    }
}

- (IBAction)onShare:(id)sender {
    NSString *msg = [NSString stringWithFormat:@"Hi! I'm using Dilly to find events. Check out %@ at %@ from Dilly", self.object[PARSE_EVENT_NAME], venue[PARSE_VENUE_NAME]];
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

- (IBAction)onVenue:(id)sender {
    VenusDetailViewController *vc = (VenusDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"VenusDetailViewController"];
    vc.object = venue;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onViewOffers:(id)sender {
    ViewOffersViewController *vc = (ViewOffersViewController *)[Util getUIViewControllerFromStoryBoard:@"ViewOffersViewController"];
    vc.object = self.object;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onJoinEvent:(id)sender {
    // check if event requires tickets - send push notification for Purchasing Ticket
    if ([lblAvailablePurchase.text isEqualToString:LOCALIZATION(@"available_purchase")]){
        [self buyEvent];
        return;
    } else if ([lblAvailablePurchase.text isEqualToString:LOCALIZATION(@"no_tickets")]){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"event_full")];
        return;
    }
    // else - no need tickets --- [lblAvailablePurchase.text isEqualToString:LOCALIZATION(@"free_event")]
    NSString *title = btnJoinEvent.titleLabel.text;
    if ([title isEqualToString:LOCALIZATION(@"join_event")]){
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:LOCALIZATION(@"cool") actionBlock:^(void) {
            if (!users){
                users = [[NSMutableArray alloc] init];
            }
            [users addObject:me];
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            self.object[PARSE_EVENT_GOING_USERS] = users;
            [self.object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                [SVProgressHUD dismiss];
                if (error){
                    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                } else {
                    [self configureLanguage];
                    lblGoingCount.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)users.count, LOCALIZATION(@"going")];
                }
            }];
        }];
        [alert showNotice:LOCALIZATION(@"") subTitle:LOCALIZATION(@"see_you_there") closeButtonTitle:nil duration:0.0f];
    } else if ([title isEqualToString:LOCALIZATION(@"btn_cancel")]){
        for (int i=0;i<users.count;i++){
            PFObject *ob = [users objectAtIndex:i];
            if ([ob.objectId isEqualToString:me.objectId]){
                [users removeObject:ob];
                break;
            }
        }
        self.object[PARSE_EVENT_GOING_USERS] = users;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self.object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            } else {
                [self configureLanguage];
                lblGoingCount.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)users.count, LOCALIZATION(@"going")];
            }
        }];
    }
    
}
- (IBAction)onShowMap:(id)sender {
    [self showMap:self.object];
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
- (IBAction)onFollow:(id)sender {
    NSString *title = btnFollow.titleLabel.text;
    if ([title isEqualToString:LOCALIZATION(@"follow")]){ //follow
        NSMutableArray *userList = venue[PARSE_VENUE_FOLLOWERS];
        if (!userList){
            userList = [[NSMutableArray alloc] init];
        }
        [userList addObject:me];
        venue[PARSE_VENUE_FOLLOWERS] = userList;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [venue saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            } else {
                PFUser *toUser = venue[PARSE_VENUE_OWNER];
                toUser = [toUser fetchIfNeeded];
                NSString *myname = me[PARSE_USER_FULL_NAME];
                if (myname.length == 0){
                    myname = me.username;
                }
                [Util saveNotification:toUser Message:[NSString stringWithFormat:@"%@ %@", myname, LOCALIZATION(@"started_following_venue")]  Type:NOTIFICATION_TYPE_FOLLOW];

                [btnFollow setTitle:LOCALIZATION(@"unfollow") forState:UIControlStateNormal];
            }
        }];
    } else {
        NSMutableArray *saveUsers = venue[PARSE_VENUE_FOLLOWERS];
        for (int i=0;i<saveUsers.count;i++){
            PFObject *obj = [saveUsers objectAtIndex:i];
            if ([obj.objectId isEqualToString:me.objectId]){
                [saveUsers removeObject:obj];
                break;
            }
        }
        venue[PARSE_VENUE_FOLLOWERS] = saveUsers;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [venue saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            } else {
                [btnFollow setTitle:LOCALIZATION(@"follow") forState:UIControlStateNormal];
            }
        }];
    }
}

- (void) buyEvent {
    NSLog(@"purchase event");
    if ([self containsMe:users]){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"already_purchase")];
        return;
    }
    [self purchaseEvent:self.object];
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
