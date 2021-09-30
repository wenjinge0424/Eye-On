//
//  StripeConnectionViewController.m
//  Eye On
//
//  Created by developer on 03/05/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "StripeConnectionViewController.h"

@interface StripeConnectionViewController ()
{
    UIWebView *newWebView;
    BOOL inited;
    NSURLRequest *stripeRequest;
    IBOutlet UIView *htmlView;
}
@end

@implementation StripeConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *stripeURL = [NSString stringWithFormat:@"%@?email=%@&password=%@", STRIPE_CONNECT_URL, [Util getLoginUserName], [Util getLoginUserPassword]];
    NSURL *url = [NSURL URLWithString:stripeURL];
    stripeRequest =[NSURLRequest requestWithURL:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (inited)
        return;
    
    newWebView = [[UIWebView alloc] initWithFrame:htmlView.frame];
    [self.view addSubview:newWebView];
    inited = YES;
    [newWebView loadRequest:stripeRequest];
    newWebView.backgroundColor = [UIColor clearColor];
    [newWebView setOpaque:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
