//
//  Config.h
//
//  Created by IOS7 on 12/16/14.
//  Copyright (c) 2014 iOS. All rights reserved.
//

#import "AppStateManager.h"
#import "Localisator.h"
/* ***************************************************************************/
/* ***************************** Category Config *****************************/
/* ***************************************************************************/

//#define CATEGORY_MAIN             [[NSArray alloc] initWithObjects:LOCALIZATION(@"category_main_restaurant"), LOCALIZATION(@"category_main_music"), LOCALIZATION(@"category_main_bars"), LOCALIZATION(@"category_main_sport"), LOCALIZATION(@"category_main_cafes"), LOCALIZATION(@"category_main_hotel"), LOCALIZATION(@"category_main_networking"),LOCALIZATION(@"category_main_clubs"), nil]

#define CATEGORY_MAIN             [[NSArray alloc] initWithObjects:@"Restaurants", @"Live Music", @"Bars \nPubs\n Clubs", @"Live Sport", @"Cafes", @"Hotels", @"Networking",@"Clubs", nil]


#define CATEGORY_RESTAURANT [[NSArray alloc] initWithObjects:LOCALIZATION(@"category_restaurant_chinese"), LOCALIZATION(@"category_restaurant_japanese"), LOCALIZATION(@"category_restaurant_malaysian"), LOCALIZATION(@"category_restaurant_thai"), LOCALIZATION(@"category_restaurant_indian"), LOCALIZATION(@"category_restaurant_korean"), LOCALIZATION(@"category_restaurant_vietnam"),LOCALIZATION(@"category_restaurant_british"),LOCALIZATION(@"category_restaurant_french"),LOCALIZATION(@"category_restaurant_german"),LOCALIZATION(@"category_restaurant_italian"),LOCALIZATION(@"category_restaurant_mediterranean"),LOCALIZATION(@"category_restaurant_russian"),LOCALIZATION(@"category_restaurant_spanish"),LOCALIZATION(@"category_restaurant_mexican"),LOCALIZATION(@"category_restaurant_tex"),LOCALIZATION(@"category_restaurant_middle_estern"),LOCALIZATION(@"category_restaurant_lebonese"), LOCALIZATION(@"category_restaurant_bbq"), nil]

#define CATEGORY_MUSIC [[NSArray alloc] initWithObjects:LOCALIZATION(@"category_music_rock"), LOCALIZATION(@"category_music_punk"), LOCALIZATION(@"category_music_reggae"), LOCALIZATION(@"category_music_soul"), LOCALIZATION(@"category_music_country_western"), LOCALIZATION(@"category_music_signer"), LOCALIZATION(@"category_music_acoustic"),LOCALIZATION(@"category_music_jazz"),LOCALIZATION(@"category_music_blues"),LOCALIZATION(@"category_music_cover_bands"),LOCALIZATION(@"category_music_open_mic"),LOCALIZATION(@"category_music_lounge"),LOCALIZATION(@"category_music_electro"),LOCALIZATION(@"category_music_techno"), nil]

#define CATEGORY_BARS [[NSArray alloc] initWithObjects:LOCALIZATION(@"category_bars_sport"), LOCALIZATION(@"category_bars_speak_easy"), LOCALIZATION(@"category_bars_cocktail"), LOCALIZATION(@"category_bars_craft"), LOCALIZATION(@"category_bars_budget"), LOCALIZATION(@"category_bars_high_end"), LOCALIZATION(@"category_bars_wine"),LOCALIZATION(@"category_bars_lounge"),LOCALIZATION(@"category_bars_themed"),LOCALIZATION(@"category_bars_quiz"),LOCALIZATION(@"category_bars_student"),LOCALIZATION(@"category_bars_cigar"),LOCALIZATION(@"category_bars_dive"),LOCALIZATION(@"category_bars_brew_house"),LOCALIZATION(@"category_bars_beach"), nil]

#define CATEGORY_SPORT [[NSArray alloc] initWithObjects:LOCALIZATION(@"category_sport_soccer"), LOCALIZATION(@"category_sport_rugby"), LOCALIZATION(@"category_sport_tennis"), LOCALIZATION(@"category_sport_nfl"), LOCALIZATION(@"category_sport_nhl"), LOCALIZATION(@"category_sport_baseball"), LOCALIZATION(@"category_sport_afl"),LOCALIZATION(@"category_sport_mma"), LOCALIZATION(@"category_sport_boxing"), LOCALIZATION(@"category_sport_winter"),nil]
#define CATEGORY_CAFE
#define CATEGORY_HOTEL
#define CATEGORY_NETWORK [[NSArray alloc] initWithObjects:LOCALIZATION(@"category_network_chambers"), LOCALIZATION(@"category_network_alumni"), LOCALIZATION(@"category_network_proffesional"), LOCALIZATION(@"category_network_charity"), LOCALIZATION(@"category_network_hobbies"), LOCALIZATION(@"category_network_school"), LOCALIZATION(@"category_network_community"), nil]

#define CATEGORY_CLUBS

#define GOOGLE_NEARBY_BASE              @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?"

#define REPORT_EMAILS                   [[NSArray alloc] initWithObjects:@"", nil]
#define ADMIN_EMAIL                     @"glenn.phelan@icloud.com"

#define CURRENCY_ALL_LIST               @"http://apilayer.net/api/list?access_key=687070b98fa0894fafe042921c2fc030"
#define CURRENCY_GET_RATE               @"http://apilayer.net/api/convert?access_key=687070b98fa0894fafe042921c2fc030&from=USD&to="
#define CURRENCY_ACCESS_KEY             @"687070b98fa0894fafe042921c2fc030"
#define KEY_CURRENCY                    @"current_currency"
#define KEY_LANGUAGE                    @"current_language"
#define LANGUAGE_ENGLISH                @"english"
#define LANGUAGE_CHINESE                @"chinese"
#define LANGUAGE_THAI                   @"thai"

/* ***************************************************************************/
/* ***************************** Stripe config ********************************/
/* ***************************************************************************/
#define STRIPE_KEY                              @""
//#define STRIPE_KEY                              @""
#define STRIPE_URL                              @"https://api.stripe.com/v1"
#define STRIPE_CHARGES                          @"charges"
#define STRIPE_CUSTOMERS                        @"customers"
#define STRIPE_TOKENS                           @"tokens"
#define STRIPE_ACCOUNTS                         @"accounts"
#define STRIPE_CONNECT_URL                      @"https://stripe.dillyapp.com"


#define APP_NAME                                                @"Dilly"
#define PARSE_FETCH_MAX_COUNT                                   10000
#define WEB_END_POINT_ITEM_SEARCH_URL                           @"http://data.enzounified.com:19551/bsc/AmazonPA/ItemSearch"
#define WEB_END_POINT_ITEM_LOOKUP_URL                           @"http://data.enzounified.com:19551/bsc/AmazonPA/ItemLookup/%@"

// Push Notification
#define PARSE_CLASS_NOTIFICATION_FIELD_TYPE                     @"type"
#define PARSE_CLASS_NOTIFICATION_FIELD_DATAINFO                 @"dataInfo"

/* Pagination values  */
#define PAGINATION_DEFAULT_COUNT                                10000
#define PAGINATION_START_INDEX                                  1

#define NOTIFICATION_PAYSUCCESS                                 @"pay_success" // choose_plan
#define NOTIFICATION_PAY_SUCCESS_EVENT                          @"pay_event"
#define NOTIFICATION_CHANGED_CATEGORY                           @"change_category"

#define MAIN_COLOR          [UIColor colorWithRed:225/255.f green:89/255.f blue:37/255.f alpha:1.f]
#define MAIN_BORDER_COLOR   [UIColor colorWithRed:186/255.f green:186/255.f blue:186/255.f alpha:1.f]
#define MAIN_BORDER1_COLOR  [UIColor colorWithRed:209/255.f green:209/255.f blue:209/255.f alpha:1.f]
#define MAIN_BORDER2_COLOR  [UIColor colorWithRed:95/255.f green:95/255.f blue:95/255.f alpha:1.f]
#define MAIN_HEADER_COLOR   [UIColor colorWithRed:103/255.f green:103/255.f blue:103/255.f alpha:1.f]
#define MAIN_SWDEL_COLOR    [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
#define MAIN_DESEL_COLOR    [UIColor colorWithRed:206/255.f green:89/255.f blue:37/255.f alpha:1.f]
#define MAIN_HOLDER_COLOR   [UIColor colorWithRed:170/255.f green:170/255.f blue:170/255.f alpha:1.f]
#define MAIN_TRANS_COLOR    [UIColor colorWithRed:230/255.f green:97/255.f blue:36/255.f alpha:1.f]
#define MAIN_BORDER_WIDTH   0.5

#define MARKER_BLUE           @"ic_marker_blue"
#define MARKER_STAR           @"ic_marker_star"
#define MARKER_GREEN          @"ic_marker_green"
#define MARKER_SIZE_WIDTH           30.0f
#define MARKER_BLUE_HEIGHT          MARKER_SIZE_WIDTH * 166 / 122
#define MARKER_STAR_HEIGHT          MARKER_SIZE_WIDTH * 189 / 122

#define AGE_LIMIT                   18
#define DEFAULT_RADIUS              40

enum {
    FLAG_TERMS_OF_SERVERICE,
    FLAG_PRIVACY_POLICY,
    FLAG_ABOUT_THE_APP
};

enum {
    NOTIFICATION_TYPE_FOLLOW,
    NOTIFICATION_TYPE_INVITE,
    NOTIFICATION_TYPE_TAGGED, // save
    NOTIFICATION_TYPE_TICKET,
    NOTIFICATION_TYPE_APPLICABLE,
    NOTIFICATION_TYPE_NOT_APPLICABLE
};

enum {
    MAP_TYPE_GOOGLE,
    MAP_TYPE_BAIDU,
    MAP_TYPE_MAPQUEST
};

enum {
    PLAN_ONE_TIME,
    PLAN_MONTHLY,
    PLAN_YEARLY
};

enum {
    INFORM_ABOUT,
    INFORM_TERMS,
    INFORM_PRIVACY
};

enum {
    REPORT_TYPE_VENUE,
    REPORT_TYPE_EVENT
};


/* Network */
#define URL_CHECK_REGION                                        @"http://ip-api.com/json"
#define RESPONSE_PARAM_COUNTRY                                  @"country"
#define COUNTRY_CHINA                                            @"China"

/* Parse Table */
#define PARSE_FIELD_OBJECT_ID                                   @"objectId"
#define PARSE_FIELD_USER                                        @"user"
#define PARSE_FIELD_CHANNELS                                    @"channels"
#define PARSE_FIELD_CREATED_AT                                  @"createdAt"
#define PARSE_FIELD_UPDATED_AT                                  @"updatedAt"

/* User Table */
#define PARSE_TABLE_USER                                        @"User"
#define PARSE_USER_FIRST_NAME                                   @"firstName"
#define PARSE_USER_LAST_NAME                                    @"lastName"
#define PARSE_USER_FULL_NAME                                    @"fullName"
#define PARSE_USER_EMAIL                                        @"email"
#define PARSE_USER_PASSWORD                                     @"password"
#define PARSE_USER_USERNAME                                     @"username"
#define PARSE_USER_AVATAR                                       @"avatar"
#define PARSE_USER_LOCATION                                     @"lonLat"
//#define PARSE_USER_BIRTHDAY                                     @"birthDay"
#define PARSE_USER_OWN_USERNAME                                 @"userName"
#define PARSE_USER_CONTACT_NUMBER                               @"phoneNumber"
#define PARSE_USER_GOOGLEID                                     @"googleid"
#define PARSE_USER_FACEBOOK_ID                                  @"facebookid"
#define PARSE_USER_WECHAT_ID                                    @"wechatid"
#define PARSE_USER_IS_VENUE_FOLLOW                              @"isVenuesFollow"
#define PARSE_USER_IS_EVENT_ATTEND                              @"isEventsAttending"
#define PARSE_USER_IS_VENUE_AREA                                @"isVenuesArea"
#define PARSE_USER_STRIPE_ACCOUNT_ID                            @"accountId"
#define PARSE_USER_HAS_VENUE                                    @"hasVenue"

/* Venue Table */
#define PARSE_TABLE_VENUE                                       @"Venue"
#define PARSE_VENUE_PLAN                                        @"plan"
#define PARSE_VENUE_NAME                                        @"name"
#define PARSE_VENUE_LOCATION_NAME                               @"locationName"
#define PARSE_VENUE_LOCATION_ADDRESS                            @"locationAddress"
#define PARSE_VENUE_LOCATION                                    @"lonLat"
#define PARSE_VENUE_LOCATION_ID                                 @"locationId"
#define PARSE_VENUE_CONTACT_NUM                                 @"phoneNumber"
#define PARSE_VENUE_EMAIL                                       @"email"
#define PARSE_VENUE_WEB_SITE                                    @"webSite"
#define PARSE_VENUE_DESCRIPTION                                 @"description"
#define PARSE_VENUE_OPERATING_HOURS                             @"operatingHours"
#define PARSE_VENUE_OWNER                                       @"owner"
#define PARSE_VENUE_AVAILABLE                                   @"isAvailable"
#define PARSE_VENUE_FOLLOWERS                                   @"followers"
#define PARSE_VENUE_IMAGE                                       @"image"
#define PARSE_VENUE_MUTE_LIST                                   @"muteList"

/* Event Table */
#define PARSE_TABLE_EVENT                                       @"Event"
#define PARSE_EVENT_VENUE                                       @"venue"
#define PARSE_EVENT_OWNER                                       @"owner"
#define PARSE_EVENT_IS_REPEAT                                   @"isRepeat"
#define PARSE_EVENT_NAME                                        @"name"
#define PARSE_EVENT_IS_PRIVATE                                  @"isPrivate"
#define PARSE_EVENT_WEEKCOUNT                                   @"weekCount"
#define PARSE_EVENT_IS_MONDAY                                   @"isMonday"
#define PARSE_EVENT_IS_TUESDAY                                  @"isTuesday"
#define PARSE_EVENT_IS_WEDNESDAY                                @"isWednesday"
#define PARSE_EVENT_IS_THURSDAY                                 @"isThursday"
#define PARSE_EVENT_IS_FRIDAY                                   @"isFriday"
#define PARSE_EVENT_IS_SATURDAY                                 @"isSaturday"
#define PARSE_EVENT_IS_SUNDAY                                   @"isSunday"
#define PARSE_EVENT_IS_FREE                                     @"isFree"
#define PARSE_EVENT_AMOUNT                                      @"price"
#define PARSE_EVENT_EMAIL                                       @"email"
#define PARSE_EVENT_CONTACT_NUM                                 @"phoneNumber"
#define PARSE_EVENT_IMAGE                                       @"image"
#define PARSE_EVENT_START_DATE                                  @"startDate"
#define PARSE_EVENT_END_DATE                                    @"endDate"
#define PARSE_EVENT_CALC_END_DATE                               @"calcEndDate"
#define PARSE_EVENT_SAVER_UESRS                                 @"saveUserList"
#define PARSE_EVENT_LOCATION                                    @"lonLat"
#define PARSE_EVENT_ADDRESS                                     @"locationAddress"
#define PARSE_EVENT_GOING_USERS                                 @"ticketUserList"
#define PARSE_EVENT_PRIVATE_UESRS                               @"privateUserList"
#define PARSE_EVENT_CATEGORY                                    @"category"
#define PARSE_EVENT_DESCRIPTION                                 @"description"

/* Offer Table */
#define PARSE_TABLE_OFFER                                       @"Offer"
#define PARSE_OFFER_TITLE                                       @"title"
#define PARSE_OFFER_QUANTY                                      @"quanty"
#define PARSE_OFFER_EVENT                                       @"event"
#define PARSE_OFFER_REDEEM_USERS                                @"redeemUsers"

/* Notificatino Table */
#define PARSE_TABLE_NOTIFICATION                                @"Notification"
#define PARSE_NOTIFICATION_FROM_USER                            @"fromUser"
#define PARSE_NOTIFICATION_TO_USER                              @"toUser"
#define PARSE_NOTIFICATION_MESSAGE                              @"message"
#define PARSE_NOTIFICATION_TYPE                                 @"type"
#define PARSE_NOTIFICATION_EVENT                                @"event"
#define PARSE_NOTIFICATION_VENUE                                @"venue"

/* Payment History */
#define PARSE_TABLE_PAY_HISTORY                                 @"PaymentHistory"
#define PARSE_PAYMENT_AMOUNT                                    @"amount"
#define PARSE_PAYMENT_DESCRIPTION                               @"description"
#define PARSE_PAYMENT_FROM_USER                                 @"fromUser"
#define PARSE_PAYMENT_TO_USER                                   @"toUser"
#define PARSE_PAYMENT_VENUE                                     @"venue"
#define PARSE_PAYMENT_EVENT                                     @"event"

/* Report Table */
#define PARSE_TABLE_REPORT                                      @"Report"
#define PARSE_REPORT_SENDER                                     @"sender"
#define PARSE_REPORT_MESSAGE                                    @"message"
#define PARSE_REPORT_VENUE                                      @"venue"
#define PARSE_REPORT_EVENT                                      @"event"
#define PARSE_REPORT_OWNER                                      @"owner"

/* Category Table */
#define PARSE_TABLE_SUB_CATEGORY                                @"SubCategory"
#define PARSE_SUB_CATEGORY_MAIN                                 @"mainCategory"
#define PARSE_SUB_CATEGORY_NAME                                 @"name"
#define PARSE_SUB_CATEGORY_MAIN_NAME                            @"main"
#define PARSE_SUB_CATEGORY_ID                                   @"categoryId"

#define PARSE_TABLE_MAIN_CATEGORY                               @"MainCategory"
#define PARSE_CATEGORY_NAME                                     @"name"
