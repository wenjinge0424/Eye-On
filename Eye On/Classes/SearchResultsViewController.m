//
//  SearchResultsViewController.m
//  Eye On
//
//  Created by developer on 26/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "EventDetailsViewController.h"

@interface SearchResultsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tableview;
    IBOutlet UILabel *lblTitle;
    
    NSMutableArray *dataArray;
    UIRefreshControl *refreshControl;
    PFUser *me;
}
@end

@implementation SearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (void) configureLanguage {
    lblTitle.text = LOCALIZATION(@"search_results");
}

- (void) refreshItems {
    dataArray = [[NSMutableArray alloc] init];
    self.view.userInteractionEnabled = NO;
    [refreshControl beginRefreshing];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_EVENT];
    if (self.model.isHereNow){
        [query whereKey:PARSE_EVENT_NAME matchesRegex:self.model.searchName modifiers:@"i"];
        [query whereKey:PARSE_EVENT_LOCATION nearGeoPoint:me[PARSE_USER_LOCATION] withinKilometers:self.model.distance];
    } else if (self.model.isPlanning) {
        [query whereKey:PARSE_EVENT_ADDRESS matchesRegex:self.model.searchCity modifiers:@"i"];
        [query whereKey:PARSE_FIELD_CREATED_AT greaterThan:self.model.dateFrom];
        if (self.model.dateTo){
            [query whereKey:PARSE_FIELD_CREATED_AT lessThan:self.model.dateTo];
        }
    } else if (self.model.isActive){
        [query whereKey:PARSE_EVENT_END_DATE lessThan:self.model.dateTo];
    } else if (self.model.isComplete){
        [query whereKey:PARSE_EVENT_END_DATE greaterThanOrEqualTo:self.model.dateFrom];
    } else { // my events
        [query whereKey:PARSE_EVENT_OWNER equalTo:me];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        self.view.userInteractionEnabled = YES;
        [refreshControl endRefreshing];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *)objects;
            if (dataArray.count == 0){
                [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_search_result") finish:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            } else {
                [tableview reloadData];
            }
        }
    }];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    BOOL isRepeat = [event[PARSE_EVENT_IS_REPEAT] boolValue];
    if (isRepeat){
        txtOccurDate.text = [Util getOccurDays:event];
    } else {
        txtOccurDate.text = [Util getParseDate:event[PARSE_EVENT_START_DATE]];
    }
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
