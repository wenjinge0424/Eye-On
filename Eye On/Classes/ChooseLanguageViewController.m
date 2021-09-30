//
//  ChooseLanguageViewController.m
//  Eye On
//
//  Created by developer on 03/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "ChooseLanguageViewController.h"
#import "PagerViewController.h"
#import "Localisator.h"

@interface ChooseLanguageViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSMutableArray *languages;
    IBOutlet UIPickerView *pickerLanuage;
    NSInteger index;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnConfirm;
}
@end

@implementation ChooseLanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    index = 0;
    languages = [[NSMutableArray alloc] initWithObjects:LOCALIZATION(@"lng_chinese"), LOCALIZATION(@"lng_engligh"), LOCALIZATION(@"lng_thai"), nil];
    pickerLanuage.showsSelectionIndicator = NO;
    self.arrayOfLanguages = [[Localisator sharedInstance].availableLanguagesArray copy];
    
    NSString *lng = [Util getStringValueForKey:KEY_LANGUAGE];
    if ([lng isEqualToString:LANGUAGE_CHINESE]){
        [pickerLanuage selectRow:0 inComponent:0 animated:NO];
    } else if ([lng isEqualToString:LANGUAGE_ENGLISH]){
        [pickerLanuage selectRow:1 inComponent:0 animated:NO];
    } else if ([lng isEqualToString:LANGUAGE_THAI]) {
        [pickerLanuage selectRow:2 inComponent:0 animated:NO];
    } else {
        [pickerLanuage selectRow:1 inComponent:0 animated:NO];
    }
}

- (void) receiveLanguageChangedNotification:(NSNotification *) notification
{
    if ([notification.name isEqualToString:kNotificationLanguageChanged])
    {
        [self configureLanguage];
    }
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
    lblTitle.text = LOCALIZATION(@"choose_language");
    [btnConfirm setTitle:LOCALIZATION(@"confirm") forState:UIControlStateNormal];
}

- (IBAction)onConfirm:(id)sender {
    switch (index) {
        case 0: // chines
            [[Localisator sharedInstance] setLanguage:@"Chinese_zh-Hans"];
            [Util setStringValueForKey:KEY_LANGUAGE value:LANGUAGE_CHINESE];
            break;
        case 1: // english
            [[Localisator sharedInstance] setLanguage:@"English_en"];
            [Util setStringValueForKey:KEY_LANGUAGE value:LANGUAGE_ENGLISH];
            break;
        case 2: //thai
            [[Localisator sharedInstance] setLanguage:@"Thai_th"];
            [Util setStringValueForKey:KEY_LANGUAGE value:LANGUAGE_THAI];
            break;
        default: 
            
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 3;
}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [languages objectAtIndex:row];
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
}
- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    index = row;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    return 40;
}
@end
