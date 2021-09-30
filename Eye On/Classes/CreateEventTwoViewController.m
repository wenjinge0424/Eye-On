//
//  CreateEventTwoViewController.m
//  Eye On
//
//  Created by developer on 05/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "CreateEventTwoViewController.h"
#import "CreateEventThreeViewController.h"

@interface CreateEventTwoViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblTheme;
    
    IBOutlet UIButton *btnNExt;
    IBOutlet UIButton *btnAddmore;
    IBOutlet UILabel *lblDesc;
    IBOutlet UITableView *tableview;
    
    IBOutlet UILabel *lblOfferTitle;
    IBOutlet UILabel *lblOfferQty;
    int counts;
}
@end

@implementation CreateEventTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    counts = 0;
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
    lblTheme.text = LOCALIZATION(@"create_offer");
    [btnNExt setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    lblDesc.text = LOCALIZATION(@"add_offer_desc");
    [btnAddmore setTitle:LOCALIZATION(@"add_more") forState:UIControlStateNormal];
    lblOfferTitle.text = LOCALIZATION(@"offer_title");
    lblOfferQty.text = LOCALIZATION(@"qty");
}
- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    
    CreateEventThreeViewController *vc = (CreateEventThreeViewController *)[Util getUIViewControllerFromStoryBoard:@"CreateEventThreeViewController"];
    if (counts > 0){
        NSMutableArray *titleArray = [[NSMutableArray alloc] init];
        NSMutableArray *qtyArray = [[NSMutableArray alloc] init];
        for (int i=0;i<counts;i++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *cell = [tableview cellForRowAtIndexPath:indexPath];
            UITextField *txtOfferTitle = (UITextField *)[cell viewWithTag:1];
            UITextField *txtQty = (UITextField *)[cell viewWithTag:2];
            NSString *title = [Util trim:txtOfferTitle.text];
            NSString *quanty = [Util trim:txtQty.text];
            [titleArray addObject:title];
            [qtyArray addObject:quanty];
        }
        vc.titleArray = titleArray;
        vc.qtyArray = qtyArray;
    }
    vc.eventObject = self.eventObject;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) gotoNextSceen {
    
}

- (BOOL) isValid {
    for (int i=0;i<counts;i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [tableview cellForRowAtIndexPath:indexPath];
        UITextField *txtOfferTitle = (UITextField *)[cell viewWithTag:1];
        UITextField *txtQty = (UITextField *)[cell viewWithTag:2];
        NSString *title = [Util trim:txtOfferTitle.text];
        NSString *quanty = [Util trim:txtQty.text];
        if (title.length < 6){
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"short_offer_title") finish:^{
                
            }];
            return NO;
        } else if (title.length > 35){
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"long_offer_title") finish:^{
                
            }];
            return NO;
        }
        if (quanty.length == 0){
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_qty") finish:^{
                
            }];
            return NO;
        }
    }
    return YES;
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAdd:(id)sender {
    NSInteger count = [tableview numberOfRowsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
    [tableview beginUpdates];
    [tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cellOffer"];
    UITextField *txtOfferTitle = (UITextField *)[cell viewWithTag:1];
    UITextField *txtQty = (UITextField *)[cell viewWithTag:2];
    txtOfferTitle.delegate = self;
    txtQty.delegate = self;
    txtOfferTitle.text = @"";
    txtQty.text = @"";
    counts++;
    [tableview endUpdates];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOffer"];
    UITextField *txtOfferTitle = (UITextField *)[cell viewWithTag:1];
    UITextField *txtQty = (UITextField *)[cell viewWithTag:2];
    txtOfferTitle.placeholder = LOCALIZATION(@"offer_title");
    txtQty.placeholder = LOCALIZATION(@"qty");
    txtQty.delegate = self;
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return counts;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView  editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    return UITableViewCellEditingStyleDelete; //enable when editing mode is on
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [tableview beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        counts--;
        [tableview endUpdates];
    }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 2){
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= 4 || returnKey;
    }
    return YES;
}

@end
