//
//  CurrencyViewController.m
//  Eye On
//
//  Created by developer on 28/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "CurrencyViewController.h"

@interface CurrencyViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UILabel *lblTitle;
    NSMutableDictionary *dataArray;
    UIRefreshControl *refreshControl;
    IBOutlet UITableView *tableview;
    
    NSMutableArray *currencyArray;
    NSMutableArray *countryArray;
    
    NSMutableArray *selectedArray;
}
@end

@implementation CurrencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = MAIN_COLOR;
//    [refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
//    [tableview addSubview:refreshControl];
    [self refreshItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguage];
}

- (void)configureLanguage {
    
}

- (void) refreshItems {
    dataArray = [[NSMutableDictionary alloc] init];
    currencyArray = [[NSMutableArray alloc] init];
    countryArray = [[NSMutableArray alloc] init];
    selectedArray = [[NSMutableArray alloc] init];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [HttpAPI sendRequestWithURL:CURRENCY_ALL_LIST paramDic:nil completionBlock:^(NSDictionary *result, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            BOOL isSuccess = (BOOL) result[@"success"];
            if (!isSuccess){
                NSDictionary *errorInfo = result[@"error"];
                [Util showAlertTitle:self title:errorInfo[@"code"] message:errorInfo[@"info"]];
            } else {
                dataArray = (NSMutableDictionary *)result[@"currencies"]; // dictionary
                NSArray *keys = [[dataArray allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
                for (NSString *key in keys){
                    [currencyArray addObject:key];
                }
                for (int i=0;i<currencyArray.count;i++){
                    [countryArray addObject:[dataArray objectForKey:currencyArray[i]]];
                }
                if ([Util getStringValueForKey:KEY_CURRENCY].length == 0){ // set default currency USD
                    [selectedArray addObject:[NSNumber numberWithUnsignedInteger:[currencyArray indexOfObject:@"USD"]]];
                } else {
                    [selectedArray addObject:[NSNumber numberWithUnsignedInteger:[currencyArray indexOfObject:[Util getStringValueForKey:KEY_CURRENCY]]]];
                }
                [tableview reloadData];
            }
        }
    }];
}

- (IBAction)onback:(id)sender {
    if (selectedArray.count>0){
        int row = [[selectedArray objectAtIndex:0] intValue];
        [Util setStringValueForKey:KEY_CURRENCY value:[currencyArray objectAtIndex:row]];
    }
    NSLog(@"%@", [Util getStringValueForKey:KEY_CURRENCY]);
//   @"http://apilayer.net/api/convert?access_key=c8570c52636423004dc086eb1cfdc382&from=USD&to="
    NSString *convertUrl = [NSString stringWithFormat:@"%@%@&amount=1", CURRENCY_GET_RATE, [Util getStringValueForKey:KEY_CURRENCY]];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [HttpAPI sendRequestWithURL:convertUrl paramDic:nil completionBlock:^(NSDictionary *result, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            BOOL isSuccess = (BOOL) result[@"success"];
            if (!isSuccess){
                NSDictionary *errorInfo = result[@"error"];
                [Util showAlertTitle:self title:errorInfo[@"code"] message:errorInfo[@"info"]];
            } else {
                double rate = [result[@"result"] doubleValue];
                NSLog(@"%f", rate);
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellCurrency"];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    UIImageView *img = (UIImageView *)[cell viewWithTag:2];
    NSString *value = [NSString stringWithFormat:@"%@ - %@", [currencyArray objectAtIndex:indexPath.row], [countryArray objectAtIndex:indexPath.row]];
    label.text = value;
    if ([selectedArray containsObject:[NSNumber numberWithInteger:indexPath.row]]){
        img.hidden = NO;
    } else {
        img.hidden = YES;
    }
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    selectedArray = [[NSMutableArray alloc] init];
    [selectedArray addObject:[NSNumber numberWithInteger:indexPath.row]];
    UIImageView *img = (UIImageView *)[cell viewWithTag:2];
    img.hidden = NO;
    [self updateTableView:indexPath];
}

- (void) updateTableView:(NSIndexPath *) indexPath {
    for (int i=0;i<dataArray.count;i++){
        UITableViewCell *cell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UIImageView *img = (UIImageView *)[cell viewWithTag:2];
        if ([selectedArray containsObject:[NSNumber numberWithInt:i]]){
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
}

@end
