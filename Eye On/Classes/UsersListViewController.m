//
//  UsersListViewController.m
//  Eye On
//
//  Created by developer on 23/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "UsersListViewController.h"

@interface UsersListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UILabel *lblUsers;
    IBOutlet UITableView *tableview;
    
    NSMutableArray *dataArray;
    PFUser *me;
    UIRefreshControl *refreshControl;
    
    NSMutableArray *selectedIndex;
}
@end

@implementation UsersListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataArray = [[NSMutableArray alloc] init];
    selectedIndex = [[NSMutableArray alloc] init];
    me = [PFUser currentUser];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = MAIN_COLOR;
//    [refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
//    [tableview addSubview:refreshControl];
    
    [self refreshItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void) configureLanguage {
    lblUsers.text = LOCALIZATION(@"Users");
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) refreshItems {
    dataArray = [[NSMutableArray alloc] init]; // followers Array
    
    NSArray *users = self.venue[PARSE_VENUE_FOLLOWERS];
    for (int i=0;i<users.count;i++){
        PFUser *user = [users objectAtIndex:i];
        user = [user fetchIfNeeded];
        [dataArray addObject:user];
    }
    [SVProgressHUD dismiss];
    [tableview reloadData];
//    self.view.userInteractionEnabled = NO;
//    [refreshControl beginRefreshing];
//    PFQuery *query = [PFUser query];
//    [query whereKey:PARSE_NOTIFICATION_TO_USER notEqualTo:me];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//        self.view.userInteractionEnabled = YES;
//        [refreshControl endRefreshing];
//        if (error){
//            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
//        } else {
//            dataArray = (NSMutableArray *)objects;
//            [tableview reloadData];
//        }
//    }];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellUser"];
    UIImageView *avatar = (UIImageView *)[cell viewWithTag:1];
    UILabel *txtName = (UILabel *)[cell viewWithTag:2];
    UIImageView *imgCheck = (UIImageView *)[cell viewWithTag:3];
    if ([selectedIndex containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        imgCheck.hidden = NO;
    } else {
        imgCheck.hidden = YES;
    }
    PFUser *user = [dataArray objectAtIndex:indexPath.row];
    user = [user fetchIfNeeded];
    [Util setImage:avatar imgFile:(PFFile *)user[PARSE_USER_AVATAR]];
    NSString *name = user[PARSE_USER_FULL_NAME];
    txtName.text = (name.length>0)?name:user.username;
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([selectedIndex containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        [selectedIndex removeObject:[NSNumber numberWithInteger:indexPath.row]];
    } else {
        [selectedIndex addObject:[NSNumber numberWithInteger:indexPath.row]];
    }
    UIImageView *imgCheck = (UIImageView *)[cell viewWithTag:3];
    if ([selectedIndex containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        imgCheck.hidden = NO;
    } else {
        imgCheck.hidden = YES;
    }
}

- (IBAction)onSend:(id)sender {
    if (selectedIndex.count == 0){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"choose_users")];
    } else {
        NSMutableArray *userIdList = [[NSMutableArray alloc] init];
        for (int i=0;i<selectedIndex.count;i++){
            NSInteger row = [[selectedIndex objectAtIndex:i] integerValue];
            [userIdList addObject:[dataArray objectAtIndex:row]];
        }
        [Util sendPushNotification:[NSString stringWithFormat:@"%d", NOTIFICATION_TYPE_INVITE] receiverList:userIdList dataInfo:nil];
        [self onback:self];
    }
}

@end
