//
//  Util.m
//  NorgesVPN
//
//  Created by IOS7 on 7/22/14.
//  Copyright (c) 2014 com.bruno.norgesVPN. All rights reserved.
//

#import "Util.h"
#import "SCLAlertView.h"

@implementation Util

static CustomIOS7AlertView *customAlertView;


/***************************************************************/
/***************************************************************/
/* Indicator Management *****************************************/
/***************************************************************/
/***************************************************************/

+ (NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!@#$%^&*()_+=|\{}[]:',./?><;";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", (unichar) [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

+ (void) setCircleView:(UIView*) view {
    [view layoutIfNeeded];
    view.layer.cornerRadius = view.frame.size.height/2;
    view.layer.masksToBounds = YES;
}

+ (void) setCornerView:(UIView*) view {
    view.layer.cornerRadius = 7;
    view.layer.masksToBounds = YES;
}

+ (void) setBorderView:(UIView *)view color:(UIColor*)color width:(CGFloat)width {
    view.layer.borderColor = [color CGColor];
    view.layer.borderWidth = width;
}

+ (void) setCornerCollection:(NSArray*) collection {
    for (UIView *view in collection) {
        [Util setCornerView:view];
    }
}

+ (void) setBorderCollection:(NSArray*) collection color:(UIColor*)color {
    for (UIView *view in collection) {
        [Util setBorderView:view color:color width:1.f];
    }
}

+ (void)_rotateImageView:(UIImageView *)imgVRotationView
{
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [imgVRotationView setTransform:CGAffineTransformRotate(imgVRotationView.transform, 1)];
    }completion:^(BOOL finished){
        if (finished) {
            [Util _rotateImageView:imgVRotationView];
        }
    }];
}
        

+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    [alert alertIsDismissed:^{
    }];
    alert.customViewColor = MAIN_COLOR;
    [alert showInfo:vc title:title subTitle:message closeButtonTitle:LOCALIZATION(@"OK") duration:0.0f];
}

+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message finish:(void (^)(void))finish
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    [alert alertIsDismissed:^{
        if (finish) {
            finish ();
        }
    }];
    [alert setForceHideBlock:^{
        if (finish) {
            finish ();
        }
    }];
    alert.customViewColor = MAIN_COLOR;
    
    [alert showInfo:vc title:title subTitle:message closeButtonTitle:LOCALIZATION(@"OK") duration:0.0f];
}

+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message info:(BOOL)info
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    [alert alertIsDismissed:^{
    }];
    alert.customViewColor = MAIN_COLOR;
    
    if (info)
        [alert showInfo:vc title:title subTitle:message closeButtonTitle:LOCALIZATION(@"OK") duration:0.0f];
    else
        [alert showQuestion:vc title:title subTitle:message closeButtonTitle:LOCALIZATION(@"OK") duration:0.0f];
}

+ (CustomIOS7AlertView *) showCustomAlertView:(UIView *) parentView view:(UIView *) view buttonTitleList:(NSMutableArray *)buttonTitleList completionBlock: (void (^)(int buttonIndex))completionBlock
{
    if (customAlertView == nil) {
        customAlertView =  [[CustomIOS7AlertView alloc] init];
    } else {
        for (UIView *view in customAlertView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    // Add some custom content to the alert view
    [customAlertView setContainerView:view];
    
    // Modify the parameters
    [customAlertView setButtonTitles:buttonTitleList];
    
    // You may use a Block, rather than a delegate.
    [customAlertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %ld.", buttonIndex, (long)[alertView tag]);
        [alertView close];
        completionBlock (buttonIndex);
    }];
    
    customAlertView.parentView = parentView;
    [customAlertView show];
    [customAlertView setUseMotionEffects:true];
    
    return customAlertView;
}

+ (void) hideCustomAlertView {
    if (customAlertView != nil) {
        [customAlertView close];
    }
}

+ (void) setLoginUserName:(NSString*) userName password:(NSString*) password {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userName forKey:@"userName"];
    [defaults setObject:password forKey:@"password"];
    [defaults synchronize];
    
    // Installation
    if (userName.length > 0 && password.length > 0) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setObject:[PFUser currentUser] forKey:@"owner"];
        [currentInstallation saveInBackground];
    } else {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation removeObjectForKey:@"owner"];
        [currentInstallation saveInBackground];
    }
}

+ (void) setFirstUse:(BOOL)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:@"firstloadapp"];
    [defaults synchronize];
}

+ (BOOL) isFirstUse {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL result = [defaults boolForKey:@"firstloadapp"];
    return result;
}

+ (NSString*) getLoginUserName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"userName"];
    return userName;
}

+ (NSString*) getLoginUserPassword {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *password = [defaults objectForKey:@"password"];
    return password;
}


+ (UIViewController*) getUIViewControllerFromStoryBoard:(NSString*) storyboardIdentifier {
    UIStoryboard *mainSB =  nil;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        mainSB =  [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    } else {
        mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    UIViewController *vc = [mainSB instantiateViewControllerWithIdentifier:storyboardIdentifier];
    return vc;
}

+ (UITextField *)getTextFieldFromSearchBar:(UISearchBar *)searchBar
{
    UITextField *searchBarTextField = nil;
    NSArray *views = ([self getOSVersion] < 7.0f) ? searchBar.subviews : [[searchBar.subviews objectAtIndex:0] subviews];
    for (UIView *subView in views) {
        if ([subView isKindOfClass:[UITextField class]]) {
            searchBarTextField = (UITextField *)subView;
            break;
        }
    }
    return searchBarTextField;
}


+ (CGFloat)getOSVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (NSDate*) convertString2HourTime:(NSString*) dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:dateString];
    
    return dateFromString;
}

+ (NSString *) convertDate2String:(NSDate*) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (void) drawBorderLine:(UIView *) view upper: (BOOL)isUpper bottom:(BOOL) isBottom bottomDiff:(CGFloat) bottomDiff borderColor:(UIColor*) borderColor {
    if (view == nil) {
        return;
    }
    CGFloat height = 2.0f;
    
    if (isUpper) {
        UIView *upperBorder = [[UIView alloc] init];;
        upperBorder.backgroundColor = borderColor;
        upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(view.frame), height);
        [view addSubview:upperBorder];
    }
    
    if (isBottom) {
        if (bottomDiff == 0.f) {
            bottomDiff = -height;
        }
        CGFloat pos_y = view.frame.size.height + bottomDiff - 0.5f;
        UIView *bottomBorder = [[UIView alloc] init];;
        bottomBorder.backgroundColor = borderColor;
        bottomBorder.frame = CGRectMake(0,  pos_y, CGRectGetWidth(view.frame), height);
        [view addSubview:bottomBorder];
    }
}

+ (void) removeBorderLine:(UIView*) view removeColor:(UIColor*) removeColor {
    NSArray *subViewList = view.subviews;
    for(int i = 0 ; i < subViewList.count ; i++) {
        UIView *subView = [subViewList objectAtIndex:i];
        UIColor *orgColor = subView.backgroundColor;
        if ([self isEqualToColor:orgColor otherColor:removeColor]) {
            [subView removeFromSuperview];
        }
    }
}

+ (BOOL)isEqualToColor:(UIColor*)orgColor otherColor:(UIColor *)otherColor {
    CGColorSpaceRef colorSpaceRGB = CGColorSpaceCreateDeviceRGB();
    
    UIColor *(^convertColorToRGBSpace)(UIColor*) = ^(UIColor *color) {
        if(CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome) {
            const CGFloat *oldComponents = CGColorGetComponents(color.CGColor);
            CGFloat components[4] = {oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1]};
            CGColorRef colorRef = CGColorCreate( colorSpaceRGB, components );
            
            UIColor *color = [UIColor colorWithCGColor:colorRef];
            CGColorRelease(colorRef);
            return color;
        } else
            return color;
    };
    
    UIColor *selfColor = convertColorToRGBSpace(orgColor);
    otherColor = convertColorToRGBSpace(otherColor);
    CGColorSpaceRelease(colorSpaceRGB);
    
    return [selfColor isEqual:otherColor];
}

static inline double radians (double degrees) {return degrees * M_PI/180;}
+ (UIImage *) getSquareImage:(UIImage *)originalImage {
    CGFloat width = originalImage.size.width;
    CGFloat height = originalImage.size.height;
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat square = width;
    if (width > height) {
        square = height;
    }
    
    x = abs(width - square) / 2;
    y = 0;//abs(height - square) / 2;
    
    CGRect cropRect = CGRectMake(x, y, square, square);
    
    // //////
    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], cropRect);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    CGContextRef bitmap = CGBitmapContextCreate(NULL, cropRect.size.width, cropRect.size.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    
    if (originalImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, - cropRect.size.height);
        
    } else if (originalImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -cropRect.size.width, 0);
        
    } else if (originalImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (originalImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, cropRect.size.width, cropRect.size.height);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, cropRect.size.width, cropRect.size.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    
    UIImage *resultImage=[UIImage imageWithCGImage:ref];
    CGImageRelease(imageRef);
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    
    NSLog(@"orgImage: %ld, newImage: %ld",originalImage.imageOrientation, resultImage.imageOrientation);
    
    return resultImage;
}

+ (UIImage *)getUploadingImageFromImage:(UIImage *)image {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    
    // dont' resize, use the original image. we can adjust this value of maxResolution like 1024, 768, 640  and more less than current value.
    CGFloat maxResolution = 320.f;
    if (image.size.width < maxResolution) {
        CGSize newSize = CGSizeMake(image.size.width, image.size.height);
        UIGraphicsBeginImageContext(newSize);
        // CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
        // CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, newSize.width, newSize.height));
        [image drawInRect:CGRectMake(0,
                                     0,
                                     image.size.width,
                                     image.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        CGFloat rate = image.size.width / maxResolution;
        CGSize newSize = CGSizeMake(maxResolution, image.size.height / rate);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
}

+ (void) downloadFile:(NSString *)url name:(NSString *) name completionBlock:(void (^)(NSURL *downloadurl, NSData *data, NSError *err))completionBlock {
    NSURL *remoteurl = [NSURL URLWithString:url];
    NSString *fileName = name;
    if (name == nil) {
        fileName = [url lastPathComponent];
    }
    NSString *filePath = [[self getDocumentDirectory] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        NSURL *localurl = [NSURL fileURLWithPath:filePath];
        if (completionBlock)
            completionBlock(localurl, data, nil);
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:remoteurl];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"Download Error:%@",error.description);
            if (completionBlock)
                completionBlock(nil, data, error);
        } else if (data) {
            [data writeToFile:filePath atomically:YES];
            NSLog(@"File is saved to %@",filePath);
            
            NSURL *localurl = [NSURL fileURLWithPath:filePath];
            if (completionBlock)
                completionBlock(localurl, data, error);
        }
    }];
}

+ (NSString *) downloadedURL:(NSString *)url name:(NSString *) name {
    NSString *fileName = name;
    if (name == nil) {
        fileName = [url lastPathComponent];
    }
    NSString *filePath = [[self getDocumentDirectory] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *localurl = [NSURL fileURLWithPath:filePath];
        return localurl.absoluteString;
    }
    
    return nil;
}

+ (void) setImage:(UIImageView *)imgView imgFile:(PFFile *)imgFile {
    NSString *imageURL;
    
    imageURL = [Util downloadedURL:imgFile.url name:nil];
    if (!imageURL) {
        imageURL = [Util urlparseCDN:imgFile.url];
        [Util downloadFile:imageURL name:nil completionBlock:nil];
    }
    
    [imgView setImageWithURL:[NSURL URLWithString:imageURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

+ (NSString *) trim:(NSString *) string {
    NSString *newString = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    return newString;
}

#pragma mark - Get the Label Width By message
+ (CGFloat) getLabelWidthByMessage :(NSString *) message fontSize:(CGFloat) fontSize {
    
    CGSize ideal_size = [message sizeWithFont:[UIFont systemFontOfSize:fontSize]];
    
    CGFloat messageWidth = ideal_size.width;
    
    return messageWidth;
}

+ (NSString *) getDocumentDirectory {    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/", [paths objectAtIndex:0]]; //create NSString object, that holds our exact path to the documents directory
    return  documentsDirectory;
}

#pragma mark appdelegate
+ (AppDelegate *) appDelegate {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate;
}


#pragma mark - Parse Util

+ (void) addPendingMessages:(PFUser *) fromUser toUser:(PFUser*) toUser type:(NSString*) type soInfo:(PFObject*)soInfo  completionBlock: (void (^)(NSError *))completionBlock {
    // Create a PFObject around a PFFile and associate it with the current user
    PFObject *pendingInfo = [PFObject objectWithClassName:@"PendingMessages"];
    
    [pendingInfo setObject:fromUser forKey:@"fromUser"];
    [pendingInfo setObject:toUser forKey:@"toUser"];
    
    [pendingInfo setObject:type forKey:@"type"];
    if (soInfo) {
//        if ([type isEqualToString:PENDING_TYPE_SO_SEND]) {
//            [pendingInfo setObject:soInfo forKey:@"SOInfo"];
//        } else if ([type isEqualToString:PENDING_TYPE_INTANGIBLE_SEND]) {
//            [pendingInfo setObject:soInfo forKey:@"IntangibleInfo"];
//        }
    }
    
    [pendingInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            completionBlock(nil);
        } else{
            completionBlock(error);
        }
    }];
}

+ (void) removePendingMessage:(PFObject*) object completionBlock: (void (^)(NSError *))completionBlock {
    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            completionBlock(nil);
        } else {
            completionBlock(error);
        }
    }];
}

#pragma mark - Push Notification
// receiverList is a list of selected user_pfObject;
+ (void) sendPushNotification:(NSString *)type receiverList:(NSArray*) receiverList dataInfo:(id)dataInfo {
    NSString *pushMessage;
    NSString *message;
    
//    if ([type isEqualToString:REMOTE_NF_TYPE_NEW_ITEM]) {
//        pushMessage = [NSString stringWithFormat:@"%@ updated a item", [PFUser currentUser].username];
//        message = @"Updated a item";
//    } else if ([type isEqualToString:REMOTE_NF_TYPE_NEW_CATEGORY]) {
//        pushMessage = [NSString stringWithFormat:@"%@ added a new category", [PFUser currentUser].username];
//        message = @"Added a new category";
//    } else if ([type isEqualToString:REMOTE_NF_TYPE_FRIEND_INVITE]) {
//        pushMessage = [NSString stringWithFormat:@"%@ wants you to be a friend", [PFUser currentUser].username];
//        message = @"Wants you to be a friend";
//    } else if ([type isEqualToString:REMOTE_NF_TYPE_INVITE_ACCEPT]) {
//        pushMessage = [NSString stringWithFormat:@"%@ accepted you to be a friend", [PFUser currentUser].username];
//        message = @"Accepted you to be a friend";
//    } else if ([type isEqualToString:REMOTE_NF_TYPE_INVITE_REJECT]) {
//        pushMessage = [NSString stringWithFormat:@"%@ rejected you to be a friend", [PFUser currentUser].username];
//        message = @"Rejected you to be a friend";
//    } else if ([type isEqualToString:REMOTE_NF_TYPE_CLICK_EMPTY_CATEGORY]) {
//        pushMessage = [NSString stringWithFormat:@"%@ opened your list today, but your list is already empty! Please come back and update your list.", [PFUser currentUser].username];
//        message = @"Opened your list today, but your list is already empty! Please come back and update your list.";
//    } else {
//        return;
//    }
//
    NSMutableArray *receiverIdList = [[NSMutableArray alloc] init];
    PFUser *me = [PFUser currentUser];
    NSString *name = (me[PARSE_USER_FULL_NAME])?me[PARSE_USER_FULL_NAME]:me.username;
    pushMessage = [NSString stringWithFormat:@"%@ %@", name, LOCALIZATION(@"invited")];
    message = pushMessage;
    for (PFUser *user in receiverList) {
        if (!me || ![me.objectId isEqualToString:user.objectId])
            [receiverIdList addObject:user.objectId];
    }
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          receiverIdList, @"idlist",
                          pushMessage, @"alert",
                          @"Increment", @"badge",
                          @"cheering.caf", @"sound",
                          dataInfo, PARSE_CLASS_NOTIFICATION_FIELD_DATAINFO,
                          nil];
    
    [PFCloud callFunctionInBackground:@"SendPushList" withParameters:data block:^(id object, NSError *err) {
        if (err) {
            NSLog(@"Fail APNS: %@", message);
        } else {
            NSLog(@"Success APNS: %@", message);
        }
    }];

    int typeNum = [type intValue];
    for (PFUser *user in receiverList) {
        if (!me || ![me.objectId isEqualToString:user.objectId]) {
            PFObject *notification = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
            [notification setObject:[NSNumber numberWithInt:typeNum] forKey:PARSE_NOTIFICATION_TYPE];
            [notification setObject:user forKey:PARSE_NOTIFICATION_TO_USER];
            [notification setObject:me forKey:PARSE_NOTIFICATION_FROM_USER];
            [notification setObject:message forKey:PARSE_NOTIFICATION_MESSAGE];
            [notification saveInBackground];
        }
    }
}

+ (void) sendPushNotification:(NSString *) type receiverList:(NSArray *)list message:(NSString *)msg event:(PFObject *)event venue:(PFObject *)venue{
    
    NSMutableArray *receiverIdList = [[NSMutableArray alloc] init];
    PFUser *me = [PFUser currentUser];
    NSString *name = (me[PARSE_USER_FULL_NAME])?me[PARSE_USER_FULL_NAME]:me.username;
    for (PFUser *user in list) {
        if (!me || ![me.objectId isEqualToString:user.objectId])
            [receiverIdList addObject:user.objectId];
    }
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          receiverIdList, @"idlist",
                          msg, @"alert",
                          @"Increment", @"badge",
                          @"cheering.caf", @"sound",
                          nil];
    
    [PFCloud callFunctionInBackground:@"SendPushList" withParameters:data block:^(id object, NSError *err) {
        if (err) {
            NSLog(@"Fail APNS: %@", msg);
        } else {
            NSLog(@"Success APNS: %@", msg);
        }
    }];
    
    int typeNum = [type intValue];
    for (PFUser *user in list) {
        if (!me || ![me.objectId isEqualToString:user.objectId]) {
            PFObject *notification = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
            [notification setObject:[NSNumber numberWithInt:typeNum] forKey:PARSE_NOTIFICATION_TYPE];
            [notification setObject:user forKey:PARSE_NOTIFICATION_TO_USER];
            [notification setObject:me forKey:PARSE_NOTIFICATION_FROM_USER];
            [notification setObject:msg forKey:PARSE_NOTIFICATION_MESSAGE];
            if (event){
                [notification setObject:event forKey:PARSE_NOTIFICATION_EVENT];
            }
            if (venue){
                [notification setObject:venue forKey:PARSE_NOTIFICATION_VENUE];
            }
            [notification saveInBackground];
        }
    }
}

+ (NSString *)urlparseCDN:(NSString *)url
{
    NSArray *paths = [url pathComponents];
    
    if (paths && paths[1]) {
        NSArray *items = [paths[1] componentsSeparatedByString:@":"];
        if (items && [items[0] isEqualToString:PARSE_SERVER_BASE]) {
            NSInteger port = [items[1] integerValue] - PARSE_CDN_DECNUM;
            NSString *cdnURL = [NSString stringWithFormat:@"https://%@/process/%ld", PARSE_CDN_BASE, (long)port];
            
            for (int i=2; i<paths.count; i++) {
                cdnURL = [[cdnURL stringByAppendingString:@"/"] stringByAppendingString:paths[i]];
            }
            
            return cdnURL;
        }
    }
    
    return url;
}


+ (void) animationExchangeView:(UIView *)parent src:(UIView *)src dst:(UIView *)dst duration:(NSTimeInterval)duration back:(BOOL)back vertical:(BOOL)vertical {
    if (dst == src)
        return;
    
    if (!src) {
        dst.hidden = NO;
        [parent bringSubviewToFront:dst];
        return;
    }
    
    CGRect rect = dst.frame;
    CGRect dstrect = rect;
    
    src.hidden = YES;
    [parent bringSubviewToFront:dst];
    dst.hidden = NO;
    if (vertical) {
        if (back)
            dstrect.origin.y -= dstrect.size.height;
        else
            dstrect.origin.y += dstrect.size.height;
    } else {
        if (back)
            dstrect.origin.x -= dstrect.size.width;
        else
            dstrect.origin.x += dstrect.size.width;
    }
    dst.frame = dstrect;
    
    // executing animation
    [UIView animateWithDuration:duration delay:0 options:(UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction) animations:^{
        // bring dst to front
        dst.frame = rect;
    } completion:^(BOOL finished) {
        // hide it after animation completes
        src.hidden = YES;
    }];
}

+ (NSString *) getParseDate:(NSDate *)date
{
    NSDate *updated = date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    if ([self isToday:date]){
        [dateFormat setDateFormat:@"h:mm a"];
    } else {
        [dateFormat setDateFormat:@"MMM d, h:mm a"];
    }
    NSString *result = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:updated]];
    return result;
}

+ (BOOL)isToday:(NSDate *)date
{
    return [[self dateStartOfDay:date] isEqualToDate:[self dateStartOfDay:[NSDate date]]];
}

+ (NSDate *)dateStartOfDay:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components =
    [gregorian               components:(NSCalendarUnitYear | NSCalendarUnitMonth |
                                         NSCalendarUnitDay) fromDate:date];
    return [gregorian dateFromComponents:components];
}

+ (NSString *) getExpireDateString:(NSDate *)date
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    return [dateFormatter stringFromDate:date];
}
+ (NSString *) convertDate2StringWithFormat:(NSDate*) date dateFormat:(NSString*) format  {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (void) saveNotification:(PFUser *)toUser type:(int)type message:(NSString*)message address:(NSString *)address notes:(NSString *)notes {
//    PFObject *object = [PFObject objectWithClassName:PARSE_CLASS_NOTIFICATION];
//    
//    object[PARSE_FIELD_NOTIFICATION_TOUSER] = toUser;
//    object[PARSE_FIELD_NOTIFICATION_FROMUSER] = [PFUser currentUser];
//    object[PARSE_FIELD_NOTIFICATION_MESSAGE] = message;
//    object[PARSE_FIELD_NOTIFICATION_ADDRESS] = address;
//    object[PARSE_FIELD_NOTIFICATION_NOTES] = notes;
//    object[PARSE_FIELD_NOTIFICATION_ISREAD] = @false;
//    
//    [object saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
//        [Util sendPushNotification:toUser.username message:message type:type];
//    }];
}

+ (void) saveNotification:(PFUser *) toUser Message:(NSString *) msg Type:(int) type {
    PFObject *notification = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
    notification[PARSE_NOTIFICATION_FROM_USER] = [PFUser currentUser];
    notification[PARSE_NOTIFICATION_TO_USER] = toUser;
    notification[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInt:type];
    notification[PARSE_NOTIFICATION_MESSAGE] = msg;
    [notification saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [Util sendPushNotification:toUser.username message:msg type:type];
    }];
}

+ (void) sendPushNotification:(NSString *)email message:(NSString *)message type:(int)type {
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          email, @"email",
                          message, @"alert",
                          @"Increment", @"badge",
                          @"cheering.caf", @"sound",
                          @"", @"data",
                          [NSNumber numberWithInt:type], @"type",
                          nil];
    
    [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
        if (err) {
            NSLog(@"Fail APNS: %@", message);
        } else {
            NSLog(@"Success APNS: %@", message);
        }
    }];
}

+ (void) sendEmail:(NSString *)email subject:(NSString *)subject message:(NSString *)message {
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          message, @"message",
                          subject, @"subject",
                          email, @"email",
                          nil];
    
    [PFCloud callFunctionInBackground:@"sendNotifyEmail" withParameters:data block:^(id object, NSError *err) {
        if (err) {
            NSLog(@"Failed to email: %@", message);
        } else {
            NSLog(@"Successed: %@", message);
        }
    }];
}
+ (BOOL) isConnectableInternet {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        return NO;
    } else {
        NSLog(@"There IS internet connection");
        return YES;
    }
}

+ (BOOL) isValidPassword:(NSString *)string {
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"^.*(?=.*[a-z])(?=.*[A-Z]).*$" options:0 error:nil];
    return [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0;
}

+ (BOOL) isContainsNumber:(NSString *)password {
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    if ([password rangeOfCharacterFromSet:set].location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (BOOL) isContainsLowerCase:(NSString *)password {
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"^.*(?=.*[a-z])" options:0 error:nil];
    return [regex numberOfMatchesInString:password options:0 range:NSMakeRange(0, [password length])] > 0;
}

+ (BOOL) isContainsUpperCase:(NSString *)password {
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"^.*(?=.*[A-Z])" options:0 error:nil];
    return [regex numberOfMatchesInString:password options:0 range:NSMakeRange(0, [password length])] > 0;
}

+ (BOOL) isPhotoAvaileble {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied || [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted){
        return NO;
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        }];
        return YES;
    } else {
        return YES;
    }
}

+ (BOOL) isCameraAvailable {
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];        
        if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
            return NO;
        }
        else if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:nil];
            return YES;
        }
        return YES;
    }
    else
        return YES;
}

+(UIImage *) image:(UIImage *)originalImage scaledToSize:(CGSize)size {
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }
    
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //draw
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

+ (NSMutableArray *) getSearchKey {
#ifdef DEBUG
//    return [NSMutableArray arrayWithObjects:@"4bf58dd8d48988d1fa931735", @"593a43e5db04f547b3839bd4", nil];
#endif
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i=0;i<[AppStateManager sharedInstance].categoryIdArray.count;i++){
        NSString *item = [[AppStateManager sharedInstance].categoryIdArray objectAtIndex:i];
        if (item.length>0)
            [result addObject:item];
    }
//    for (int i=0;i<[AppStateManager sharedInstance].mainCategoryArray.count;i++){
//        NSNumber *number = [[AppStateManager sharedInstance].mainCategoryArray objectAtIndex:i];
//        NSInteger index = [number integerValue] - 1;
//        NSString *string = [CATEGORY_MAIN objectAtIndex:index];
//        if ([string isEqualToString:@"Restaurants"]){
//            string = @"restaurant";
//        }
//        string = [string lowercaseString];
//        if ([string containsString:@"Bars"]){
//            [result addObject:@"bar"];
//            [result addObject:@"pub"];
//            [result addObject:@"club"];
//            continue;
//        }
//        [result addObject:string];
//    }
    return result;
}

+ (void)setStringValueForKey:(NSString *)key value:(NSString *)value {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:value forKey:key];
    [userDefault synchronize];
}

+ (NSString *)getStringValueForKey:(NSString *)key {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefault stringForKey:key];
    if (value == nil) {
        value = @"";
    }
    return value;
}

+(void)getAddressFromLatitde:(double)latitude Longitude:(double)longitude complationBlock:(addressCompletion)completionBlock;
{
    __block NSString *address = @"";
    __block NSString *Address1, *Address2, *city, *State, *Country, *County, *PIN;
    NSString *getAddressURL = [NSString stringWithFormat:@"%@%f,%f%@", @"http://maps.googleapis.com/maps/api/geocode/json?latlng=", latitude, longitude, @"&sensor=true"];
    [HttpAPI sendRequestWithURL:getAddressURL paramDic:nil completionBlock:^(NSDictionary *result, NSError *error){
        NSString *status = [result objectForKey:@"status"];
        if ([status isEqualToString:@"OK"]){
            NSArray *results = [result objectForKey:@"results"];
            NSDictionary *zero = [results objectAtIndex:0];
            NSString *formattedAddress = [zero objectForKey:@"formatted_address"];
            NSString *placeId = [zero objectForKey:@"place_id"];
//            NSArray *addressComponents = [zero objectForKey:@"address_components"];
//            for (int i=0;i<addressComponents.count;i++){
//                NSDictionary *zero2 = [addressComponents objectAtIndex:i];
//                NSString *long_name = [zero2 objectForKey:@"long_name"];
//                NSArray *mytypes = [zero2 objectForKey:@"types"];
//                NSString *Type = [mytypes objectAtIndex:0];
//                
//                if ((long_name || ![long_name isEqualToString:@""])){
//                    if ([Type isEqualToString:@"street_number"]){
//                        Address1 = [NSString stringWithFormat:@"%@ ", long_name];
//                    } else if ([Type isEqualToString:@"route"]){
//                        Address1 = [NSString stringWithFormat:@"%@%@", Address1, long_name];
//                    } else if ([Type isEqualToString:@"sublocality"]){
//                        Address2 = long_name;
//                    } else if ([Type isEqualToString:@"locality"]){
//                        city = long_name;
//                    } else if ([Type isEqualToString:@"administrative_area_level_2"]){
//                        County = long_name;
//                    } else if ([Type isEqualToString:@"administrative_area_level_1"]){
//                        State = long_name;
//                    } else if ([Type isEqualToString:@"postal_code"]){
//                        PIN = long_name;
//                    } else if ([Type isEqualToString:@"country"]){
//                        Country = long_name;
//                    }
//                }
//            }
//            if (Address1 && ![Address1 isEqualToString:@""]){
//                address = [NSString stringWithFormat:@"%@%@", address, Address1];
//            }
//            if (Address2 && ![Address2 isEqualToString:@""]){
//                address = [NSString stringWithFormat:@"%@, %@", address, Address2];
//            }
//            if (city && ![city isEqualToString:@""]){
//                address = [NSString stringWithFormat:@"%@, %@", address, city];
//            }
//            //            if (State && ![State isEqualToString:@""]){
//            //                address = [NSString stringWithFormat:@"%@%@", address, State];
//            //            }
//            if (Country && ![Country isEqualToString:@""]){
//                address = [NSString stringWithFormat:@"%@, %@", address, Country];
//            }
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            [result setValue:formattedAddress forKey:@"address"];
            [result setValue:placeId forKey:@"placeId"];
            completionBlock(result);
        } else {
            completionBlock(nil);
        }        
    }];
}

+ (NSString *)getOccurDays:(PFObject *)event {
    NSString *result = LOCALIZATION(@"occurs");
    int count = 0;
    if ([event[PARSE_EVENT_IS_MONDAY] boolValue]){
        result = [NSString stringWithFormat:@"%@ %@", result, LOCALIZATION(@"monday")];
        count++;
    }
    if ([event[PARSE_EVENT_IS_TUESDAY] boolValue]){
        result = (result.length>0)?[NSString stringWithFormat:@"%@ & %@", result, LOCALIZATION(@"tuesday")]:[NSString stringWithFormat:@"%@", LOCALIZATION(@"tuesday")];
        count++;
    }
    if ([event[PARSE_EVENT_IS_WEDNESDAY] boolValue]){
        result = (result.length>0)?[NSString stringWithFormat:@"%@ & %@", result, LOCALIZATION(@"wednesday")]:[NSString stringWithFormat:@"%@", LOCALIZATION(@"wednesday")];
        count++;
    }
    if ([event[PARSE_EVENT_IS_THURSDAY] boolValue]){
        result = (result.length>0)?[NSString stringWithFormat:@"%@ & %@", result, LOCALIZATION(@"thursday")]:[NSString stringWithFormat:@"%@", LOCALIZATION(@"thursday")];
        count++;
    }
    if ([event[PARSE_EVENT_IS_FRIDAY] boolValue]){
        result = (result.length>0)?[NSString stringWithFormat:@"%@ & %@", result, LOCALIZATION(@"friday")]:[NSString stringWithFormat:@"%@", LOCALIZATION(@"friday")];
        count++;
    }
    if ([event[PARSE_EVENT_IS_SATURDAY] boolValue]){
        result = (result.length>0)?[NSString stringWithFormat:@"%@ & %@", result, LOCALIZATION(@"saturday")]:[NSString stringWithFormat:@"%@", LOCALIZATION(@"saturday")];
        count++;
    }
    if ([event[PARSE_EVENT_IS_SUNDAY] boolValue]){
        result = (result.length>0)?[NSString stringWithFormat:@"%@ & %@", result, LOCALIZATION(@"sunday")]:[NSString stringWithFormat:@"%@", LOCALIZATION(@"sunday")];
        count++;
    }
    if (count == 7)
        result = LOCALIZATION(@"occurs_daily");
    return result;
}

+ (NSDate *) setTimeforDate:(NSDate *) date :(NSString *)time{
    NSDateFormatter *timeOnlyFormatter = [[NSDateFormatter alloc] init];
    [timeOnlyFormatter setDateFormat:@"h:mm"];
    [timeOnlyFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComps = [calendar components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear) fromDate:date];
    
    NSDateComponents *comps = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[timeOnlyFormatter dateFromString:time]];
    comps.day = todayComps.day;
    comps.month = todayComps.month;
    comps.year = todayComps.year;
    NSDate *result = [calendar dateFromComponents:comps];
    return result;
}

+ (NSDate *) getDateAfterWeeks:(NSInteger) weekscount :(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [NSDateComponents new];
    comp.day = weekscount * 7;
    NSDate *result = [calendar dateByAddingComponents:comp toDate:date options:0];
    return result;
}

+ (NSInteger) getDifferenceHours:(NSDate *)firstDate :(NSDate *)secondDate {
    NSTimeInterval distanceBetweenDates = [secondDate timeIntervalSinceDate:firstDate];
    double secondsInAnHour = 3600;
    NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
    return hoursBetweenDates;
}

@end

