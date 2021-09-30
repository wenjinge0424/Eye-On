//
//  ViewController.m
//  Eye On
//
//  Created by developer on 23/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "ViewController.h"
#import "Localisator.h"
#import "Config.h"

@interface ViewController ()
{
    NSArray * arrayOfLanguages;
    IBOutlet UILabel *lbltest;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    arrayOfLanguages = [[[Localisator sharedInstance] availableLanguagesArray] copy];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onenglish:(id)sender {
    [[Localisator sharedInstance] setLanguage:@"English_en"];
    lbltest.text = LOCALIZATION(@"help");
}

- (IBAction)onfrench:(id)sender {
    [[Localisator sharedInstance] setLanguage:@"French_fr"];
    lbltest.text = LOCALIZATION(@"help");
}

@end
