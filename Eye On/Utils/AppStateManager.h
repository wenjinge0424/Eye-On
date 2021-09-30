//
//  AppStateManager.h
//  Partner
//
//  Created by star on 12/8/15.
//  Copyright (c) 2015 zapporoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Localisator.h"

@interface AppStateManager : NSObject

@property (assign, nonatomic) int alertCount;

@property (assign, nonatomic) BOOL isOutGoing;

@property (strong, nonatomic) PFObject *activeSession;

@property (strong, nonatomic) NSString *callerId;
@property (strong, nonatomic) NSString *callerName;
@property (strong, nonatomic) NSString *receiverId;
@property (strong, nonatomic) NSString *receiverName;

@property (strong, nonatomic) NSString *sessionID;
@property (strong, nonatomic) NSString *publisherToken;
@property (copy, nonatomic) NSString *subscriberToken;


@property (strong, nonatomic) NSString *chatRoomId;
@property (strong, nonatomic) PFObject *chatRoom;

@property (assign) BOOL isCalling;
@property (assign) BOOL isChatting;

@property (assign) BOOL shouldShowHistory;
@property (assign) BOOL shouldShowChat;

@property (strong, nonatomic) NSMutableArray *usersArray;

// Dilly
@property (strong, nonatomic) NSMutableArray *categoryArray; // subcategory ---- Name
@property (strong, nonatomic) NSMutableArray *categoryIdArray;
@property (strong, nonatomic) NSMutableArray *mainCategoryArray;
@property (assign) BOOL isCreate;
@property (strong, nonatomic) NSString *category;
@property (nonatomic) NSString *currentLanguage;
@property (strong, nonatomic) NSMutableArray *categoryRestaurant;
@property (strong, nonatomic) NSMutableArray *categoryBars;
@property (strong, nonatomic) NSMutableArray *categorySports;
@property (strong, nonatomic) NSMutableArray *categoryMusic;
@property (strong, nonatomic) NSMutableArray *categoryHotel;
@property (strong, nonatomic) NSMutableArray *categoryNetworking;

@property (strong, nonatomic) NSMutableArray *categoryIdRestaurant;
@property (strong, nonatomic) NSMutableArray *categoryIdBars;
@property (strong, nonatomic) NSMutableArray *categoryIdSports;
@property (strong, nonatomic) NSMutableArray *categoryIdMusic;
@property (strong, nonatomic) NSMutableArray *categoryIdHotel;
@property (strong, nonatomic) NSMutableArray *categoryIdNetworking;

+ (AppStateManager *)sharedInstance;

- (void)playIncomingSound;
- (void)playOutgoingSound;
- (void)stopSound;

- (void)resetAlertCount;

@end
