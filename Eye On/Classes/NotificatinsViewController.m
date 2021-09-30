//
//  NotificatinsViewController.m
//  Eye On
//
//  Created by developer on 23/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "NotificatinsViewController.h"

@interface NotificatinsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UILabel *lblNotifications;
    
    IBOutlet UITableView *tableview;
    NSMutableArray *dataArray;
    PFUser *me;
    UIRefreshControl *refreshControl;
}
@end

@implementation NotificatinsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataArray = [[NSMutableArray alloc] init];
    me = [PFUser currentUser];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = MAIN_COLOR;
    [refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
    [tableview addSubview:refreshControl];
    
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
    lblNotifications.text = LOCALIZATION(@"notifications");
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellUser"];
    UIImageView *avtar = (UIImageView *)[cell viewWithTag:1];
    UITextView *lblName = (UITextView *)[cell viewWithTag:2];
    PFObject *obj = [dataArray objectAtIndex:indexPath.row];
    PFUser *sender = obj[PARSE_NOTIFICATION_FROM_USER];
    [sender fetchIfNeeded];
    [Util setImage:avtar imgFile:(PFFile *)sender[PARSE_USER_AVATAR]];
    lblName.text = obj[PARSE_NOTIFICATION_MESSAGE];
    
    return cell;
}

- (void) refreshItems {
    dataArray = [[NSMutableArray alloc] init];
    self.view.userInteractionEnabled = NO;
    [refreshControl beginRefreshing];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
    [query whereKey:PARSE_NOTIFICATION_TO_USER equalTo:me];
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

@end
