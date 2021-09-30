//
//  SendPushViewController.m
//  Eye On
//
//  Created by developer on 26/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SendPushViewController.h"
#import "IQDropDownTextField.h"

@interface SendPushViewController ()<IQDropDownTextFieldDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnSend;
    
    IBOutlet IQDropDownTextField *txtEvent;
    IBOutlet IQDropDownTextField *txtAction;
    
    NSMutableArray *eventList;
    NSMutableArray *actionList;
    
    NSMutableArray *dataArray;
    PFUser *me;
    
    NSMutableArray *followVenueUsers;
    NSMutableArray *attendingUsers;
    NSMutableArray *areaUsers;
}
@end

@implementation SendPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    txtEvent.delegate = self;
    txtAction.delegate = self;
    me = [PFUser currentUser];
    
    [self initUserArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguage];
}

- (void)configureLanguage {
    lblTitle.text = LOCALIZATION(@"push_notification");
    [btnSend setTitle:LOCALIZATION(@"send_push") forState:UIControlStateNormal];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) initUserArray{
    self.venus = [self.venus fetchIfNeeded];
    NSMutableArray *followers = self.venus[PARSE_VENUE_FOLLOWERS];
    NSMutableArray *follwerIds = [[NSMutableArray alloc] init];
    for (int i=0;i<followers.count;i++){
        PFUser *us = [followers objectAtIndex:i];
        [follwerIds addObject:us.objectId];
    }

    followVenueUsers = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_IS_VENUE_FOLLOW equalTo:@YES];
    [SVProgressHUD show];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            for (int i=0;i<objects.count;i++){
                PFUser *obj = [objects objectAtIndex:i];
                if ([follwerIds containsObject:obj.objectId]){
                    [followVenueUsers addObject:obj];
                }
            }
            areaUsers = [[NSMutableArray alloc] init];
            PFGeoPoint *current = me[PARSE_USER_LOCATION];
            PFQuery *query1 = [PFUser query];
            [query1 whereKey:PARSE_USER_IS_VENUE_AREA equalTo:@YES];
            [query1 whereKey:PARSE_USER_LOCATION nearGeoPoint:current withinKilometers:5.0];
            [query1 findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                if (error){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                } else {
                    for (int i=0;i<array.count;i++){
                        PFUser *object = [array objectAtIndex:i];
                        [areaUsers addObject:object];
                    }
                    attendingUsers = [[NSMutableArray alloc] init];
                    PFQuery *query2 = [PFUser query];
                    [query2 whereKey:PARSE_USER_IS_EVENT_ATTEND equalTo:@YES];
                    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error){
                        if (error){
                            [SVProgressHUD dismiss];
                            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                        } else {
                            attendingUsers = (NSMutableArray *)objs;
                            [self refreshItems];
                        }
                    }];
                }
            }];
        }
    }];
}

- (void) refreshItems {
    eventList = [NSMutableArray arrayWithObjects:LOCALIZATION(@"not_applicable"), nil];
    dataArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_EVENT];
    [query whereKey:PARSE_EVENT_OWNER equalTo:[PFUser currentUser]];
    [query whereKey:PARSE_EVENT_VENUE equalTo:self.venus];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *)array;
            if (array.count == 0){
                actionList = [NSMutableArray arrayWithObjects:LOCALIZATION(@"action_promote"), nil];
                txtEvent.itemList = eventList;
                txtAction.itemList = actionList;
            } else {
                actionList = [NSMutableArray arrayWithObjects:LOCALIZATION(@"action_promote"), LOCALIZATION(@"action_remind"), LOCALIZATION(@"action_advertise"), nil];
                txtAction.itemList = actionList;
                for (int i=0;i<array.count;i++){
                    PFObject *event = [array objectAtIndex:i];
                    NSString *name = event[PARSE_EVENT_NAME];
                    [eventList addObject:name];
                }
                txtEvent.itemList = eventList;
            }
        }
    }];
}

- (IBAction)onSendPush:(id)sender {
    self.venus = [self.venus fetchIfNeeded];
    if ([txtEvent.selectedItem isEqualToString:LOCALIZATION(@"not_applicable")]){ // not applicable
        if ([txtAction.selectedItem isEqualToString:LOCALIZATION(@"action_promote")]){
            NSString *msg = [NSString stringWithFormat:@"%@ %@!", LOCALIZATION(@"come_visit"), self.venus[PARSE_VENUE_NAME]];
            NSMutableArray *users = [self mix2Arrays:followVenueUsers :areaUsers];
            [Util sendPushNotification:[NSString stringWithFormat:@"%d", NOTIFICATION_TYPE_NOT_APPLICABLE] receiverList:users message:msg event:nil venue:self.venus];
        }
    } else if (txtEvent.selectedItem && txtEvent.selectedRow !=-1) { // applicable
        NSString *eventName = txtEvent.selectedItem;
        NSString *venueName = self.venus[PARSE_VENUE_NAME];
        if ([txtAction.selectedItem isEqualToString:LOCALIZATION(@"action_promote")]){
            NSString *msg = [NSString stringWithFormat:@"%@ %@ %@!", venueName, LOCALIZATION(@"have_event"), eventName];
            self.event = [dataArray objectAtIndex:(txtEvent.selectedRow-1)];
            NSMutableArray *users = [self mix2Arrays:followVenueUsers :areaUsers];
            [Util sendPushNotification:[NSString stringWithFormat:@"%d", NOTIFICATION_TYPE_APPLICABLE] receiverList:users message:msg event:self.event venue:self.venus];
        } else if ([txtAction.selectedItem isEqualToString:LOCALIZATION(@"action_remind")]){
            NSString *msg = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@!", LOCALIZATION(@"dont_foget"), eventName, LOCALIZATION(@"at"), venueName, LOCALIZATION(@"on"), [Util getParseDate:self.event[PARSE_EVENT_CALC_END_DATE]]];
            NSMutableArray *users = [self mix2Arrays:attendingUsers :followVenueUsers];
            users = [self mix2Arrays:users :areaUsers];
            [Util sendPushNotification:[NSString stringWithFormat:@"%d", NOTIFICATION_TYPE_APPLICABLE] receiverList:users message:msg event:self.event venue:self.venus];
        } else if ([txtAction.selectedItem isEqualToString:LOCALIZATION(@"action_advertise")]){
            NSString *msg = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", LOCALIZATION(@"join"), eventName, LOCALIZATION(@"at"), venueName, LOCALIZATION(@"enjoy_offer")];
            NSMutableArray *users = [self mix2Arrays:followVenueUsers :areaUsers];
            [Util sendPushNotification:[NSString stringWithFormat:@"%d", NOTIFICATION_TYPE_APPLICABLE] receiverList:users message:msg event:self.event venue:self.venus];
        }
    }
}

- (NSMutableArray *) mix2Arrays:(NSMutableArray *)array1 :(NSMutableArray *)array2 {
    NSMutableArray *idArray = [[NSMutableArray alloc] init];
    NSMutableArray *result = [NSMutableArray arrayWithArray:array1];
    for (int i=0;i<array1.count;i++){
        PFObject *obj = [array1 objectAtIndex:i];
        [idArray addObject:obj.objectId];
    }
    for (int i=0;i<array2.count;i++){
        PFObject *obj = [array2 objectAtIndex:i];
        if (![idArray containsObject:obj.objectId]){
            [result addObject:[array2 objectAtIndex:i]];
            [idArray addObject:obj.objectId];
        }
    }
    return result;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) textField:(IQDropDownTextField *)textField didSelectItem:(NSString *)item {
    if (textField == txtEvent){
        if ([item isEqualToString:LOCALIZATION(@"not_applicable")]){
            actionList = [NSMutableArray arrayWithObjects:LOCALIZATION(@"action_promote"), nil];
            txtAction.itemList = actionList;
        } else {
            actionList = [NSMutableArray arrayWithObjects:LOCALIZATION(@"action_promote"), LOCALIZATION(@"action_remind"), LOCALIZATION(@"action_advertise"), nil];
            txtAction.itemList = actionList;
        }
    }
}
@end
