//
//  PrivateEventsViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "PrivateEventsViewController.h"
#import "EventDetailsViewController.h"

@interface PrivateEventsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UITableView *tableview;
    NSMutableArray *dataArray;
    UIRefreshControl *refreshControl;
    PFUser *me;
}
@end

@implementation PrivateEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = MAIN_COLOR;
    [refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
    [tableview addSubview:refreshControl];
    
    tableview.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
    [self refreshItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguage];
}
- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) configureLanguage {
    lblTitle.text = LOCALIZATION(@"private_events");
}

- (void) refreshItems {
    dataArray = [[NSMutableArray alloc] init];
    self.view.userInteractionEnabled = NO;
    [refreshControl beginRefreshing];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_EVENT];
    [query whereKey:PARSE_EVENT_PRIVATE_UESRS equalTo:me];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        self.view.userInteractionEnabled = YES;
        [refreshControl endRefreshing];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *)objects;
            [tableview reloadData];
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
- (NSInteger ) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellEvent"];
    UIImageView *image = (UIImageView *)[cell viewWithTag:1];
    UITextView *txtOccurDate = (UITextView *)[cell viewWithTag:2];
    UILabel *labelName = (UILabel *)[cell viewWithTag:3];
    UITextView *txtAddress = (UITextView *)[cell viewWithTag:4];
    UILabel *lblDistance = (UILabel *)[cell viewWithTag:5];
    
    PFObject *event = [dataArray objectAtIndex:indexPath.row];
    [Util setImage:image imgFile:(PFFile *)event[PARSE_EVENT_IMAGE]];
    txtOccurDate.text = [Util getParseDate:event[PARSE_EVENT_START_DATE]];
    PFObject *venue = event[PARSE_EVENT_VENUE];
    venue = [venue fetchIfNeeded];
    labelName.text = [NSString stringWithFormat:@"%@ - %@", venue[PARSE_VENUE_NAME], event[PARSE_EVENT_NAME]];
    txtAddress.text = event[PARSE_EVENT_ADDRESS];
    PFGeoPoint *meLonLat = me[PARSE_USER_LOCATION];
    PFGeoPoint *eventLonLat = event[PARSE_EVENT_LOCATION];
    CLLocation *meLocation = [[CLLocation alloc] initWithLatitude:meLonLat.latitude longitude:meLonLat.longitude];
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:eventLonLat.latitude longitude:eventLonLat.longitude];
    CLLocationDistance distance = [meLocation distanceFromLocation:eventLocation];
    lblDistance.text = [NSString stringWithFormat:@"%d %@", (int)distance/1000, LOCALIZATION(@"kilometer_away")];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EventDetailsViewController *vc = (EventDetailsViewController *)[Util getUIViewControllerFromStoryBoard:@"EventDetailsViewController"];
    vc.object = [dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
