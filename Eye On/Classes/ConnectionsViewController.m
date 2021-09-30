//
//  ConnectionsViewController.m
//  Eye On
//
//  Created by developer on 26/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "EventDetailsViewController.h"
#import "MainViewController.h"
#import "HTHorizontalSelectionList.h"

@interface ConnectionsViewController ()<UITableViewDelegate, UITableViewDataSource, HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource>
{
    IBOutlet UIView *viewSavedEvents;
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UITableView *tableview;
    
    NSMutableArray *dataArray;
    PFUser *me;
    PFObject *myVenue;
    
    UIRefreshControl *refreshControl;
    IBOutlet HTHorizontalSelectionList *topbarList;
    
    NSMutableArray *menu;
    IBOutlet UIView *viewTitle;
    IBOutlet UILabel *lblNoResult;
}
@end

@implementation ConnectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    me = [PFUser currentUser];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = MAIN_COLOR;
    [refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
    [tableview addSubview:refreshControl];
    
    topbarList.delegate = self;
    topbarList.dataSource = self;
    
    topbarList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    topbarList.selectionIndicatorColor = [UIColor darkGrayColor];
    topbarList.backgroundColor = MAIN_TRANS_COLOR;
    viewTitle.backgroundColor = MAIN_TRANS_COLOR;
    
    [topbarList setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [topbarList setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [topbarList setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [topbarList setTitleFont:[UIFont systemFontOfSize:15] forState:UIControlStateNormal];
    [topbarList setTitleFont:[UIFont boldSystemFontOfSize:16] forState:UIControlStateSelected];
    [topbarList setTitleFont:[UIFont boldSystemFontOfSize:16] forState:UIControlStateHighlighted];
    
    menu = [[NSMutableArray alloc] initWithObjects:LOCALIZATION(@"saved_events"), LOCALIZATION(@"venue_followers"), nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanuagues];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self checkPaid];
}

- (void) configureLanuagues {
    lblTitle.text = LOCALIZATION(@"connections");
}

- (IBAction)onChangeSegment:(id)sender {
    tableview.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
    [self refreshItems];
}

- (void) checkPaid {
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_VENUE];
    [query whereKey:PARSE_VENUE_OWNER equalTo:me];
    [query whereKey:PARSE_VENUE_AVAILABLE equalTo:@YES];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            if (objects.count >0){
                myVenue = [objects objectAtIndex:0];
            } else{
            }
            tableview.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
            [self refreshItems];
        }
    }];
}

- (void) refreshItems {
    lblNoResult.hidden = YES;
    dataArray = [[NSMutableArray alloc] init];
    if (topbarList.selectedButtonIndex == 0){
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_EVENT];
        [query whereKey:PARSE_EVENT_SAVER_UESRS equalTo:me];
        [refreshControl beginRefreshing];
        self.view.userInteractionEnabled = NO;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            [refreshControl endRefreshing];
            self.view.userInteractionEnabled = YES;
            if (error) {
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            } else {
                dataArray = (NSMutableArray *) objects;
                if (dataArray.count == 0){
                    lblNoResult.text = LOCALIZATION(@"no_saved_events");
                    lblNoResult.hidden = NO;
                }
                [tableview reloadData];
            }
        }];
    } else if (topbarList.selectedButtonIndex == 1){
        if (!myVenue){
            lblNoResult.text = LOCALIZATION(@"no_followers");
            lblNoResult.hidden = NO;
            [tableview reloadData];
            return;
        }
        [refreshControl beginRefreshing];
        self.view.userInteractionEnabled = NO;
        [myVenue fetchInBackgroundWithBlock:^(PFObject *obj, NSError *error){
            [refreshControl endRefreshing];
            self.view.userInteractionEnabled = YES;
            if (error){
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            } else {
                myVenue = obj;
                dataArray = myVenue[PARSE_VENUE_FOLLOWERS];
                [tableview reloadData];
            }
        }];
        
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (topbarList.selectedButtonIndex == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellEvent"];
        PFObject *event = [dataArray objectAtIndex:indexPath.row];
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        label.text = event[PARSE_EVENT_NAME];
    } else if (topbarList.selectedButtonIndex == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellUser"];
        PFUser *user = [dataArray objectAtIndex:indexPath.row];
        user = [user fetchIfNeeded];
        [dataArray replaceObjectAtIndex:indexPath.row withObject:user];
        UIImageView *imgAvatar = (UIImageView *)[cell viewWithTag:1];
        UILabel *label = (UILabel *)[cell viewWithTag:2];
        [Util setImage:imgAvatar imgFile:(PFFile *)user[PARSE_USER_AVATAR]];
        NSString *fullname = user[PARSE_USER_FULL_NAME];
        if (fullname.length>0){
            label.text = fullname;
        } else {
            label.text = user.username;
        }
    }
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (topbarList.selectedButtonIndex == 0){ // event
        EventDetailsViewController *vc = (EventDetailsViewController *)[Util getUIViewControllerFromStoryBoard:@"EventDetailsViewController"];
        vc.object = [dataArray objectAtIndex:indexPath.row];
        [[MainViewController getInstance] pushViewController:vc];
    } else { // follower
        PFUser *user = [dataArray objectAtIndex:indexPath.row];
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView  editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    return UITableViewCellEditingStyleDelete; //enable when editing mode is on
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (topbarList.selectedButtonIndex == 0)
        return YES;
    else
        return NO;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LOCALIZATION(@"unsave");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (topbarList.selectedButtonIndex == 0){ // unsave event
            PFObject *event = [dataArray objectAtIndex:indexPath.row];
            NSMutableArray *users = event[PARSE_EVENT_SAVER_UESRS];
            for (int i=0;i<users.count;i++){
                PFObject *obj = [users objectAtIndex:i];
                if ([obj.objectId isEqualToString:me.objectId]){
                    [users removeObject:obj];
                    break;
                }
            }
            event[PARSE_EVENT_SAVER_UESRS] = users;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            [event saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                [SVProgressHUD dismiss];
                if (succeed && !error){
                    [tableview beginUpdates];
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationRight];
                    [dataArray removeObjectAtIndex:indexPath.row];
                    [tableview endUpdates];
                } else {
                    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
                }
            }];
        } else if (topbarList.selectedButtonIndex == 1){// unfollow event
            
        }
    }
}

- (NSInteger) numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList{
    return menu.count;
}

- (void) selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    tableview.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
    [self refreshItems];
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    return [menu objectAtIndex:index];
}

@end
