//
//  EventViewController.m
//  Eye On
//
//  Created by developer on 27/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "EventViewController.h"
#import "EventDetailsViewController.h"
#import "MainViewController.h"

@interface EventViewController ()
{
    IBOutlet UIButton *btnAttending;    
    IBOutlet UIButton *btnOpenEvent;
    IBOutlet UIImageView *imgEvent;
    IBOutlet UILabel *lblDate;
    IBOutlet UILabel *lblWeekDay;
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblDistance;
    IBOutlet UILabel *lblGoingCount;
    PFUser *me;
    NSMutableArray *users;
}
@property (strong, nonatomic) IBOutlet UITextView *txtAddress;
@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    me = [PFUser currentUser];
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

- (void) configureLanguage {
    
}

- (void) loadData {
    [Util setImage:imgEvent imgFile:(PFFile *)self.object[PARSE_EVENT_IMAGE]];
    lblDate.text = [Util getParseDate:self.object[PARSE_EVENT_START_DATE]];
    lblName.text = self.object[PARSE_EVENT_NAME];
    PFObject *venue = self.object[PARSE_EVENT_VENUE];
    venue = [venue fetchIfNeeded];
    _txtAddress.text = venue[PARSE_VENUE_LOCATION_ADDRESS];
    
    PFGeoPoint *meLonLat = me[PARSE_USER_LOCATION];
    PFGeoPoint *eventLonLat = self.object[PARSE_EVENT_LOCATION];
    CLLocation *meLocation = [[CLLocation alloc] initWithLatitude:meLonLat.latitude longitude:meLonLat.longitude];
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:eventLonLat.latitude longitude:eventLonLat.longitude];
    CLLocationDistance distance = [meLocation distanceFromLocation:eventLocation];
    lblDistance.text = [NSString stringWithFormat:@"%d %@", (int)distance/1000, LOCALIZATION(@"kimometer")];
    users = self.object[PARSE_EVENT_GOING_USERS];
    lblGoingCount.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)users.count, LOCALIZATION(@"going")];
    
    [btnAttending setTitle:LOCALIZATION(@"attending") forState:UIControlStateNormal];
    for (int i=0;i<users.count;i++){
        PFObject *user = [users objectAtIndex:i];
        if ([user.objectId isEqualToString:me.objectId]){
            [btnAttending setTitle:LOCALIZATION(@"not_going_anymore") forState:UIControlStateNormal];
            break;
        }
    }
    [btnOpenEvent setTitle:LOCALIZATION(@"open_event") forState:UIControlStateNormal];
}

- (IBAction)onAttending:(id)sender {
    NSLog(@"attending");
    NSString *title = btnAttending.titleLabel.text;
    if ([title isEqualToString:LOCALIZATION(@"attending")]){
        if (!users){
            users = [[NSMutableArray alloc] init];
        }
        [users addObject:me];
        self.object[PARSE_EVENT_GOING_USERS] = users;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self.object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (succeed && !error){
                [btnAttending setTitle:LOCALIZATION(@"not_going_anymore") forState:UIControlStateNormal];
                lblGoingCount.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)users.count, LOCALIZATION(@"going")];
            } else {
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            }
        }];
    } else if ([title isEqualToString:LOCALIZATION(@"not_going_anymore")]){
        for (int i=0;i<users.count;i++){
            PFObject *user = [users objectAtIndex:i];
            if ([user.objectId isEqualToString:me.objectId]){
                [users removeObject:user];
                break;
            }
        }
        self.object[PARSE_EVENT_GOING_USERS] = users;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self.object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (succeed && !error){
                [btnAttending setTitle:LOCALIZATION(@"attending") forState:UIControlStateNormal];
                lblGoingCount.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)users.count, LOCALIZATION(@"going")];
            } else {
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            }
        }];
    }
}

- (IBAction)onOpenEvent:(id)sender {
    EventDetailsViewController *vc = (EventDetailsViewController *)[Util getUIViewControllerFromStoryBoard:@"EventDetailsViewController"];
    vc.object = self.object;
    [[MainViewController getInstance] pushViewController:vc];
    [self dismissViewControllerAnimated:NO completion:nil];
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
