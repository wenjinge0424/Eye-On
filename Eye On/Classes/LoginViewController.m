//
//  LoginViewController.m
//  Eye On
//
//  Created by developer on 26/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "LoginViewController.h"
#import "ResetPasswordViewController.h"
#import "SignUpOneViewController.h"
#import "SignUpFourViewController.h"

@interface LoginViewController ()<GIDSignInUIDelegate, GIDSignInDelegate>
{
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    
    IBOutlet UIButton *btnResetPassword;
    IBOutlet UIButton *btnLogin;
    IBOutlet UIButton *btnSignUP;
    
    IBOutlet UIView *viewInform;
    IBOutlet UILabel *lblOrLoginWith;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util setBorderView:viewInform color:[UIColor whiteColor] width:0.5];
    [Util setCornerView:viewInform];
    
    if ([Util getLoginUserName].length > 0){
        txtEmail.text = [Util getLoginUserName];
        txtPassword.text = [Util getLoginUserPassword];
        
        [self onLogin:nil];
    }
    
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLanguageChangedNotification:)
                                                 name:kNotificationLanguageChanged
                                               object:nil];
}

- (void) receiveLanguageChangedNotification:(NSNotification *) notification
{
    if ([notification.name isEqualToString:kNotificationLanguageChanged])
    {
        [self configureLanguages];
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLanguageChanged object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureLanguages];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([Util getLoginUserName].length > 0){
        txtEmail.text = [Util getLoginUserName];
        txtPassword.text = [Util getLoginUserPassword];
    }
}

- (void) configureLanguages {
    txtEmail.placeholder = LOCALIZATION(@"email");
    txtPassword.placeholder = LOCALIZATION(@"password");
    [btnResetPassword setTitle:LOCALIZATION(@"button_forgot_password") forState:UIControlStateNormal];
    [btnLogin setTitle:LOCALIZATION(@"button_login") forState:UIControlStateNormal];
    lblOrLoginWith.text = LOCALIZATION(@"or_login_with");
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[btnSignUP attributedTitleForState:UIControlStateNormal]];
//    [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length) withString:LOCALIZATION(@"button_sign_up")];
//    [btnSignUP setAttributedTitle:attributedString forState:UIControlStateNormal];
}

- (IBAction)onLogin:(id)sender {

    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }

    if (![self isValid]){
        return;
    }
    
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_EMAIL equalTo:txtEmail.text];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error && object) {
            PFUser *user = (PFUser *)object;
            NSString *username = user.username;
            [PFUser logInWithUsernameInBackground:username password:txtPassword.text block:^(PFUser *user, NSError *error) {
                [SVProgressHUD dismiss];
                if (user) {
                    [Util setLoginUserName:user.email password:txtPassword.text];
                    [self gotoMainScreen];
                } else {
                    NSString *errorString = LOCALIZATION(@"incorrect_password");
                    [Util showAlertTitle:self title:LOCALIZATION(@"login_failed") message:errorString finish:^{
                        [txtPassword becomeFirstResponder];
                    }];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
            [Util setLoginUserName:@"" password:@""];
             
            NSString *msg = LOCALIZATION(@"msg_not_registerd_email");
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.customViewColor = MAIN_COLOR;
            alert.horizontalButtons = YES;
            [alert addButton:LOCALIZATION(@"try_again") actionBlock:^(void) {
            }];
            [alert addButton:LOCALIZATION(@"sign_up") actionBlock:^(void) {
                [self onSignUp:self];
            }];
            [alert showError:LOCALIZATION(@"sign_up") subTitle:msg closeButtonTitle:nil duration:0.0f];
        }
    }];

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

- (BOOL) isValid {
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    NSString *password = txtPassword.text;
    if (email.length == 0 && password.length == 0){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_email_password") finish:^{
            [txtEmail becomeFirstResponder];
        }];
        return NO;
    }
    if (email.length == 0){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_email") finish:^{
            [txtEmail becomeFirstResponder];
        }];
        return NO;
    }
    if (password.length == 0){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"no_password") finish:^{
            [txtPassword becomeFirstResponder];
        }];
        return NO;
    }
    if (![email isEmail]){
        [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"invalid_email") finish:^{
            [txtEmail becomeFirstResponder];
        }];
        return NO;
    }
    return YES;
}

- (IBAction)onSignUp:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    SignUpOneViewController *vc = (SignUpOneViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpOneViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onResetPassword:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    ResetPasswordViewController *vc = (ResetPasswordViewController *)[Util getUIViewControllerFromStoryBoard:@"ResetPasswordViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onGoogleLogin:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    [[GIDSignIn sharedInstance] signIn];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (IBAction)onWeChat:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
}

- (IBAction)onFacebook:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
     {
         if (user != nil) {
             if (user[@"facebookid"] == nil) {
                 PFUser *puser = [PFUser user];
                 puser = user;
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self requestFacebook:puser];
             } else {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self userLoggedIn:user];
             }
         } else {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"registered_email")];
         }
     }];
}

- (void)requestFacebook:(PFUser *)user
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,first_name,last_name,birthday,email" forKey:@"fields"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:parameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error == nil)
        {
            NSDictionary *userData = (NSDictionary *)result;
            [self processFacebook:user UserData:userData];
        }
        else
        {
            [Util setLoginUserName:@"" password:@""];
            [PFUser logOut];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"fail_fetch_facebook")];
        }
    }];
}

- (void)userLoggedIn:(PFUser *)user {
    /* login */
    user.password = [Util randomStringWithLength:20];
    [Util setLoginUserName:user.email password:user.password];
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    [user saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
        [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            txtEmail.text = user.email;
            txtPassword.text = user.password;
            [self onLogin:nil];
        }];
    }];
}

- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData
{
    NSString *link = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (responseObject) {
             user.username = userData[@"name"];
             user.password = [Util randomStringWithLength:20];
             user[PARSE_USER_FIRST_NAME] = userData[@"first_name"];
             user[PARSE_USER_LAST_NAME] = userData[@"last_name"];
             user[PARSE_USER_FULL_NAME] = [NSString stringWithFormat:@"%@ %@", user[PARSE_USER_FIRST_NAME], user[PARSE_USER_LAST_NAME]];
             user[PARSE_USER_FACEBOOK_ID] = userData[@"id"];
             if (userData[@"email"]) {
                 user.email = userData[@"email"];
                 user.username = user.email;
             } else {
                 NSString *name = [[userData[@"name"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
                 user.email = [NSString stringWithFormat:@"%@@facebook.com",name];
                 user.username = user.email;
             }
             
             UIImage *profileImage = [Util getUploadingImageFromImage:responseObject];
             NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
             NSString *filename = [NSString stringWithFormat:@"avatar.png"];
             PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
             user[PARSE_USER_AVATAR] = imageFile;
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [Util showAlertTitle:self title:LOCALIZATION(@"success") message:LOCALIZATION(@"success_login") finish:^{
                 [self gotoSignUpNex:user];
             }];
         } else {
             [Util setLoginUserName:@"" password:@""];
             [PFUser logOut];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile picture."];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [Util setLoginUserName:@"" password:@""];
         [PFUser logOut];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile picture."];
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

//  "Sign in with Google" delegate
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (error) {
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"fail_to_google_login")];
    } else {
        NSString *passwd = [Util randomStringWithLength:20];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              user.profile.email, @"username",
                              user.userID, @"googleid",
                              passwd, @"password",
                              nil];
        
        [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD setForegroundColor:MAIN_COLOR];
        [PFCloud callFunctionInBackground:@"resetGooglePasswd" withParameters:data block:^(id object, NSError *err) {
            if (err) { // this user is not registered on parse server
                PFUser *puser = [PFUser user];
                puser.password = passwd;
                puser[PARSE_USER_FIRST_NAME] = user.profile.givenName;
                puser[PARSE_USER_LAST_NAME] = user.profile.familyName;
                puser[PARSE_USER_FULL_NAME] = [NSString stringWithFormat:@"%@ %@", user.profile.givenName, user.profile.familyName];
                puser[PARSE_USER_GOOGLEID] = user.userID;
                puser.email = user.profile.email;
                puser.username = puser.email;
                
                if (user.profile.hasImage) {
                    NSURL *imageURL = [user.profile imageURLWithDimension:50*50];
                    UIImage *im = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
                    UIImage *profileImage = [Util getUploadingImageFromImage:im];
                    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                    NSString *filename = [NSString stringWithFormat:@"avatar.png"];
                    PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
                    puser[PARSE_USER_AVATAR] = imageFile;
                }
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:LOCALIZATION(@"success") message:LOCALIZATION(@"success_login") finish:^{
                    [self gotoSignUpNex:puser];
                }];
            } else { // this server is registerd on parse server
                [SVProgressHUD dismiss];
                txtEmail.text = user.profile.email;
                txtPassword.text = passwd;
                [self onLogin:nil];
            }
        }];
        
    }
}

- (void) gotoSignUpNex:(PFUser *) user {
    SignUpFourViewController *vc = (SignUpFourViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpFourViewController"];
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
