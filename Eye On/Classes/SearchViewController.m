//
//  SearchViewController.m
//  Eye On
//
//  Created by developer on 26/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SearchViewController.h"
#import "MainViewController.h"
#import "SearchResultsViewController.h"
#import "AIDatePickerController.h"
#import "SearchModel.h"

@interface SearchViewController ()<UITextFieldDelegate, UISearchBarDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblTitleHeaderOne;
    IBOutlet UILabel *lblTitleHeaderTwo;
    IBOutlet UISearchBar *searchBar;
    IBOutlet UISlider *sliderDistance;
    
    IBOutlet UILabel *lblTitleHeaderThree;
    IBOutlet UILabel *lblTitleHeaderFour;
    IBOutlet UITextField *txtCity;
    IBOutlet UITextField *txtDateFrom;
    IBOutlet UITextField *txtDateTo;
    IBOutlet UIButton *btnSearch;
    IBOutlet UILabel *lblSearchDesc;
    AIDatePickerController *datePickerViewController;
    
    NSDate *dateFrom;
    NSDate *dateTo;
    SearchModel *model;
    
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    searchBar.delegate = self;
    txtCity.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguage];
}

- (void) configureLanguage {
    lblTitle.text = LOCALIZATION(@"search_events");
    lblTitleHeaderOne.text = LOCALIZATION(@"here_now");
    lblTitleHeaderTwo.text = LOCALIZATION(@"find_events_desc");
    lblTitleHeaderThree.text = LOCALIZATION(@"plan_ahead");
    lblTitleHeaderFour.text = LOCALIZATION(@"look_for_events");
    
    searchBar.placeholder = LOCALIZATION(@"search_for_event");
    lblSearchDesc.text = [NSString stringWithFormat:@"%@: %.f km", LOCALIZATION(@"search_radius"), sliderDistance.value];
    txtCity.placeholder = LOCALIZATION(@"enter_city");
    txtDateFrom.placeholder = LOCALIZATION(@"date_from");
    txtDateTo.placeholder = LOCALIZATION(@"date_to");
    
    [btnSearch setTitle:LOCALIZATION(@"go") forState:UIControlStateNormal];
}
- (IBAction)onDate:(UIButton *)sender {
    [self inactiveHereAndNow];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [NSDate date];
    
    // Create an instance of the picker
    datePickerViewController = [AIDatePickerController pickerWithDate:date selectedBlock:^(NSDate *selectedDate) {
        if ([sender tag] == 1){ // date from
            txtDateFrom.text = [dateFormatter stringFromDate:selectedDate];
            dateFrom = selectedDate;
        } else if ([sender tag] == 2){ // date to
            txtDateTo.text = [dateFormatter stringFromDate:selectedDate];
            dateTo = selectedDate;
        }
        [datePickerViewController dismissViewControllerAnimated:YES completion:nil];
    } cancelBlock:^{
        [datePickerViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    // Present it
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}

- (IBAction)changeSlider:(id)sender {
    lblSearchDesc.text = [NSString stringWithFormat:@"%@: %.f km", LOCALIZATION(@"search_radius"), sliderDistance.value];
}

- (void) activeHereAndNow {
    searchBar.text = @"";
    sliderDistance.enabled = YES;
    
    txtCity.textColor = [UIColor grayColor];
    txtDateFrom.textColor = [UIColor grayColor];
    txtDateTo.textColor = [UIColor grayColor];
}

- (void) inactiveHereAndNow {
    searchBar.text = @"";
    sliderDistance.enabled = NO;
    
    txtCity.textColor = [UIColor blackColor];
    txtDateTo.textColor = [UIColor blackColor];
    txtDateFrom.textColor = [UIColor blackColor];    
}

- (void) activePlanningAhead {
    txtDateFrom.text = @"";
    txtDateTo.text = @"";
    dateFrom = [[NSDate alloc] init];
    dateTo = [[NSDate alloc] init];
    dateFrom = nil;
    dateTo = nil;
    txtCity.textColor = [UIColor blackColor];
    txtDateTo.textColor = [UIColor blackColor];
    txtDateFrom.textColor = [UIColor blackColor];
    
    sliderDistance.enabled = NO;
}

- (BOOL) isValid {
    if (sliderDistance.isEnabled){ // here and now
        searchBar.text = [Util trim:searchBar.text];
        NSString *name = searchBar.text;
        if (name.length == 0 || sliderDistance.value == 0){
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_name") finish:^{
                
            }];
            return NO;
        }
        model = [[SearchModel alloc] init];
        model.isHereNow = YES;
        model.isPlanning = NO;
        model.isActive = NO;
        model.isComplete = NO;
        model.distance = sliderDistance.value;
        model.searchName = name;
    } else { // planning ahead
        txtCity.text = [Util trim:txtCity.text];
        NSString *city = txtCity.text;
        if (city.length == 0 || !dateFrom){
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_city") finish:^{
                
            }];
            return NO;
        }
        model = [[SearchModel alloc] init];
        model.isHereNow = NO;
        model.isActive = NO;
        model.isComplete = NO;
        model.isPlanning = YES;
        model.searchCity = city;
        model.dateFrom = dateFrom;
        if (dateTo){
            model.dateTo = dateTo;
        }
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onMenu:(id)sender {
    [[MainViewController getInstance] showSideMenu];
}
- (IBAction)onSearch:(id)sender {
    if (![self isValid]){
        return;
    }
    SearchResultsViewController *vc = (SearchResultsViewController *)[Util getUIViewControllerFromStoryBoard:@"SearchResultsViewController"];
    vc.model = model;
    [[MainViewController getInstance] pushViewController:vc];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == txtCity){
        txtCity.text = @"";
        [self activePlanningAhead];
    }
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self activeHereAndNow];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self onSearch:nil];
}

@end
