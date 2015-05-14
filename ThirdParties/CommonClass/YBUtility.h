//
//  YBUtility.h
//  iStudent
//
//  Created by michaelwong on 9/22/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YBUtility : NSObject

#pragma mark - view
+ (void)setStarImages:(NSArray *)starImageViews rate:(float)rate; // [0, 5]

+ (void)makeRoundForView:(UIView*)view;

+ (void)makeRoundForImageView:(UIImageView*)imageView;

+ (void)makeRoundForAvatar:(UIImageView*)imageView;

+ (void)rotateView:(UIView*)view;

+ (void)scaleView:(UIView*)view scale:(float)scale;

#pragma mark - web image view
// used for small image, like avarta
+ (void)setImageView:(UIImageView*)imageView withURLString:(NSString*)urlString placeHolder:(NSString*)placeHolder;

// used for large image, like raw image
+ (void)setImageViewWithProgress:(UIImageView*)imageView withURLString:(NSString*)urlString;

#pragma mark - account validate

+ (BOOL)validateEmailWithString:(NSString*)email;
+ (BOOL)checkNicknameLength:(NSString *)nickname;
+ (BOOL)isNicknameLegal:(NSString *)nickname;
+ (BOOL)isPureInt:(NSString *)string;
+ (BOOL)validateTaomeeCodeWithString:(NSString*)code;
+ (BOOL)validatePhoneNumber:(NSString*)mobileNum;
+ (BOOL)isAccountLegal:(NSString *)account;
+ (BOOL)isPasswordLegal:(NSString *)password;

#pragma mark - account password
+ (NSString*)getPasswordWithAccount:(NSString*)phoneNumber;
+ (void)savePassword:(NSString*)password account:(NSString*)account;
+ (NSString*)getKeyChainPasswordFor:(NSString*)account;

#pragma mark - file system
+ (NSString*)getWhiteBoardCachePath;
+ (NSString*)getPlaybackCachePath;
+ (NSString*)getCachePath;
+ (NSString*)getDocumentsPath;
+ (NSString*)getLibraryPath;
+ (NSString*)getTempPath;
+ (BOOL)deleteFile:(NSString*)filePath;
+ (BOOL)copyFile:(NSString*)srcPath to:(NSString *)dstPath;
+ (BOOL)fileExists:(NSString*)filePath;
+ (NSString*)getCacheFolder4User;
+ (NSString*)getCacheSubFolder:(NSString*)subFolder;
+ (NSString*)getCacheFolder4Document;
+ (NSString*)getDownloadPath4Document:(NSString*)url;
+ (NSString*)getCacheFolder4Video;
+ (NSString*)getCacheFolder4Exam;
+ (NSString*)getCacheFolder4Couseware;
+ (NSString*)getCacheFolder4Homework;
+ (unsigned long long)getFileSize:(NSString*)filePath;
+ (unsigned long long)getFolderSize:(NSString *)folderPath;
+ (NSString*)getUsedTimeAttr:(NSString*)fileName;

#pragma mark - time format
+ (NSString*)getFormatDateTime:(NSTimeInterval)duration;
+ (NSString*)getFormatDateWithoutTime:(NSTimeInterval)duration;
+ (NSString*)getFormatTimeNoSecond:(NSTimeInterval)duration;
+ (NSString*)getFormatMinuteSecond:(NSTimeInterval)duration;
+ (NSString*)getFormatHourMinuteSecond:(NSTimeInterval)duration;
+ (NSString*)getTHourMinuteWithAMPM:(NSTimeInterval)time;
+ (NSString*)getMonDayWeek:(NSTimeInterval)time;
+ (BOOL)isToday:(NSTimeInterval)time;

#pragma mark - view controller
+ (void)displayContentController:(UIViewController*)content inViewController:(UIViewController*)controller;
+ (void)hideContentController:(UIViewController*)content inViewController:(UIViewController*)controller;

#pragma mark - UILabel

+ (CGFloat)heightForText:(NSString *)text textFont:(UIFont*)font width:(CGFloat)width;

#pragma mark - image process
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;
+ (UIImage *)scaleImageTo1024:(UIImage *)image;

#pragma mark - PDF Image
+ (UIImage*) pdfImageWithCGPDFPage:(CGPDFPageRef)page withFrame:(CGRect)frame;

#pragma mark - HUD
+ (void)hideInfoHUDInView:(UIView*)view;
+ (void)showInfoHUDInView:(UIView*)view message:(NSString*)message;
+ (void)showInfoHUDInView:(UIView*)view message:(NSString*)message time:(int)time;
+ (void)showErrorMessageInView:(UIView*)view message:(NSString*)errorMessage errorCode:(NSNumber*)errorCode;

#pragma mark - string
+ (NSString*)getHostFromRoomId:(NSString*)roomId;
+ (NSString*)getHostFrom:(NSString*)serverAddress;
+ (NSString*)getPortFrom:(NSString*)serverAddress;
+ (NSString*)getLocalizedString:(NSString*)key;
+ (NSString*)getLocalizedStringRandom:(NSArray*)keys;
+ (NSString*)getShortIdFrom:(NSString*)xmppId;

#pragma mark - common
+ (void)openURL:(NSString *)urlString;
+ (BOOL)makePhoneCall:(NSString *)phoneNumber;

#pragma mark - user data
+ (NSString *)getGradeString:(int)grade;

#pragma mark - device check
+ (BOOL)isLessPad2;
+ (BOOL)isLessPad3;

+ (NSString*)getVideoTitle:(NSString*)lessonName intros:(NSString*)intros;

@end
