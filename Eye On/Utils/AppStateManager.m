//
//  AppStateManager.m
//  Partner
//
//  Created by star on 12/8/15.
//  Copyright (c) 2015 zapporoo. All rights reserved.
//

#import "AppStateManager.h"
#import <AVFoundation/AVFoundation.h>


#define SOUND_VOLUME    1.0
#define INCOMING_SOUND  @"incoming_call_ring.wav"
#define OUTGOING_SOUND  @"outgoing_call_ring.wav"

static AppStateManager *sharedInstance = nil;

@interface AppStateManager() <AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioPlayer;
}
@end

@implementation AppStateManager

+ (AppStateManager *)sharedInstance {
    
    if (!sharedInstance) {
        sharedInstance = [[AppStateManager alloc] init];
        sharedInstance.alertCount = 0;
        sharedInstance.chatRoomId = @"";
        sharedInstance.chatRoom = nil;
        sharedInstance.categoryArray = [[NSMutableArray alloc] init];
        sharedInstance.categoryIdArray = [[NSMutableArray alloc] init];
        sharedInstance.mainCategoryArray = [[NSMutableArray alloc] init];
        sharedInstance.isCreate = NO;
        
        sharedInstance.categoryRestaurant = [[NSMutableArray alloc] init];
        sharedInstance.categoryBars = [[NSMutableArray alloc] init];
        sharedInstance.categorySports = [[NSMutableArray alloc] init];
        sharedInstance.categoryMusic = [[NSMutableArray alloc] init];
        sharedInstance.categoryHotel = [[NSMutableArray alloc] init];
        sharedInstance.categoryNetworking = [[NSMutableArray alloc] init];
    }
    
    return sharedInstance;
}

- (void)playIncomingSound {
    if (audioPlayer) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    NSURL *urlPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], INCOMING_SOUND]];
    NSError *err = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPath error:&err];
    audioPlayer.numberOfLoops = -1;
    audioPlayer.delegate = self;
    [audioPlayer setVolume:SOUND_VOLUME];
    [audioPlayer play];
}

- (void)playOutgoingSound {
    if (audioPlayer) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    NSURL *urlPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], OUTGOING_SOUND]];
    NSError *err = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPath error:&err];
    audioPlayer.numberOfLoops = -1;
    audioPlayer.delegate = self;
    [audioPlayer setVolume:SOUND_VOLUME];
    [audioPlayer play];
}

- (void)stopSound {
    if (audioPlayer) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
}

- (void)resetAlertCount {
    self.alertCount = 0;
}

@end
