//
//  VenuesViewController.m
//  Eye On
//
//  Created by developer on 26/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "VenuesViewController.h"
#import "VenusDetailViewController.h"
#import "MainViewController.h"

@interface VenuesViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tableview;
    
    IBOutlet UILabel *lblTitle;
    PFUser *me;
    
    UIRefreshControl *refreshControl;
    NSMutableArray *dataArray;
    IBOutlet UITextView *lblNoResult;
}
@end

@implementation VenuesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableview.delegate = self;
    tableview.dataSource = self;
    me = [PFUser currentUser];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = MAIN_COLOR;
    [refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
    [tableview addSubview:refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureLanguage];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    tableview.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
    [self refreshItems];
}

- (void) configureLanguage
{
    lblTitle.text = LOCALIZATION(@"venues_followed");
    lblNoResult.text = LOCALIZATION(@"no_result_venue_followed");
}

- (void) refreshItems {
    lblNoResult.hidden = YES;
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_VENUE];
    [query whereKey:PARSE_VENUE_FOLLOWERS equalTo:me];
    [query whereKey:PARSE_VENUE_AVAILABLE equalTo:@YES];
    [query whereKey:PARSE_VENUE_MUTE_LIST notEqualTo:me];
    self.view.userInteractionEnabled = NO;
    [refreshControl beginRefreshing];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [refreshControl endRefreshing];
        self.view.userInteractionEnabled = YES;
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *) objects;
            if (dataArray.count == 0){
                lblNoResult.hidden = NO;
            }
            [tableview reloadData];
        }
    }];
}

- (IBAction)onMenu:(id)sender {
    [[MainViewController getInstance] showSideMenu];
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

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellVenue"];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    PFObject *venue = [dataArray objectAtIndex:indexPath.row];
    label.text = venue[PARSE_VENUE_NAME];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VenusDetailViewController *vc = (VenusDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"VenusDetailViewController"];
    vc.object = [dataArray objectAtIndex:indexPath.row];
    [[MainViewController getInstance] pushViewController:vc];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView  editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LOCALIZATION(@"unfollow");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *venue = [dataArray objectAtIndex:indexPath.row];
        NSMutableArray *users = venue[PARSE_VENUE_FOLLOWERS];
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
                [tableview beginUpdates];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationRight];
                [dataArray removeObjectAtIndex:indexPath.row];
                [tableview endUpdates];
            } else {
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            }
        }];
    }
}


@end
