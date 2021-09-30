//
//  SubCategoriesViewController.m
//  Eye On
//
//  Created by developer on 18/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SubCategoriesViewController.h"
#import "MapViewController.h"
#import "SideMenuViewController.h"
#import "CreateEventThreeViewController.h"

@interface SubCategoriesViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblDesc;
    IBOutlet UITableView *tableview;
    
    NSMutableArray *arraySelected;
    NSMutableArray *categories;
    NSMutableArray *categoryIds;
    IBOutlet UIButton *btnDone;
    IBOutlet UIButton *btnAll;
    
    AppStateManager *instance;
    NSString *category;
}
@end

@implementation SubCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableview.delegate = self;
    tableview.dataSource = self;
    arraySelected = [[NSMutableArray alloc] init];
    categories = [[NSMutableArray alloc] init];
    categoryIds = [[NSMutableArray alloc] init];
    instance = [AppStateManager sharedInstance];
    
    // init CategoryArray
    [self initCategoryArray];
    
    if (instance.categoryArray.count > 0){
        categories = instance.categoryArray;
        categoryIds = instance.categoryIdArray;
    }
    
    if ([AppStateManager sharedInstance].isCreate){
        categories = [[NSMutableArray alloc] init];
        categoryIds = [[NSMutableArray alloc] init];
        category = @"";
        btnAll.enabled = NO;
    }
    
    for (int i=0;i<self.mainCategory.count;i++){
        [arraySelected addObject:[[NSDictionary alloc] init]];
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

- (void) initCategoryArray {
    BOOL isRestaurant = NO, isBars = NO, isLive = NO, isSport = NO, isMusic = NO, isHotel = NO, isNetwork = NO;
    for (int section = 0;section<self.mainCategory.count;section++){
        NSNumber *number = [self.mainCategory objectAtIndex:section];
        NSInteger index = [number integerValue];
        switch (index) {
            case TAG_RESTAURANT:
                isRestaurant = YES;
                break;
            case TAG_MUSIC:
                isMusic = YES;
                break;
            case TAG_BARS:
                isBars = YES;
                break;
            case TAG_SPORT:
                isSport = YES;
                break;
            case TAG_CAFE:
                break;
            case TAG_HOTEL:
                isHotel = YES;
                break;
            case TAG_NETWORK:
                isNetwork = YES;
                break;
            case TAG_CLUBS:
                break;
            default:
                break;
        }
    }
    if (!isRestaurant){
        for (NSString *subCategory in instance.categoryRestaurant){
            if ([instance.categoryArray containsObject:subCategory]){
                [instance.categoryIdArray removeObjectAtIndex:[instance.categoryArray indexOfObject:subCategory]];
                [instance.categoryArray removeObject:subCategory];
            }
        }
    }
    if (!isBars){
        for (NSString *val in instance.categoryBars){
            if ([instance.categoryArray containsObject:val]){
                [instance.categoryIdArray removeObjectAtIndex:[instance.categoryArray indexOfObject:val]];
                [instance.categoryArray removeObject:val];
            }
        }
    }
    if (!isSport){
        for (NSString *subCategory in instance.categorySports){
            if ([instance.categoryArray containsObject:subCategory]){
                [instance.categoryIdArray removeObjectAtIndex:[instance.categoryArray indexOfObject:subCategory]];
                [instance.categoryArray removeObject:subCategory];
            }
        }
    }
    if (!isMusic){
        for (NSString *subCategory in instance.categoryMusic){
            if ([instance.categoryArray containsObject:subCategory]){
                [instance.categoryIdArray removeObjectAtIndex:[instance.categoryArray indexOfObject:subCategory]];
                [instance.categoryArray removeObject:subCategory];
            }
        }
    }
    if (!isHotel){
        for (NSString *subCategory in instance.categoryHotel){
            if ([instance.categoryArray containsObject:subCategory]){
                [instance.categoryIdArray removeObjectAtIndex:[instance.categoryArray indexOfObject:subCategory]];
                [instance.categoryArray removeObject:subCategory];
            }
        }
    }
    if (!isNetwork){
        for (NSString *subCategory in instance.categoryNetworking){
            if ([instance.categoryArray containsObject:subCategory]){
                [instance.categoryIdArray removeObjectAtIndex:[instance.categoryArray indexOfObject:subCategory]];
                [instance.categoryArray removeObject:subCategory];
            }
        }
    }
}

- (void) configureLanguage {
    lblTitle.text = LOCALIZATION(@"category_title");
    lblDesc.text = LOCALIZATION(@"sub_category");
    [btnDone setTitle:LOCALIZATION(@"done") forState:UIControlStateNormal];
    [btnAll setTitle:LOCALIZATION(@"select_all") forState:UIControlStateNormal];
}

- (IBAction)onSelectAll:(id)sender {
    NSInteger sectionCount = [tableview numberOfSections]; // self.mainCategory.count
    if (!categories){
        categories = [[NSMutableArray alloc] init];
        categoryIds = [[NSMutableArray alloc] init];
    }
    for (int i=0;i<sectionCount;i++){
        NSInteger rowCount = [tableview numberOfRowsInSection:i];
        for (int j=0;j<rowCount;j++){
            [self add:i :j];
        }
    }
    [tableview reloadData];
    
    for (int section=0;section<self.mainCategory.count;section++){
        NSNumber *number = [self.mainCategory objectAtIndex:section];
        NSInteger index = [number integerValue];
        switch (index) {
            case TAG_RESTAURANT:
                for (int i=0;i<instance.categoryRestaurant.count;i++){
                    [categories addObject:[instance.categoryRestaurant objectAtIndex:i]];
                    [categoryIds addObject:[instance.categoryIdRestaurant objectAtIndex:i]];
                }
                break;
            case TAG_MUSIC:
                for (int i=0;i<instance.categoryMusic.count;i++){
                    [categories addObject:[instance.categoryMusic objectAtIndex:i]];
                    [categoryIds addObject:[instance.categoryIdMusic objectAtIndex:i]];
                }
                break;
            case TAG_BARS:
                for (int i=0;i<instance.categoryBars.count;i++){
                    [categories addObject:[instance.categoryBars objectAtIndex:i]];
                    [categoryIds addObject:[instance.categoryIdBars objectAtIndex:i]];
                }
                break;
            case TAG_SPORT:
                for (int i=0;i<instance.categorySports.count;i++){
                    [categories addObject:[instance.categorySports objectAtIndex:i]];
                    [categoryIds addObject:[instance.categoryIdSports objectAtIndex:i]];
                }
                break;
            case TAG_CAFE:
                break;
            case TAG_HOTEL:
                for (int i=0;i<instance.categoryHotel.count;i++){
                    [categories addObject:[instance.categoryHotel objectAtIndex:i]];
                    [categoryIds addObject:[instance.categoryIdHotel objectAtIndex:i]];
                }
                break;
            case TAG_NETWORK:
                for (int i=0;i<instance.categoryNetworking.count;i++){
                    [categories addObject:[instance.categoryNetworking objectAtIndex:i]];
                    [categoryIds addObject:[instance.categoryIdNetworking objectAtIndex:i]];
                }
                break;
            case TAG_CLUBS:
                break;
            default:
                break;
        }
    }
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender {
    if ([AppStateManager sharedInstance].isCreate){
        if (category.length == 0){
            [Util showAlertTitle:self title:LOCALIZATION(@"categories") message:LOCALIZATION(@"1_categories")];
            return;
        }
        [AppStateManager sharedInstance].isCreate = NO;
        [AppStateManager sharedInstance].category = category;
        for (UIViewController *vc in self.navigationController.viewControllers){
            if ([vc isKindOfClass:[CreateEventThreeViewController class]]){
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
    } else {
        instance.categoryArray = categories;
        instance.categoryIdArray = categoryIds;
    }
    
    if (categories.count < 1){
        [Util showAlertTitle:self title:LOCALIZATION(@"categories") message:LOCALIZATION(@"1_categories")];
        return;
    }
    if (!instance.categoryArray){
        instance.categoryArray = [[NSMutableArray alloc] init];
        instance.categoryIdArray = [[NSMutableArray alloc] init];
    }
    
    for (UIViewController *vc in self.navigationController.viewControllers){
        if ([vc isKindOfClass:[MainViewController class]]){
            [self.navigationController popToViewController:vc animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHANGED_CATEGORY object:nil];
            return;
        }
    }
    [self gotoMainScreen];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.mainCategory.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSNumber *number = [self.mainCategory objectAtIndex:section];
    NSInteger index = [number integerValue];
    
    switch (index) {
        case TAG_RESTAURANT:
            //            return SUB_COUNT_RESTAURANT;
            return instance.categoryRestaurant.count;
        case TAG_MUSIC:
            return instance.categoryMusic.count;
        case TAG_BARS:
            return instance.categoryBars.count;
        case TAG_SPORT:
            return instance.categorySports.count;
        case TAG_CAFE:
            return SUB_COUNT_CAFE;
        case TAG_HOTEL:
            return instance.categoryHotel.count;
        case TAG_NETWORK:
            return instance.categoryNetworking.count;
        case TAG_CLUBS:
            return SUB_COUNT_CLUBS;
        default:
            return 0;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, tableView.frame.size.width, 20)];
    [label setFont:[UIFont boldSystemFontOfSize:16]];
    NSNumber *number = [self.mainCategory objectAtIndex:section];
    NSInteger index = [number integerValue] - 1;
    NSString *string = [CATEGORY_MAIN objectAtIndex:index];
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor lightGrayColor]];
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSInteger menuId = [[self.mainCategory objectAtIndex:section] integerValue];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellCategory"];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    UIImageView *img = (UIImageView *)[cell viewWithTag:2];
    img.hidden = ![self isExistSection:indexPath.section row:indexPath.row];
    switch (menuId) {
        case TAG_RESTAURANT:
            label.text = [instance.categoryRestaurant objectAtIndex:row];
            break;
        case TAG_MUSIC:
            label.text = [instance.categoryMusic objectAtIndex:row];
            break;
        case TAG_BARS:
            label.text = [instance.categoryBars objectAtIndex:row];
            break;
        case TAG_SPORT:
            label.text = [instance.categorySports objectAtIndex:row];
            break;
        case TAG_CAFE:
            break;
        case TAG_HOTEL:
            label.text = [instance.categoryHotel objectAtIndex:row];
            break;
        case TAG_NETWORK:
            label.text = [instance.categoryNetworking objectAtIndex:row];
            break;
        case TAG_CLUBS:
            break;
        default:
            break;
    }
    NSString *cat = label.text;
    if ([categories containsObject:cat]){
        img.hidden = NO;
        [self add:section :row];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isChecked = [self isExistSection:indexPath.section row:indexPath.row];
    UITableViewCell *cell = (UITableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    UIImageView *img = (UIImageView *)[cell viewWithTag:2];
    img = (UIImageView *)[cell viewWithTag:2];
    
    if ([AppStateManager sharedInstance].isCreate){
        arraySelected = [[NSMutableArray alloc] init];
        for (int i=0;i<self.mainCategory.count;i++){
            [arraySelected addObject:[[NSDictionary alloc] init]];
        }
        img.hidden = NO;
        [self add:indexPath.section :indexPath.row];
        [self updateTableView:indexPath];
        category = label.text;
    } else {
        img.hidden = !img.hidden;
        NSString *categoryString = label.text;
        NSString *categoryId = [self getCategoryId:categoryString Section:indexPath.section Row:indexPath.row];
        
        if (img.hidden){
            [categories removeObject:categoryString];
            [categoryIds removeObject:categoryId];
        } else {
            [categories addObject:categoryString];
            [categoryIds addObject:categoryId];
        }
        if (isChecked){
            [self remove:indexPath.section :indexPath.row];
        } else {
            [self add:indexPath.section :indexPath.row];
        }
    }
}

- (NSString *) getCategoryId:(NSString *)categoryString Section:(NSInteger) section Row:(NSInteger) row {
    NSString *categoryId = @"";
    NSNumber *number = [self.mainCategory objectAtIndex:section];
    NSInteger index = [number integerValue];
    switch (index) {
        case TAG_RESTAURANT:
            return [instance.categoryIdRestaurant objectAtIndex:row];
        case TAG_MUSIC:
            return [instance.categoryIdMusic objectAtIndex:row];
        case TAG_BARS:
            return [instance.categoryIdBars objectAtIndex:row];
        case TAG_SPORT:
            return [instance.categoryIdSports objectAtIndex:row];
        case TAG_CAFE:
            break;
        case TAG_HOTEL:
            return [instance.categoryIdHotel objectAtIndex:row];
            break;
        case TAG_NETWORK:
            return [instance.categoryIdNetworking objectAtIndex:row];
        case TAG_CLUBS:
            break;
        default:
            break;
    }
    return categoryId;
}

- (void) updateTableView:(NSIndexPath *)indexPath{
    NSInteger sectionCount = self.mainCategory.count;
    for (int i=0;i<sectionCount;i++){
        for (int j=0;j<[tableview numberOfRowsInSection:i];j++){
            UITableViewCell *cell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            UIImageView *img = (UIImageView *)[cell viewWithTag:2];
            if (indexPath.section == i && indexPath.row == j){
                img.hidden = NO;
            } else {
                img.hidden = YES;
            }
        }
    }
}

- (BOOL) isExistSection:(NSInteger)section row:(NSInteger )row{
    NSDictionary *dic = [arraySelected objectAtIndex:section];
    if (arraySelected.count<section ||dic == nil){
        return NO;
    }
    NSMutableArray *array = [dic objectForKey:[NSString stringWithFormat:@"%ld", section]];
    if ([array containsObject:[NSString stringWithFormat:@"%ld", (long)row]]){
        return YES;
    }
    return NO;
}

- (void) remove:(NSInteger) section :(NSInteger) row {
    NSMutableDictionary *dic = [arraySelected objectAtIndex:section];
    NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
    NSMutableArray *array = [dic objectForKey:[NSString stringWithFormat:@"%ld", section]];
    if (!array){
        array = [[NSMutableArray alloc] init];
    }
    if ([array containsObject:[NSString stringWithFormat:@"%ld", (long)row]]){
        [array removeObject:[NSString stringWithFormat:@"%ld", (long)row]];
    }
    [newDic setObject:array forKey:[NSString stringWithFormat:@"%ld", section]];
    [arraySelected replaceObjectAtIndex:section withObject:newDic];
}

- (void) add:(NSInteger) section :(NSInteger) row {
    NSMutableDictionary *dic = [arraySelected objectAtIndex:section];
    NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
    NSMutableArray *array = [dic objectForKey:[NSString stringWithFormat:@"%ld", section]];
    if (!array){
        array = [[NSMutableArray alloc] init];
    }
    if (![array containsObject:[NSString stringWithFormat:@"%ld", (long)row]]){
        [array addObject:[NSString stringWithFormat:@"%ld", (long)row]];
    }
    [newDic setObject:array forKey:[NSString stringWithFormat:@"%ld", section]];
    [arraySelected replaceObjectAtIndex:section withObject:newDic];
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

@end
