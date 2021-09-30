//
//  CategoryViewController.m
//  Eye On
//
//  Created by developer on 03/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "MFSideMenuContainerViewController.h"
#import "SideMenuViewController.h"
#import "CategoryViewController.h"
#import "SubCategoriesViewController.h"

@interface CategoryViewController ()
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnDone;
    IBOutlet UILabel *lblDesc;
    
    IBOutlet UIButton *btnRestaurant;
    IBOutlet UIButton *btnMusic;
    IBOutlet UIButton *btnBars;
    IBOutlet UIButton *btnSports;
    IBOutlet UIButton *btnCafe;
    IBOutlet UIButton *btnHotel;
    IBOutlet UIButton *btnNetworking;
    IBOutlet UIButton *btnClub;
    
    IBOutlet UIButton *btnLater;
    IBOutlet UILabel *lblRestaurant;
    IBOutlet UILabel *lblMusic;
    IBOutlet UILabel *lblBars;
    IBOutlet UILabel *lblSports;
    IBOutlet UILabel *lblCafe;
    IBOutlet UILabel *lblHotel;
    IBOutlet UILabel *lblNetworking;
    IBOutlet UILabel *lblClubs;
}
@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *array = [AppStateManager sharedInstance].mainCategoryArray;
    for (int i=0;i<array.count;i++){
        int tag = [[array objectAtIndex:i] intValue];
        UIButton *btn = (UIButton *)[self.view viewWithTag:tag];
        UIImageView *image = [self.view viewWithTag:(10+tag)];
        UIImageView *imgMenu = [self.view viewWithTag:(100+tag)];
        btn.selected = YES;
        image.hidden = NO;
        imgMenu.hidden = !image.isHidden;
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
    lblTitle.text = LOCALIZATION(@"category_title");
    lblDesc.text = LOCALIZATION(@"category_desc");
    [btnDone setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    [btnLater setTitle:LOCALIZATION(@"skip") forState:UIControlStateNormal];
    
    lblRestaurant.text = LOCALIZATION(@"category_main_restaurant");
    lblBars.text = LOCALIZATION(@"category_main_bars");
    lblSports.text = LOCALIZATION(@"category_main_sport");
    lblMusic.text = LOCALIZATION(@"category_main_music");
    lblCafe.text = LOCALIZATION(@"category_main_cafes");
    lblNetworking.text = LOCALIZATION(@"category_main_networking");
    lblClubs.text = LOCALIZATION(@"category_main_clubs");
    lblHotel.text = LOCALIZATION(@"category_main_hotel");
}

- (IBAction)onSubCategory:(id)sender {
    NSMutableArray *mainCategory = [[NSMutableArray alloc] init];
    for (int i=1;i<9;i++){
        UIButton *button = (UIButton *) [self.view viewWithTag:i];
        if (button.isSelected){
            [mainCategory addObject:[NSNumber numberWithInt:(i)]];
        }
    }
    
    if (mainCategory.count == 0){
        [Util showAlertTitle:self title:LOCALIZATION(@"categories") message:LOCALIZATION(@"1_categories")];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_SUB_CATEGORY];
    [query includeKey:PARSE_SUB_CATEGORY_NAME];
    [query orderByAscending:PARSE_SUB_CATEGORY_NAME];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
        } else {
            AppStateManager *inst = [AppStateManager sharedInstance];
            inst.categoryNetworking = [[NSMutableArray alloc] init];
            inst.categoryRestaurant = [[NSMutableArray alloc] init];
            inst.categoryBars = [[NSMutableArray alloc] init];
            inst.categoryHotel = [[NSMutableArray alloc] init];
            inst.categorySports = [[NSMutableArray alloc] init];
            inst.categoryMusic = [[NSMutableArray alloc] init];
            inst.categoryIdNetworking = [[NSMutableArray alloc] init];
            inst.categoryIdRestaurant = [[NSMutableArray alloc] init];
            inst.categoryIdBars = [[NSMutableArray alloc] init];
            inst.categoryIdHotel = [[NSMutableArray alloc] init];
            inst.categoryIdSports = [[NSMutableArray alloc] init];
            inst.categoryIdMusic = [[NSMutableArray alloc] init];
            for (int i=0;i<objects.count;i++){
                PFObject *category = [objects objectAtIndex:i];
                NSString *name = category[PARSE_SUB_CATEGORY_MAIN_NAME];
                if ([name isEqualToString:@"Restaurants"]){
                    [inst.categoryRestaurant addObject:category[PARSE_SUB_CATEGORY_NAME]];
                    [inst.categoryIdRestaurant addObject:category[PARSE_SUB_CATEGORY_ID]];
                } else if ([name containsString:@"Bars"]){
                    [inst.categoryBars addObject:category[PARSE_SUB_CATEGORY_NAME]];
                    [inst.categoryIdBars addObject:category[PARSE_SUB_CATEGORY_ID]];
                } else if ([name isEqualToString:@"Live Sports"]){
                    [inst.categorySports addObject:category[PARSE_SUB_CATEGORY_NAME]];
                    [inst.categoryIdSports addObject:category[PARSE_SUB_CATEGORY_ID]];
                } else if ([name isEqualToString:@"Live Music"]){
                    [inst.categoryMusic addObject:category[PARSE_SUB_CATEGORY_NAME]];
                    [inst.categoryIdMusic addObject:category[PARSE_SUB_CATEGORY_ID]];
                } else if ([name isEqualToString:@"Hotels"]){
                    [inst.categoryHotel addObject:category[PARSE_SUB_CATEGORY_NAME]];
                    [inst.categoryIdHotel addObject:category[PARSE_SUB_CATEGORY_ID]];
                } else if ([name isEqualToString:@"Networking"]){
                    [inst.categoryNetworking addObject:category[PARSE_SUB_CATEGORY_NAME]];
                    [inst.categoryIdNetworking addObject:category[PARSE_SUB_CATEGORY_ID]];
                }
            }
            
            SubCategoriesViewController *vc = (SubCategoriesViewController *)[Util getUIViewControllerFromStoryBoard:@"SubCategoriesViewController"];
            vc.mainCategory = mainCategory;
            [AppStateManager sharedInstance].mainCategoryArray = mainCategory;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (IBAction)onDone:(id)sender {
    if ([AppStateManager sharedInstance].categoryIdArray.count == 0){
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [AppStateManager sharedInstance].mainCategoryArray = [[NSMutableArray alloc] init];
        [AppStateManager sharedInstance].categoryArray = [[NSMutableArray alloc] init];
        [AppStateManager sharedInstance].categoryIdArray = [[NSMutableArray alloc] init];
        
        for (int i=1;i<8;i++){
            if (i != 5){
                [[AppStateManager sharedInstance].mainCategoryArray addObject:[NSNumber numberWithInt:i]];
            }
        }
        [SVProgressHUD setForegroundColor:MAIN_COLOR];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_SUB_CATEGORY];
        [query includeKey:PARSE_SUB_CATEGORY_NAME];
        [query orderByAscending:PARSE_SUB_CATEGORY_NAME];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription]];
            } else {
                AppStateManager *inst = [AppStateManager sharedInstance];
                inst.categoryNetworking = [[NSMutableArray alloc] init];
                inst.categoryRestaurant = [[NSMutableArray alloc] init];
                inst.categoryBars = [[NSMutableArray alloc] init];
                inst.categoryHotel = [[NSMutableArray alloc] init];
                inst.categorySports = [[NSMutableArray alloc] init];
                inst.categoryMusic = [[NSMutableArray alloc] init];
                inst.categoryIdNetworking = [[NSMutableArray alloc] init];
                inst.categoryIdRestaurant = [[NSMutableArray alloc] init];
                inst.categoryIdBars = [[NSMutableArray alloc] init];
                inst.categoryIdHotel = [[NSMutableArray alloc] init];
                inst.categoryIdSports = [[NSMutableArray alloc] init];
                inst.categoryIdMusic = [[NSMutableArray alloc] init];
                for (int i=0;i<objects.count;i++){
                    PFObject *category = [objects objectAtIndex:i];
                    NSString *name = category[PARSE_SUB_CATEGORY_MAIN_NAME];
                    if ([name isEqualToString:@"Restaurants"]){
                        [inst.categoryRestaurant addObject:category[PARSE_SUB_CATEGORY_NAME]];
                        [inst.categoryIdRestaurant addObject:category[PARSE_SUB_CATEGORY_ID]];
                    } else if ([name containsString:@"Bars"]){
                        [inst.categoryBars addObject:category[PARSE_SUB_CATEGORY_NAME]];
                        [inst.categoryIdBars addObject:category[PARSE_SUB_CATEGORY_ID]];
                    } else if ([name isEqualToString:@"Live Sports"]){
                        [inst.categorySports addObject:category[PARSE_SUB_CATEGORY_NAME]];
                        [inst.categoryIdSports addObject:category[PARSE_SUB_CATEGORY_ID]];
                    } else if ([name isEqualToString:@"Live Music"]){
                        [inst.categoryMusic addObject:category[PARSE_SUB_CATEGORY_NAME]];
                        [inst.categoryIdMusic addObject:category[PARSE_SUB_CATEGORY_ID]];
                    } else if ([name isEqualToString:@"Hotels"]){
                        [inst.categoryHotel addObject:category[PARSE_SUB_CATEGORY_NAME]];
                        [inst.categoryIdHotel addObject:category[PARSE_SUB_CATEGORY_ID]];
                    } else if ([name isEqualToString:@"Networking"]){
                        [inst.categoryNetworking addObject:category[PARSE_SUB_CATEGORY_NAME]];
                        [inst.categoryIdNetworking addObject:category[PARSE_SUB_CATEGORY_ID]];
                    }
                }
                
                for (int section=0;section<inst.mainCategoryArray.count;section++){
                    NSNumber *number = [inst.mainCategoryArray objectAtIndex:section];
                    NSInteger index = [number integerValue];
                    switch (index) {
                        case TAG_RESTAURANT:
                            for (int i=0;i<inst.categoryRestaurant.count;i++){
                                [inst.categoryArray addObject:[inst.categoryRestaurant objectAtIndex:i]];
                                [inst.categoryIdArray addObject:[inst.categoryIdRestaurant objectAtIndex:i]];
                            }
                            break;
                        case TAG_MUSIC:
                            for (int i=0;i<inst.categoryMusic.count;i++){
                                [inst.categoryArray addObject:[inst.categoryMusic objectAtIndex:i]];
                                [inst.categoryIdArray addObject:[inst.categoryIdMusic objectAtIndex:i]];
                            }
                            break;
                        case TAG_BARS:
                            for (int i=0;i<inst.categoryBars.count;i++){
                                [inst.categoryArray addObject:[inst.categoryBars objectAtIndex:i]];
                                [inst.categoryIdArray addObject:[inst.categoryIdBars objectAtIndex:i]];
                            }
                            break;
                        case TAG_SPORT:
                            for (int i=0;i<inst.categorySports.count;i++){
                                [inst.categoryArray addObject:[inst.categorySports objectAtIndex:i]];
                                [inst.categoryIdArray addObject:[inst.categoryIdSports objectAtIndex:i]];
                            }
                            break;
                        case TAG_CAFE:
                            break;
                        case TAG_HOTEL:
                            for (int i=0;i<inst.categoryHotel.count;i++){
                                [inst.categoryArray addObject:[inst.categoryHotel objectAtIndex:i]];
                                [inst.categoryIdArray addObject:[inst.categoryIdHotel objectAtIndex:i]];
                            }
                            break;
                        case TAG_NETWORK:
                            for (int i=0;i<inst.categoryNetworking.count;i++){
                                [inst.categoryArray addObject:[inst.categoryNetworking objectAtIndex:i]];
                                [inst.categoryIdArray addObject:[inst.categoryIdNetworking objectAtIndex:i]];
                            }
                            break;
                        case TAG_CLUBS:
                            break;
                        default:
                            break;
                    }
                }
                
                [self finishScreen];
            }
        }];
    } else {
        [self finishScreen];
    }
}

- (void) finishScreen {
    [AppStateManager sharedInstance].isCreate = NO;
    if (self.isFromMap){
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHANGED_CATEGORY object:nil];
    } else if (self.isFromTutorial){
        [self gotoMainScreen];
    }
}

- (void) gotoMainScreen {
    UIViewController *mainVC = [Util getUIViewControllerFromStoryBoard:@"MainViewController"];
    UINavigationController *mainNav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    [mainNav setNavigationBarHidden:YES];
    
    SideMenuViewController *leftMenuViewController = (SideMenuViewController*) [Util getUIViewControllerFromStoryBoard:@"SideMenuViewController"];
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:mainNav
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    [container setLeftMenuWidth:280];
    [container setPanMode:MFSideMenuPanModeSideMenu];
    
    [self.navigationController pushViewController:container animated:YES];
}

- (IBAction)onTapCategory:(id)sender {
    NSInteger tag = [sender tag];
    UIButton *button = [self.view viewWithTag:tag];
    UIImageView *img = [self.view viewWithTag:(10+tag)];
    UIImageView *imgMenu = [self.view viewWithTag:(100+tag)];
    if ([AppStateManager sharedInstance].isCreate){
        for (int i=1;i<9;i++){
            UIButton *btn = (UIButton *) [self.view viewWithTag:i];
            UIImageView *image = [self.view viewWithTag:(10+i)];
            btn.selected = NO;
            imgMenu.hidden = !img.isHidden;
            image.hidden = YES;
        }
        img.hidden = NO;
        button.selected = YES;
        imgMenu.hidden = !img.isHidden;
        [self onSubCategory:nil];
        return;
    }
    img.hidden = button.selected;
    imgMenu.hidden = !img.isHidden;
    button.selected = !button.selected;
    
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
