//
//  PhotoViewController.m
//  Eye On
//
//  Created by developer on 02/05/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()
{
    IBOutlet UIImageView *imageview;    
}
@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util setImage:imageview imgFile:(PFFile *)self.user[PARSE_USER_AVATAR]];
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
