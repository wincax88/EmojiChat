//
//  YBUtility.m
//  iStudent
//
//  Created by michaelwong on 9/22/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "YBUtility.h"
#import "UIImageView+WebCache.h"
#import "CommonDefine.h"
#import "SSKeychain.h"
#import "MBProgressHUD.h"
#import "MD5.h"
#import <sys/xattr.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#define MBPROGRESS_HUD_TAG      140326

@implementation YBUtility

#pragma mark - view
+ (void)setStarImages:(NSArray *)starImageViews rate:(float)rate // [0, 5]
{
    NSParameterAssert(rate >= 0 && rate <= 5);
    int index = 1;
    
    starImageViews = [starImageViews sortedArrayUsingComparator:^NSComparisonResult(id objA, id objB){
        return(
               ([objA frame].origin.x < [objB frame].origin.x) ? NSOrderedAscending :
               ([objA frame].origin.x > [objB frame].origin.x) ? NSOrderedDescending :
               NSOrderedSame);
    }];
    
    for (UIImageView *star in starImageViews) {
        if ((int)(floorf(rate)) >= index) {
            [star setImage:[UIImage imageNamed:@"star_gray"]];
        }
        else if ((int)(ceilf(rate)) >= index) {
            [star setImage:[UIImage imageNamed:@"star_gray_half"]];
        }
        else {
            [star setImage:[UIImage imageNamed:@"star_blank"]];
        }
        index++;
    }
    
}

+ (void)rotateView:(UIView*)view
{
    // rotate view
    double rads = 90 / 180.0 * M_PI;
    CGAffineTransform transform = CGAffineTransformRotate(view.transform, rads);
    view.transform = transform;
}

+ (void)scaleView:(UIView*)view scale:(float)scale
{
    CGAffineTransform transform = CGAffineTransformScale(view.transform, scale, scale);
    view.transform = transform;
}

+ (void)makeRoundForView:(UIView*)view {
    if (!view) {
        return;
    }
    CGRect rect = view.bounds;
    view.layer.cornerRadius = rect.size.width/2;
    view.layer.masksToBounds = YES;
}

+ (void)makeRoundForImageView:(UIImageView*)imageView {
    if (!imageView) {
        return;
    }
    CGRect rect = imageView.bounds;
    imageView.layer.cornerRadius = rect.size.width/2;
    imageView.layer.masksToBounds = YES;
    
    imageView.layer.borderWidth = 1.0f;
    // 250,250,250
    imageView.layer.borderColor = [[UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f] CGColor];

}

+ (void)makeRoundForAvatar:(UIImageView*)imageView
{
    if (!imageView) {
        return;
    }
    CGRect rect = imageView.bounds;
    imageView.layer.cornerRadius = rect.size.width/2;
    imageView.layer.masksToBounds = YES;
    
    imageView.layer.borderWidth = 1.0f;
    imageView.layer.borderColor = [[UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1.0f] CGColor];
}

#pragma mark - web image view

+ (void)setImageView:(UIImageView*)imageView withURLString:(NSString*)urlString placeHolder:(NSString*)placeHolder
{
    if (!imageView && (!urlString || !placeHolder)) {
        NSParameterAssert(false);
        return;
    }
    [imageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:placeHolder]];
}

+ (void)setImageViewWithProgress:(UIImageView*)imageView withURLString:(NSString*)urlString
{
    if (!imageView || !urlString) {
        NSParameterAssert(false);
        return;
    }
    __block UIActivityIndicatorView *activityIndicator;
    __weak UIImageView *weakImageView = imageView;
    NSString *thumbUrl = [urlString stringByAppendingString:@"?imageView/0/h/256"];
    [imageView sd_setImageWithURL:[NSURL URLWithString:thumbUrl]
                      placeholderImage:nil
                               options:SDWebImageProgressiveDownload
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  if (!activityIndicator) {
                                      [weakImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
                                      activityIndicator.center = weakImageView.center;
                                      [activityIndicator startAnimating];
                                  }
                              }
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 [activityIndicator removeFromSuperview];
                                 activityIndicator = nil;
                             }];
}

#pragma mark - account validate
+ (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"（^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4})";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)checkNicknameLength:(NSString *)nickname
{
    NSString* userName = [nickname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger nickLen = [userName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (nickLen < 6 || nickLen > 16) {
        return NO;
    };
    return YES;
}

// 数字、字母、下划线、中文
// 1、长度限制：3-8个汉字或6-16个英文字符。
// 2、不可使用除“_”以外的特殊字符。
// 3、昵称中不可使用空格。
+ (BOOL)isNicknameLegal:(NSString *)nickname
{
    NSString* userName = [nickname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *regex = [NSString stringWithFormat:@"(^[a-zA-Z0-9_\u4e00-\u9fa5]{%d,%d}$)", MIN_LENGTH_FOR_NICKNAME, MAX_LENGTH_FOR_NICKNAME];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    // NSUTF16StringEncoding
    if (![predicate evaluateWithObject:userName])
    {
        return NO;
    }
    
    return YES;
}

+ (BOOL)validateTaomeeCodeWithString:(NSString*)code
{
    NSString *regex = @"[0-9]]{5,9}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:code];
}

+ (BOOL)isPureInt:(NSString *)string {
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (BOOL)validatePhoneNumber:(NSString*)mobileNum
{
#ifdef DEBUG
    return YES;
#else
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return ([mobileNum length] == 11);
    }
#endif
}

+ (BOOL)isAccountLegal:(NSString *)account
{
    NSString* userName = [account stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // is email ?
    if ([YBUtility validateEmailWithString:userName]) {
        return YES;
    }
    // is mimi code
    if ([YBUtility validateTaomeeCodeWithString:userName]) {
        return YES;
    }
    // is phone number
    if ([YBUtility validatePhoneNumber:userName]) {
        return YES;
    }
    // self defines
    NSString *regex = [NSString stringWithFormat:@"(^[A-Za-z0-9_]{%d,%d}$)", MIN_LENGTH_FOR_ACCOUNT, MAX_LENGTH_FOR_ACCOUNT];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([predicate evaluateWithObject:userName])
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isPasswordLegal:(NSString *)password
{
    NSString *regex = [NSString stringWithFormat:@"(^[A-Za-z0-9_]{%d,%d}$)", MIN_LENGTH_FOR_PASSWORD, MAX_LENGTH_FOR_PASSWORD];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if (![predicate evaluateWithObject:password])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - account password
+ (NSString*)getPasswordWithAccount:(NSString *)phoneNumber
{
    NSString *password = [SSKeychain passwordForService:KeyChainAccountServiceName account:phoneNumber];
    return password;
}

+ (void)savePassword:(NSString *)password account:(NSString *)account
{
    NSString *md5Password = [password length] >= 32 ? password : [MD5 md5WithoutKey:password];
    [SSKeychain setPassword:md5Password forService:KeyChainAccountServiceName account:account];
}

#pragma mark - file system
+ (NSString*)getWhiteBoardCachePath
{
    NSString *cachePath = [[YBUtility getCachePath] stringByAppendingPathComponent:@"cache"];
    BOOL isDir = NO;
    NSError *error;
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    isDir = NO;
    cachePath = [cachePath stringByAppendingPathComponent:@"whiteboard"];
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    cachePath = [cachePath stringByAppendingString:@"/"];
    return cachePath;
}

+ (NSString*)getPlaybackCachePath
{
    NSString *cachePath = [[YBUtility getCachePath] stringByAppendingPathComponent:@"cache"];
    BOOL isDir = NO;
    NSError *error;
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    isDir = NO;
    cachePath = [cachePath stringByAppendingPathComponent:@"playback"];
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    cachePath = [cachePath stringByAppendingString:@"/"];
    return cachePath;
}

+ (NSString*)getCachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError *error;
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    cachePath = [cachePath stringByAppendingString:@"/"];
    return cachePath;
}

+ (NSString*)getDocumentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingString:@"/"];
    return documentsDirectory;
}

+ (NSString*)getLibraryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    libraryDirectory = [libraryDirectory stringByAppendingString:@"/"];
    return libraryDirectory;
}

+ (NSString*)getTempPath
{
    return NSTemporaryDirectory();
}

+ (BOOL)fileExists:(NSString*)filePath {
    BOOL result = NO;
    NSFileManager *manager = [NSFileManager defaultManager];
    result = [manager fileExistsAtPath:filePath];
    
    return result;
}

+ (BOOL)deleteFile:(NSString*)filePath
{
    if ([YBUtility fileExists:filePath])
    {
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:&error];
        if (!error)
        {
            return YES;
        }
        
    }
    return NO;
}

+ (BOOL)copyFile:(NSString*)srcPath to:(NSString *)dstPath
{
    if (![YBUtility fileExists:srcPath])
    {
        return NO;
    }
    if ([YBUtility fileExists:dstPath])
    {
        [YBUtility deleteFile:dstPath];
    }
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager copyItemAtPath:srcPath toPath:dstPath error:&error]){
        return NO;
    }
    if (!error)
    {
        return YES;
    }
    return NO;
}

+ (NSString *)getCacheFolder4User
{
    NSString* cachePath = [YBUtility getCachePath];
    cachePath = [cachePath stringByAppendingPathComponent:USER_CACHE_FOLDER];
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir])
    {
        NSError *error;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
        NSAssert(result, @"");
    }
    return cachePath;
}

+ (NSString *)getCacheSubFolder:(NSString*)subFolder
{
    NSParameterAssert(subFolder);
    NSString *rootPath = [YBUtility getCacheFolder4User];
    BOOL isDir = YES;
    NSString *dir = [rootPath stringByAppendingPathComponent:subFolder];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir])
    {
        NSError *error;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        NSAssert(result, @"");
    }
    return dir;
}

+ (NSString*)getCacheFolder4Document
{
    return [YBUtility getCacheSubFolder:DOCUMNET_FOLDER];
}

+ (NSString*)getDownloadPath4Document:(NSString*)url
{
    NSString *filename = [url lastPathComponent];
    NSString *docPath = [YBUtility getCacheFolder4Document];
    docPath = [docPath stringByAppendingPathComponent:filename];
    
    return docPath;
}

+ (NSString *)getCacheFolder4Video
{
    return [YBUtility getCacheSubFolder:VIDEO_FOLDER];
}

+ (NSString *)getCacheFolder4Exam
{
    return [YBUtility getCacheSubFolder:EXAM_FOLDER];
}

+ (NSString *)getCacheFolder4Couseware
{
    return [YBUtility getCacheSubFolder:COUSEWARE_FOLDER];
}

+ (NSString *)getCacheFolder4Homework
{
    return [YBUtility getCacheSubFolder:HOMEWORK_FOLDER];
}

+ (unsigned long long)getFileSize:(NSString*)filePath
{
    unsigned long long size = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *arrtibutes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size = [arrtibutes fileSize];
    }
    return size;
}

+ (unsigned long long)getFolderSize:(NSString *)folderPath {
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}

+ (NSString*)getUsedTimeAttr:(NSString*)fileName
{
    const char *filePath = [fileName UTF8String];
    const char *attrName = [@"usedTime" UTF8String];
    
    // get size of needed buffer
    ssize_t bufferLength = getxattr(filePath, attrName, NULL, 0, 0, 0);
    NSString *timeAttr;
    if (bufferLength > 0) {
        // make a buffer of sufficient length
        char *buffer = malloc(bufferLength);
        memset(buffer, 0, bufferLength);
        // now actually get the attribute string
        getxattr(filePath, attrName, buffer, bufferLength, 0, 0);
        
        if (buffer) {
            timeAttr = [NSString stringWithUTF8String:buffer];
            free(buffer);
        }
    }
    return timeAttr;
}

#pragma mark - time format
+ (NSString*)getFormatDateTime:(NSTimeInterval)duration
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:duration];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (NSString*)getFormatDateWithoutTime:(NSTimeInterval)duration
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:duration];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (NSString*)getFormatTimeNoSecond:(NSTimeInterval)duration
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:duration];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (NSString*)getFormatMinuteSecond:(NSTimeInterval)duration
{
    if (duration <= 0) {
        return @"00 : 00";
    }
    else {
        int minute = (int)(duration / 60);
        int second = (int)duration % 60;
        NSString *timeString = [NSString stringWithFormat:@"%02d : %02d", minute, second];
        return timeString;
    }
}

+ (NSString*)getFormatHourMinuteSecond:(NSTimeInterval)duration
{
    if (duration <= 0) {
        return @"00:00:00";
    }
    else {
        int hour = (int)(duration / 3600);
        int minute = (int)(duration / 60);
        int second = (int)duration % 60;
        NSString *timeString = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
        if (hour <= 0) {
            timeString = [NSString stringWithFormat:@"%02d:%02d", minute, second];
        }
        return timeString;
    }
}

+ (NSString*)getTHourMinuteWithAMPM:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (NSString*)getMonDayWeek:(NSTimeInterval)time
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"MM月dd日 EEE"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (BOOL)isToday:(NSTimeInterval)time
{
    BOOL today = NO;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSCalendarUnit units = NSDayCalendarUnit;
    
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];
    
    if (components.day <= 0) {
        today = YES;
    }
    return today;
}
#pragma mark - key chain
+ (void)storeAccount:(NSString *)account andPassword:(NSString *)password
{
    [SSKeychain setPassword:password forService:KeyChainAccountServiceName account:account];
}

+ (void)storeAccountWithoutPassword:(NSString *)account
{
    [self storeAccount:account andPassword:@""];
}

+ (void)removeStoredPasswordForAccount:(NSString *)account
{
    [SSKeychain deletePasswordForService:KeyChainAccountServiceName account:account];
}

+ (NSArray *)allStoredUser
{
    NSArray *savedAccount = [SSKeychain accountsForService:KeyChainAccountServiceName];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger cnt = [savedAccount count];
    for (NSInteger i = cnt - 1; i >= 0; --i)
    {
        NSDictionary *dic = [savedAccount objectAtIndex:i];
        NSString *userId = [dic objectForKey:kSSKeychainAccountKey];
        NSString *password = [SSKeychain passwordForService:KeyChainAccountServiceName account:userId];
        [array addObject: @{ userId : password }];
    }
    
    return (cnt == 0) ? nil : array;
}

+ (void)getLastAccount:(NSString **)account andPassword:(NSString **)password
{
    NSDictionary *dic = [[SSKeychain accountsForService:KeyChainAccountServiceName] lastObject];
    *account = [dic objectForKey:kSSKeychainAccountKey];
    if ([*account length] == 0)
    {
        *password = nil;
    }
    else
    {
        *password = [SSKeychain passwordForService:KeyChainAccountServiceName account:*account];
    }
}

+ (NSString*)getKeyChainPasswordFor:(NSString*)account {
    NSString *password = nil;
    NSArray *savedAccount = [SSKeychain accountsForService:KeyChainAccountServiceName];
    for (NSDictionary *dic in savedAccount) {
        NSString *userId = [dic objectForKey:kSSKeychainAccountKey];
        if ([userId isEqual:account]) {
            password = [SSKeychain passwordForService:KeyChainAccountServiceName account:userId];
            if ([password length] < 32) {
                // md5
                password = [MD5 md5WithoutKey:password];
            }
            break;
        }
    }
    
    return password;
}

+ (void)displayContentController:(UIViewController*)content inViewController:(UIViewController*)controller {
    [controller addChildViewController:content];
    [controller.view addSubview:content.view];
    CGRect rect = controller.view.bounds;
    content.view.frame = rect;
    [content didMoveToParentViewController:controller];
}

+ (void)hideContentController:(UIViewController*)content inViewController:(UIViewController*)controller {
    
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

+ (CGFloat)heightForText:(NSString *)text textFont:(UIFont*)font width:(CGFloat)width

{
    NSDictionary *attrbute = @{NSFontAttributeName:font};
    
    return [text boundingRectWithSize:CGSizeMake(width, 4000) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:attrbute context:nil].size.height;
    
}

#pragma mark - image process
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0f);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)scaleImageTo1024:(UIImage *)image
{
    UIImage *imageScaled = image;
    // scale image to small size
    if (image.size.height > 1024 ||
        image.size.width > 1024 ) {
        float scaleHeight = 1024/image.size.height;
        float scaleWidth = 1024/image.size.width;
        float scale = MIN(scaleHeight, scaleWidth);
        CGSize scaledSize = CGSizeMake(image.size.width*scale, image.size.height*scale);
        imageScaled = [YBUtility scaleImage:image toSize:scaledSize];
    }
    return imageScaled;
}

+ (UIImage*) pdfImageWithCGPDFPage:(CGPDFPageRef)page withFrame:(CGRect)frame {
    CGFloat thumb_w = frame.size.width; // Maximum thumb width
    CGFloat thumb_h = frame.size.height; // Maximum thumb height
    
    CGRect cropBoxRect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    CGRect mediaBoxRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
    
    NSInteger pageRotate = CGPDFPageGetRotationAngle(page); // Angle
    CGFloat page_w = 0.0f; CGFloat page_h = 0.0f; // Rotated page size
    
    switch (pageRotate) // Page rotation (in degrees)
    {
        default: // Default case
        case 0: case 180: // 0 and 180 degrees
        {
            page_w = effectiveRect.size.width;
            page_h = effectiveRect.size.height;
            break;
        }
            
        case 90: case 270: // 90 and 270 degrees
        {
            page_h = effectiveRect.size.width;
            page_w = effectiveRect.size.height;
            break;
        }
    }
    CGFloat scale_w = (thumb_w / page_w); // Width scale
    CGFloat scale_h = (thumb_h / page_h); // Height scale
    CGFloat scale = 0.0f; // Page to target thumb size scale
    
    if (page_h > page_w)
        scale = ((thumb_h > thumb_w) ? scale_w : scale_h); // Portrait
    else
        scale = ((thumb_h < thumb_w) ? scale_h : scale_w); // Landscape
    
    NSInteger target_w = (page_w * scale); // Integer target thumb width
    NSInteger target_h = (page_h * scale); // Integer target thumb height
    
    if (target_w % 2) target_w--; if (target_h % 2) target_h--; // Even
    
    target_w *= 1; target_h *= 1; // Screen scale
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB(); // RGB color space
    CGBitmapInfo bmi = (kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    CGContextRef context = CGBitmapContextCreate(NULL, target_w, target_h, 8, 0, rgb, bmi);
    
    if (context != NULL) // Must have a valid custom CGBitmap context to draw into
    {
        CGRect thumbRect = CGRectMake(0.0f, 0.0f, target_w, target_h); // Target thumb rect
        CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); CGContextFillRect(context, thumbRect); // White fill
        CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, thumbRect, 0, true)); // Fit rect
        //CGContextSetRenderingIntent(context, kCGRenderingIntentDefault); CGContextSetInterpolationQuality(context, kCGInterpolationDefault);
        CGContextDrawPDFPage(context, page); // Render the PDF page into the custom CGBitmap context
        CGImageRef imageRef = CGBitmapContextCreateImage(context); // Create CGImage from custom CGBitmap context
        CGContextRelease(context); // Release custom CGBitmap context reference
        if (imageRef != NULL) // Create UIImage from CGImage and show it, then save thumb as PNG
        {
            UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
            CGImageRelease(imageRef);
            CGColorSpaceRelease(rgb);
            return image;
        }
    }
    CGColorSpaceRelease(rgb); // Release device RGB color space reference
    return NULL;
}

#pragma mark - HUD
+ (void)showInfoHUDInView:(UIView*)view message:(NSString*)message
{
    if (!view) {
        return;
    }
    UIView *hudView = [view viewWithTag:MBPROGRESS_HUD_TAG];
    if (hudView) {
        [hudView removeFromSuperview];
    }
    MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    hud.tag = MBPROGRESS_HUD_TAG;
    if (message && [message length] > 0) {
        // Set custom view mode
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = message;
    }
    hud.removeFromSuperViewOnHide = YES;
    hud.minShowTime = 1.5f;
    [hud show:YES];
    if ([message length] > 0) {
        [hud hide:YES afterDelay:2];
    }
    else {
        [hud hide:YES afterDelay:10];
    }
}

+ (void)showInfoHUDInView:(UIView*)view message:(NSString*)message time:(int)time
{
    if (!view) {
        return;
    }
    UIView *hudView = [view viewWithTag:MBPROGRESS_HUD_TAG];
    if (hudView) {
        [hudView removeFromSuperview];
    }
    MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    hud.tag = MBPROGRESS_HUD_TAG;
    if (message && [message length] > 0) {
        // Set custom view mode
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = message;
    }
    hud.removeFromSuperViewOnHide = YES;
    hud.minShowTime = 1.5f;
    [hud show:YES];
    if (time > 0) {
        [hud hide:YES afterDelay:time];
    }
}

+ (void)showErrorMessageInView:(UIView*)view message:(NSString*)errorMessage errorCode:(NSNumber*)errorCode
{
    // show error message
    if (!errorMessage && !errorCode) {
        return;
    }
    NSString *message = [errorMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (message && [message length] > 0) {
        [YBUtility showInfoHUDInView:view message:message];
    }
    else {
        NSString* message = [YBUtility getErrorString:errorCode];
        [YBUtility showInfoHUDInView:view message:message];
    }
}

+ (void)hideInfoHUDInView:(UIView*)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

+ (NSString*)getErrorString:(NSNumber*)errorCode {
    NSString *key = [NSString stringWithFormat:@"NETWORK_ERROR_%d", [errorCode intValue]];
    NSString *table = @"networkError";
    NSString *message = NSLocalizedStringFromTable(key, table, nil);
    if ([message length] <= 0 || [message hasPrefix:@"NETWORK_ERROR_"]) {
        message = [NSString stringWithFormat:@"网络错误（%@）", errorCode];
    }
    return message;
}

#pragma mark - string
// l_161y3y3@conference.192.168.0.5
+ (NSString*)getHostFromRoomId:(NSString*)roomId
{
    NSArray *subStrings = [roomId componentsSeparatedByString:@"@conference."];
    if ([subStrings count] >= 2) {
        return [subStrings objectAtIndex:1];
    }
    return nil;
}
// 10.1.10.173:5060
+ (NSString*)getHostFrom:(NSString*)serverAddress
{
    NSArray *subStrings = [serverAddress componentsSeparatedByString:@":"];
    if ([subStrings count] >= 2) {
        return [subStrings objectAtIndex:0];
    }
    return nil;
}

+ (NSString*)getPortFrom:(NSString*)serverAddress
{
    NSArray *subStrings = [serverAddress componentsSeparatedByString:@":"];
    if ([subStrings count] >= 2) {
        return [subStrings objectAtIndex:1];
    }
    return nil;
}

// get localized string
+ (NSString*)getLocalizedString:(NSString*)key
{
    if (key.length <= 0) {
        NSParameterAssert(false);
        return nil;
    }
    NSString *result = NSLocalizedString(key, @"");
    if (result.length <= 0 || [result isEqualToString:key]) {
        //NSParameterAssert(false);
    }
    return result;
}

+ (NSString*)getLocalizedStringRandom:(NSArray*)keys
{
    NSUInteger count = keys.count;
    if (count <= 0) {
        NSParameterAssert(false);
        return nil;
    }
    u_int32_t random = arc4random();
    int index = random % count;
    NSString *key = [keys objectAtIndex:index];
    NSParameterAssert(key.length > 0);
    NSString *result = NSLocalizedString(key, @"");
    if (result.length <= 0 || [result isEqualToString:key]) {
        NSParameterAssert(false);
    }
    return result;
}

+ (NSString*)getShortIdFrom:(NSString*)xmppId
{
    NSString *shortId = xmppId;
    NSRange range = [shortId rangeOfString:@"@"];
    if (range.location != NSNotFound) {
        shortId = [shortId substringToIndex:range.location];
    }
    return shortId;
}

#pragma mark - common
+ (void)openURL:(NSString *)urlString
{
    if ([urlString length] > 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

+ (BOOL)makePhoneCall:(NSString *)phoneNumber
{
    if ([phoneNumber length] > 0)
    {
        //NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]];
        //return [[UIApplication sharedApplication] openURL:telURL];
        NSString *telURL = [@"telprompt://" stringByAppendingString:phoneNumber];
        return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telURL]];
    }
    return NO;
}

#pragma mark - user data
+ (NSString *)getGradeString:(int)grade
{
    NSString *result = @"";
    switch (grade) {
        case 106:
            result = @"六年级";
            break;
        case 201:
            result = @"七年级";
            break;
        case 202:
            result = @"八年级";
            break;
        case 203:
            result = @"九年级";
            break;
            
        default:
            break;
    }
    return result;
    
}

#pragma mark - device check
+ (BOOL)isLessPad2
{
    BOOL result = NO;
    size_t size = 100;
    char *hw_machine = malloc(size);
    int name[] = {CTL_HW,HW_MACHINE};
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    if ([hardware isEqualToString:@"iPad2,1"] ||
        [hardware isEqualToString:@"iPad2,2"] ||
        [hardware isEqualToString:@"iPad2,3"] ||
        [hardware isEqualToString:@"iPad2,4"] ||
        [hardware isEqualToString:@"iPad2,5"] ||
        [hardware isEqualToString:@"iPad2,6"] ||
        [hardware isEqualToString:@"iPad2,7"] ||
        [hardware isEqualToString:@"iPad1,1"] ||
        [hardware isEqualToString:@"iPad1,2"]
        )
    {
        result = YES;
    }
    
    return result;
}
+ (BOOL)isLessPad3
{
    BOOL result = NO;
    size_t size = 100;
    char *hw_machine = malloc(size);
    int name[] = {CTL_HW,HW_MACHINE};
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    if ([hardware isEqualToString:@"iPad3,1"] ||
        [hardware isEqualToString:@"iPad3,2"] ||
        [hardware isEqualToString:@"iPad3,3"] ||
        [hardware isEqualToString:@"iPad3,4"] ||
        [hardware isEqualToString:@"iPad2,1"] ||
        [hardware isEqualToString:@"iPad2,2"] ||
        [hardware isEqualToString:@"iPad2,3"] ||
        [hardware isEqualToString:@"iPad2,4"] ||
        [hardware isEqualToString:@"iPad2,5"] ||
        [hardware isEqualToString:@"iPad2,6"] ||
        [hardware isEqualToString:@"iPad2,7"] ||
        [hardware isEqualToString:@"iPad1,1"] ||
        [hardware isEqualToString:@"iPad1,2"]
        )
    {
        result = YES;
    }
    
    return result;
}

+ (NSString*)getVideoTitle:(NSString*)lessonName intros:(NSString*)intros
{
    NSString* title = lessonName;
    NSArray* lessonIntros = [intros componentsSeparatedByString:@"|"];
    if (lessonIntros.count == 2) {
        if ([[lessonIntros objectAtIndex:0] isEqualToString:[lessonIntros objectAtIndex:1]]) {
            title = [NSString stringWithFormat:@"%@ (%@)", lessonName, [lessonIntros objectAtIndex:0]];
        }
        else {
            title = [NSString stringWithFormat:@"%@ (%@ | %@)", lessonName, [lessonIntros objectAtIndex:0], [lessonIntros objectAtIndex:1]];
        }
    }
    else if (lessonIntros.count == 1) {
        title = [NSString stringWithFormat:@"%@ (%@)", lessonName, [lessonIntros objectAtIndex:0]];
    }
    return title;
}

@end
