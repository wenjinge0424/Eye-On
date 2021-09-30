//
//  ViewOffersViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "ViewOffersViewController.h"
#import "OfferQRViewController.h"

@interface ViewOffersViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblSubtitle;
    IBOutlet UITableView *tableview;
    
    NSMutableArray *dataArray;
    UIRefreshControl *refreshControl;
    
    PFUser *me;
}
@end

@implementation ViewOffersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = MAIN_COLOR;
    [refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
    [tableview addSubview:refreshControl];
    
    lblSubtitle.text = self.object[PARSE_EVENT_NAME];
    me = [PFUser currentUser];
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

- (void) configureLanguage {
    lblTitle.text = LOCALIZATION(@"view_offer");
}

- (void) refreshItems {
    dataArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_OFFER];
    [query whereKey:PARSE_OFFER_EVENT equalTo:self.object];
    [refreshControl beginRefreshing];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [refreshControl endRefreshing];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *) objects;
            [tableview reloadData];
        }
    }];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onReport:(id)sender {
    [self onReport:self.object type:REPORT_TYPE_EVENT];
}

- (void)checkButtonTapped:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableview];
    NSIndexPath *indexPath = [tableview indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        PFObject *obj = [dataArray objectAtIndex:indexPath.row];
        NSInteger redeemCount = 0;
        NSMutableArray *redeemUsers = obj[PARSE_OFFER_REDEEM_USERS];
        redeemCount = redeemUsers.count;
        [redeemUsers addObject:me];
        if (!redeemUsers){
            redeemUsers = [[NSMutableArray alloc] init];
        }
        obj[PARSE_OFFER_REDEEM_USERS] = redeemUsers;
        NSInteger quanty = [obj[PARSE_OFFER_QUANTY] integerValue];
        NSInteger left = quanty - redeemCount;
        if (left <= 0){
            return;
        }
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            } else {
                OfferQRViewController *vc = (OfferQRViewController *)[Util getUIViewControllerFromStoryBoard:@"OfferQRViewController"];
                vc.object = obj[PARSE_OFFER_EVENT];
                [self.navigationController pushViewController:vc animated:YES];                
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
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOffer"];
    UITextView *txtTitle = (UITextView *)[cell viewWithTag:1];
    UIButton *buttonRedeem = (UIButton *)[cell viewWithTag:2];
    UILabel *lblRedeemCount = (UILabel *)[cell viewWithTag:3];
    UILabel *lblLeftCount = (UILabel *)[cell viewWithTag:4];
    
    [buttonRedeem setTitle:LOCALIZATION(@"redeem") forState:UIControlStateNormal];
    [buttonRedeem addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    PFObject *object = [dataArray objectAtIndex:indexPath.row];
    txtTitle.text = object[PARSE_OFFER_TITLE];
    NSArray *redeemUsers = object[PARSE_OFFER_REDEEM_USERS];
    for (int i=0;i<redeemUsers.count;i++){
        PFObject *obj = [redeemUsers objectAtIndex:i];
        if ([obj.objectId isEqualToString:me.objectId]){
            [buttonRedeem setEnabled:NO];
            break;
        }
    }
    NSInteger redeemCount = redeemUsers.count;
    NSInteger quanty = [object[PARSE_OFFER_QUANTY] integerValue];
    NSInteger left = quanty - redeemCount;
    if (left <= 0){
        [buttonRedeem setEnabled:NO];
    }
    lblRedeemCount.text = [NSString stringWithFormat:@"%@ %ld %@", LOCALIZATION(@"redem_header"), (long)redeemCount, LOCALIZATION(@"times")];
    lblLeftCount.text = [NSString stringWithFormat:@"%@ %ld %@", LOCALIZATION(@"hurry"), (long)left, LOCALIZATION(@"left")];
    return cell;
}
@end
