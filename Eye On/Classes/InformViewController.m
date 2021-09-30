//
//  InformViewController.m
//  Eye On
//
//  Created by developer on 23/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//
#import "Config.h"
#import "InformViewController.h"

@interface InformViewController ()
{
    IBOutlet UIWebView *webview;
    IBOutlet UILabel *lblTitle;
}
@end

@implementation InformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *docName = @"";
    if (self.type == INFORM_TERMS){
        docName = LOCALIZATION(@"doc_name_terms");
        lblTitle.text = LOCALIZATION(@"termsconditions");
    } else if (self.type == INFORM_PRIVACY){
        docName = LOCALIZATION(@"doc_name_policy");
        lblTitle.text = LOCALIZATION(@"privacy");
    } else if (self.type == INFORM_ABOUT){
        docName = LOCALIZATION(@"doc_name_about");
        lblTitle.text = LOCALIZATION(@"about");
    }
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:docName ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSStringEncodingConversionAllowLossy  error:nil];
    [webview loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
