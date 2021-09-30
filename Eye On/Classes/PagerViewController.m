//
//  PagerViewController.m
//  Eye On
//
//  Created by developer on 03/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "PagerViewController.h"
#import "PageItemViewController.h"
#import "CategoryViewController.h"
#import "MainViewController.h"
#import "SideMenuViewController.h"
#import "MFSideMenu.h"

@interface PagerViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    IBOutlet UIView *pagerContainer;
    UIPageViewController *pagerVC;
    NSArray *pageTitles;
    NSArray *pageDescriptions;
    NSArray *pageImages;
    IBOutlet UIPageControl *pageControl;

    IBOutlet UIButton *btnSkip;
    IBOutlet UIButton *btnNext;
}
@end

@implementation PagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self launchPageViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLayoutSubviews {
    pagerVC.view.frame = pagerContainer.frame;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguage];
}

- (void) configureLanguage {
    [btnSkip setTitle:LOCALIZATION(@"skip") forState:UIControlStateNormal];
}

- (void) launchPageViewController {
    pageTitles = @[LOCALIZATION(@"title_page_one"), LOCALIZATION(@"title_page_two"),
                   LOCALIZATION(@"title_page_three"), LOCALIZATION(@"title_page_four")
                      ];
    
    pageDescriptions = @[LOCALIZATION(@"description_page_one"), LOCALIZATION(@"description_page_two"), LOCALIZATION(@"description_page_three"), LOCALIZATION(@"description_page_four")];
    
    pageImages = @[@"freeMessaging",
                        @"freeVoiceCall",
                        @"freeVideoCall",
                        @"groups"];
    
    pagerVC = (UIPageViewController *)[Util getUIViewControllerFromStoryBoard:@"pageviewcontroller"];
    pagerVC.dataSource = self;
    pagerVC.delegate = self;
    PageItemViewController *startingVC = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingVC];
    [pagerVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
//    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 667 *617);
    
    UIPageControl *onBoardImagePageControl = [[UIPageControl alloc]init];
    onBoardImagePageControl.translatesAutoresizingMaskIntoConstraints = NO;
    onBoardImagePageControl.backgroundColor = [UIColor clearColor];
    [pagerVC.view addSubview:onBoardImagePageControl];
    
    [self addChildViewController:pagerVC];
    [self.view addSubview:pagerVC.view];
    [pagerVC didMoveToParentViewController:self];
}
- (IBAction)onNext:(id)sender {
    PageItemViewController *vc = [pagerVC.viewControllers lastObject];
    vc = [self viewControllerAtIndex:vc.pageIndex +1];
    if (vc){
        [pagerVC setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward  animated:YES completion:^(BOOL finished){
            [pageControl setCurrentPage:vc.pageIndex];
            if (vc.pageIndex == pageTitles.count -1){
                [self setLastValue];
            } else {
                [self setFirstValue];            }
        }];
    }
    else { // All Done
        [self gotomainScreen];
    }
}
- (IBAction)onSkip:(id)sender {
    [self gotomainScreen];
}
- (void) gotomainScreen {
    CategoryViewController *vc = (CategoryViewController *)[Util getUIViewControllerFromStoryBoard:@"CategoryViewController"];
    vc.isFromTutorial = YES;
    vc.isFromMap = NO;
    [self.navigationController pushViewController:vc animated:YES];
    
//    UIViewController *mainVC = [Util getUIViewControllerFromStoryBoard:@"MainViewController"];
//    UINavigationController *mainNav = [[UINavigationController alloc] initWithRootViewController:mainVC];
//    [mainNav setNavigationBarHidden:YES];
//    
//    SideMenuViewController *leftMenuViewController = (SideMenuViewController*) [Util getUIViewControllerFromStoryBoard:@"SideMenuViewController"];
//    
//    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
//                                                    containerWithCenterViewController:mainNav
//                                                    leftMenuViewController:leftMenuViewController
//                                                    rightMenuViewController:nil];
//    [container setLeftMenuWidth:280];
//    [container setPanMode:MFSideMenuPanModeSideMenu];
//    
//    [self.navigationController pushViewController:container animated:YES];
}
- (void) setLastValue {
    [btnNext setTitle:LOCALIZATION(@"all_done") forState:UIControlStateNormal];
    btnSkip.hidden = YES;
}
- (void) setFirstValue {
    [btnNext setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    btnSkip.hidden = NO;
}
- (PageItemViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([pageTitles count] == 0) || (index >= [pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageItemViewController *pageContentViewController =(PageItemViewController *) [Util getUIViewControllerFromStoryBoard:@"PageItemViewController"];
    
    pageContentViewController.titleText = pageTitles[index];
    pageContentViewController.desctiptionText = pageDescriptions[index];
    pageContentViewController.imageFile = pageImages[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = ((PageItemViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index --;
    return [self viewControllerAtIndex:index];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((PageItemViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    if (index == [pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}
- (void) pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed){
        PageItemViewController *vc = [pageViewController.viewControllers lastObject];
        [pageControl setCurrentPage:vc.pageIndex];
        if (vc.pageIndex == pageTitles.count-1){
            [self setLastValue];
        } else {
            [self setFirstValue];
        }
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
