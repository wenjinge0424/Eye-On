//
//  CreateEventOneViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "CreateEventOneViewController.h"
#import "CreateEventTwoViewController.h"
#import "AIDatePickerController.h"
#import "IQDropDownTextField.h"
#import "UsersListViewController.h"
#import "MyProfileViewController.h"
#import "MainViewController.h"

@interface CreateEventOneViewController ()<UITextFieldDelegate, IQDropDownTextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UIButton *btnNext;
    IBOutlet UITextField *txtEventName;
    IBOutlet UILabel *lblStart;
    IBOutlet UILabel *lblEnd;
    IBOutlet UILabel *lblRepeat;
    IBOutlet UILabel *lblNumberofWeeks;
    IBOutlet UILabel *lblDays;
    IBOutlet UILabel *lblPrivateEvent;
    IBOutlet UIButton *btnInvite;
    IBOutlet UILabel *lblInvite;
    
    
    IBOutlet UIButton *btnMonday;
    IBOutlet UIButton *btnTuesday;
    IBOutlet UIButton *btnWedneday;
    IBOutlet UIButton *btnThurday;
    IBOutlet UIButton *btnFriday;
    IBOutlet UIButton *btnSaturday;
    IBOutlet UIButton *btnSunday;
    
    IBOutlet UITextField *txtDateStart;
    IBOutlet UITextField *txtDateEnd;
    IBOutlet IQDropDownTextField *txtTimeStart;
    IBOutlet IQDropDownTextField *txtTimeEnd;
    IBOutlet IQDropDownTextField *txtNumberWeeks;
    
    NSDate *dateStart;
    NSDate *dateEnd;
    
    IBOutlet UISwitch *switchRepeat;
    IBOutlet UISwitch *switchPrivate;
    AIDatePickerController *datePickerViewController;
    IBOutlet UIImageView *imgEvent;
    BOOL hadPhoto;
}
@end

@implementation CreateEventOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    txtEventName.delegate = self;
    
    txtTimeStart.delegate = self;
    txtTimeEnd.delegate = self;
    txtNumberWeeks.itemList = [NSArray arrayWithObjects:@"1 week", @"2 weeks", @"3 weeks", @"4 weeks", @"5 weeks", @"6 weeks", @"7 weeks", @"8 weeks", @"9 weeks", @"10 weeks", @"11 weeks", @"12 weeks", @"No End Date", nil];
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
    lblTitle.text = LOCALIZATION(@"create_event_title");
    [btnNext setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    txtEventName.placeholder = LOCALIZATION(@"name_event");
    lblStart.text = LOCALIZATION(@"start");
    lblEnd.text = LOCALIZATION(@"end");
    lblRepeat.text = LOCALIZATION(@"repeat");
    lblNumberofWeeks.text = LOCALIZATION(@"numberweeks");
    lblDays.text = LOCALIZATION(@"days");
    lblPrivateEvent.text = LOCALIZATION(@"private_event");
    lblInvite.text = LOCALIZATION(@"invite_followers");
    
    [btnMonday setTitle:LOCALIZATION(@"monday") forState:UIControlStateNormal];
    [btnTuesday setTitle:LOCALIZATION(@"tuesday") forState:UIControlStateNormal];
    [btnWedneday setTitle:LOCALIZATION(@"wednesday") forState:UIControlStateNormal];
    [btnThurday setTitle:LOCALIZATION(@"thursday") forState:UIControlStateNormal];
    [btnFriday setTitle:LOCALIZATION(@"friday") forState:UIControlStateNormal];
    [btnSaturday setTitle:LOCALIZATION(@"saturday") forState:UIControlStateNormal];
    [btnSunday setTitle:LOCALIZATION(@"sunday") forState:UIControlStateNormal];
    
    [btnMonday setTitle:LOCALIZATION(@"monday") forState:UIControlStateSelected];
    [btnTuesday setTitle:LOCALIZATION(@"tuesday") forState:UIControlStateSelected];
    [btnWedneday setTitle:LOCALIZATION(@"wednesday") forState:UIControlStateSelected];
    [btnThurday setTitle:LOCALIZATION(@"thursday") forState:UIControlStateSelected];
    [btnFriday setTitle:LOCALIZATION(@"friday") forState:UIControlStateSelected];
    [btnSaturday setTitle:LOCALIZATION(@"saturday") forState:UIControlStateSelected];
    [btnSunday setTitle:LOCALIZATION(@"sunday") forState:UIControlStateSelected];
    
    txtTimeStart.dropDownMode = IQDropDownModeTimePicker;
    txtTimeEnd.dropDownMode = IQDropDownModeTimePicker;
}

- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    PFObject *eventObject = [PFObject objectWithClassName:PARSE_TABLE_EVENT];
    eventObject[PARSE_EVENT_OWNER] = [PFUser currentUser];
    eventObject[PARSE_EVENT_VENUE] = self.venueObeject;
    eventObject[PARSE_EVENT_START_DATE] = dateStart;
    eventObject[PARSE_EVENT_END_DATE] = dateEnd;
    eventObject[PARSE_EVENT_EMAIL] = self.venueObeject[PARSE_VENUE_EMAIL];
    eventObject[PARSE_EVENT_LOCATION] = self.venueObeject[PARSE_VENUE_LOCATION];
    eventObject[PARSE_EVENT_ADDRESS] = self.venueObeject[PARSE_VENUE_LOCATION_ADDRESS];
    eventObject[PARSE_EVENT_CONTACT_NUM] = self.venueObeject[PARSE_VENUE_CONTACT_NUM];
    eventObject[PARSE_EVENT_IS_MONDAY] = (btnMonday.isSelected)?@YES:@NO;
    eventObject[PARSE_EVENT_IS_TUESDAY] = (btnTuesday.isSelected)?@YES:@NO;
    eventObject[PARSE_EVENT_IS_WEDNESDAY] = (btnWedneday.isSelected)?@YES:@NO;
    eventObject[PARSE_EVENT_IS_THURSDAY] = (btnThurday.isSelected)?@YES:@NO;
    eventObject[PARSE_EVENT_IS_FRIDAY] = (btnFriday.isSelected)?@YES:@NO;
    eventObject[PARSE_EVENT_IS_SATURDAY] = (btnSaturday.isSelected)?@YES:@NO;
    eventObject[PARSE_EVENT_IS_SUNDAY] = (btnSunday.isSelected)?@YES:@NO;
    eventObject[PARSE_EVENT_IS_REPEAT] = (switchRepeat.isOn)?@YES:@NO;
    eventObject[PARSE_EVENT_NAME] = txtEventName.text;
    if (switchRepeat.isOn && txtNumberWeeks.selectedItem){
        if (txtNumberWeeks.selectedRow == 12){
            eventObject[PARSE_EVENT_WEEKCOUNT] = [NSNumber numberWithInteger:54];
        }
        eventObject[PARSE_EVENT_WEEKCOUNT] = [NSNumber numberWithInteger:(txtNumberWeeks.selectedRow+1)];
    }
    if (switchRepeat.isOn){
        NSInteger count = txtNumberWeeks.selectedRow+1;
        eventObject[PARSE_EVENT_CALC_END_DATE] = [Util getDateAfterWeeks:count :dateStart];
    }
    eventObject[PARSE_EVENT_IS_PRIVATE] = (switchPrivate.isOn)?@YES:@NO;
    
    CreateEventTwoViewController *vc = (CreateEventTwoViewController *)[Util getUIViewControllerFromStoryBoard:@"CreateEventTwoViewController"];
    vc.eventObject = eventObject;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onback:(id)sender {
//#ifdef DEBUG
    for (UIViewController *vc in self.navigationController.viewControllers){
        if ([vc isKindOfClass:[MainViewController class]]){
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
//#else
//    [self.navigationController popViewControllerAnimated:YES];
//#endif
    
}

- (BOOL) isValid {
    txtEventName.text = [Util trim:txtEventName.text];
    if (!dateStart || !dateEnd || !txtTimeStart.selectedItem || !txtTimeEnd.selectedItem){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_date_time") finish:^{
            
        }];
        return NO;
    }
    if ([dateStart compare:dateEnd] == NSOrderedAscending){
        if (!dateStart || !dateEnd || !txtTimeStart.selectedItem || !txtTimeEnd.selectedItem){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"invalid_time") finish:^{
                
            }];
            return NO;
        }
    }
    
    dateStart = [Util setTimeforDate:dateStart :txtTimeStart.selectedItem];
    dateEnd = [Util setTimeforDate:dateEnd :txtTimeEnd.selectedItem];
    
//    if ([Util getDifferenceHours:dateStart :dateEnd]>=24 || [Util getDifferenceHours:dateStart :dateEnd]<=0){
//        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"invalid_entry") finish:^{
//            
//        }];
//        return NO;
//    }
    
    NSString *eventname = txtEventName.text;
    if (eventname.length == 0){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_event_name") finish:^{
            [txtEventName becomeFirstResponder];
        }];
        return NO;
    }
    if (eventname.length > 35){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"long_event_name") finish:^{
            [txtEventName becomeFirstResponder];
        }];
    }
    return YES;
}

- (IBAction)onEventImage:(id)sender {
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"camera") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onTakePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"gallery") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onChoosePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}

- (void)onChoosePhoto:(id)sender {
    if (![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)onTakePhoto:(id)sender {
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    hadPhoto = YES;
    [imgEvent setImage:image];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
}


- (IBAction)onWeekDayClicked:(id)sender {
    if (!switchRepeat.isOn){
        return;
    }
    UIButton *button = [self.view viewWithTag:[sender tag]];
    button.selected = !button.selected;
}

- (IBAction)onInvite:(id)sender {
    if (!switchPrivate.isOn){
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    UsersListViewController *vc = (UsersListViewController *)[Util getUIViewControllerFromStoryBoard:@"UsersListViewController"];
    vc.venue = self.venueObeject;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onDate:(id)sender {
    NSInteger tag = [sender tag]; // 1: from, 2: to
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [NSDate date];
    
    // Create an instance of the picker
    datePickerViewController = [AIDatePickerController pickerWithDate:date selectedBlock:^(NSDate *selectedDate) {
        [datePickerViewController dismissViewControllerAnimated:YES completion:nil];
        if ([selectedDate compare:date] == NSOrderedAscending){
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"invalid_date")];
            return;
        }
        if (tag == 100){
            txtDateStart.text = [dateFormatter stringFromDate:selectedDate];
            dateStart = selectedDate;
        } else if (tag == 101){
            txtDateEnd.text = [dateFormatter stringFromDate:selectedDate];
            dateEnd = selectedDate;
        }
        if (dateStart && dateEnd){
            if ([dateStart compare:dateEnd] == NSOrderedDescending){// start is later than end
                
            }
        }
    } cancelBlock:^{
        [datePickerViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    // Present it
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}

- (IBAction)onSwithRepeat:(id)sender {
    txtNumberWeeks.enabled = switchRepeat.isOn;
}
- (IBAction)onSwitchPrivate:(id)sender {
    if (!switchPrivate.isOn){
        lblInvite.textColor = [UIColor lightGrayColor];
        btnInvite.enabled = NO;
    } else {
        lblInvite.textColor = [UIColor blackColor];
        btnInvite.enabled = YES;
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

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == txtEventName){
        textField.text = @"";
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (textField == txtTimeStart){
        
    }
}

@end
