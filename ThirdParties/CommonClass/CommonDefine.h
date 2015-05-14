//
//  CommonDefine.h
//  iStudent
//
//  Created by michaelwong on 9/22/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#ifndef iStudent_CommonDefinition_h
#define iStudent_CommonDefinition_h

#pragma mark - color
// blue
#define DEFAULT_COLOR_BLUE          ([UIColor colorWithRed:11/255.0f green:206/255.0f blue:255/255.0f alpha:1])
// red
#define DEFAULT_COLOR_RED           ([UIColor colorWithRed:255/255.0f green:0/255.0f blue:0/255.0f alpha:1])
// lignt blue
//#define DEFAULT_COLOR_LIGHT_BLUE    ([UIColor colorWithRed:11/255.0f green:206/255.0f blue:255/255.0f alpha:0.7])
// transparent blue
#define DEFAULT_COLOR_TRANSPARENT_BLUE    ([UIColor colorWithRed:11/255.0f green:206/255.0f blue:255/255.0f alpha:0.1])
// gray
#define DEFAULT_COLOR_GRAY          ([UIColor colorWithRed:203/255.0f green:206/255.0f blue:213/255.0f alpha:1])
// line gray
#define DEFAULT_LINE_GRAY           ([UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1])
// lignt gray
#define DEFAULT_COLOR_LIGHT_GRAY    ([UIColor colorWithRed:203/255.0f green:206/255.0f blue:213/255.0f alpha:0.7])
// transparent gray
#define DEFAULT_COLOR_TRANSPARENT_GRAY    ([UIColor colorWithRed:203/255.0f green:206/255.0f blue:213/255.0f alpha:0.1])
// white
#define DEFAULT_COLOR_WHITE         ([UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1])
// alarm red
#define DEFAULT_COLOR_ALARM_RED     ([UIColor colorWithRed:255/255.0f green:67/255.0f blue:81/255.0f alpha:1])
// lignt red
#define DEFAULT_COLOR_ALARM_LIGHT_RED    ([UIColor colorWithRed:255/255.0f green:67/255.0f blue:81/255.0f alpha:0.7])
// transparent red
#define DEFAULT_COLOR_ALARM_TRANSPARENT_RED    ([UIColor colorWithRed:255/255.0f green:67/255.0f blue:81/255.0f alpha:0.1])
// agree green
#define DEFAULT_COLOR_AGREE_GREEN   ([UIColor colorWithRed:112/255.0f green:218/255.0f blue:101/255.0f alpha:1])
// light blue
#define DEFAULT_COLOR_LIGHT_BLUE    ([UIColor colorWithRed:127/255.0f green:229/255.0f blue:255/255.0f alpha:1])
// dark blue
#define DEFAULT_COLOR_DARK_BLUE     ([UIColor colorWithRed:8/255.0f green:165/255.0f blue:204/255.0f alpha:1])
//  R:251    G:254    B:255
#define DEFAULT_DRAW_BOARD_COLOR     ([UIColor colorWithRed:251/255.0f green:254/255.0f blue:255/255.0f alpha:1])

// pen color green
#define DEFAULT_PEN_COLOR_GREEN     ([UIColor colorWithRed:112/255.0f green:218/255.0f blue:101/255.0f alpha:1])
// pen color blue
#define DEFAULT_PEN_COLOR_BLUE      ([UIColor colorWithRed:11/255.0f green:206/255.0f blue:255/255.0f alpha:1])
// pen color red
#define DEFAULT_PEN_COLOR_RED       ([UIColor colorWithRed:255/255.0f green:67/255.0f blue:81/255.0f alpha:1])

// chat message color for out
#define DEFAULT_CHAT_BUBBLE_COLOR_GRAY       ([UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1])

#pragma mark - text length
// account
#define MIN_LENGTH_FOR_ACCOUNT          (5)
#define MAX_LENGTH_FOR_ACCOUNT          (20)
// password
#define MIN_LENGTH_FOR_PASSWORD         (6)
#define MAX_LENGTH_FOR_PASSWORD         (16)
// nick name
#define MIN_LENGTH_FOR_NICKNAME         (2)
#define MAX_LENGTH_FOR_NICKNAME         (16)
// like count 10
#define MAX_LIKE_COUNT                  (15)
// init page count for whiteboard
#define MIN_WHITEBOARD_COUNT            (10)
#define MAX_WHITEBOARD_COUNT            (100)

#pragma mark - user data folder
// cache root folder
#define USER_CACHE_FOLDER               @"cache"
// folder for all user document
#define DOCUMNET_FOLDER                 @"doc"
// folder for class video
#define VIDEO_FOLDER                    @"video"
// folder for class unit exam document
#define EXAM_FOLDER                     @"exam"
// folder for class document from teacher
#define COUSEWARE_FOLDER                @"couseware"
// folder for homework document
#define HOMEWORK_FOLDER                 @"homework"

#pragma mark - whiteboard size
#define DEFAULT_WHITEBOARD_WIDTH        1024
#define DEFAULT_WHITEBOARD_HEIGHT       768

#pragma mark - popup view size
#define DEFAULT_POPOVER_WIDTH           630
#define DEFAULT_POPOVER_HEIGHT          630

// avarta
#define DEFAULT_ASSISTANT_AVATAR        @"WD_picture_head"
#define DEFAULT_TEACHER_AVATAR          @"WD_picture_head"
#define DEFAULT_STUDENT_AVATAR          @"WD_picture_head"
#define DEFAULT_CHAT_AVATAR             @"WD_picture_head"
#define IMAGE_THUMB_80                  @"_80x80.jpg"
#define IMAGE_THUMB_180                 @"_180x180.jpg"


#pragma mark - application
// keychain
#define KeyChainAccountServiceName      @"YBKeyChainAccountService"
// ios app id
// 理优1对1（家长）  952944611
// 理优1对1（学生）  954196099
// 理优1对1（老师）  954196104
// #define APPLICATION_ID                  (865731782)
#define APPLICATION_ID_PARENT           (952944611)
#define APPLICATION_ID_TEACHER          (954196104)
#define APPLICATION_ID_STUDENT          (954196099)

// image compression
#define kCompressionQuality             0.9f

//#define XMPP_HOST_NAME      @"115.28.241.77" // @"michael.local" //
//#define XMPP_MUC_SERVICE    @"conference.115.28.241.77" // @"conference.michael.local" //
//#define MCU_HOST_NAME       @"115.28.241.77" // @"michael.local" //

// common notification
#define YBNSMemoryWarning               @"YBNSMemoryWarning"

// ios version
#define IS_IOS8                         ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IPAD                         ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)

#endif
