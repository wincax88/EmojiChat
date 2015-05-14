//
//  HttpClient.h
//  TaoLaoShiHttp
//
//  Created by michaelwong on 6/18/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//
// tao_teacher 123456q for teacher side

#import <Foundation/Foundation.h>

#define TM_NOTIFICATION_NETWORKING_ERROR    @"TM_NOTIFICATION_NETWORKING_ERROR"

#define IMAGE_THUMB_100             @"_100x100.jpg"
#define IMAGE_THUMB_160             @"_160x160.jpg"

#define TM_NOTIFICATION_NETWORKING_ERROR    @"TM_NOTIFICATION_NETWORKING_ERROR"

#define IMAGE_THUMB_100             @"_100x100.jpg"
#define IMAGE_THUMB_160             @"_160x160.jpg"

#ifdef PUBLICTEST  // pre-distribution url

#define YBWEB_COMMON_SERVER_URL     @"http://test.comm.weiyi.com/"
#define YBWEB_SERVER_URL            @"http://test.sx.yb1v1.com/"

#elif DISTRIBUTION      // distribution url

#define YBWEB_COMMON_SERVER_URL     @"http://test.comm.weiyi.com/"
#define YBWEB_SERVER_URL            @"http://test.sx.yb1v1.com/"

#elif INNERTEST                   // inner url

#define YBWEB_COMMON_SERVER_URL     @"http://comm.weiyi.com/"
#define YBWEB_SERVER_URL            @"http://sx.weiyi.com/"

#else
#warning MUST define  PUBLICTEST or DISTRIBUTION or INNERTEST.
#endif


// 检测用户是否存在 http://sx.weiyi.com/register/check_user
#define CHECK_USER_URL             (YBWEB_SERVER_URL @"register/check_user")

/** ---------- register and login ---------- **/
// 发送验证码 http://sx.weiyi.com/register/send_verify_code
#define VERIFY_PHONE_URL           (YBWEB_SERVER_URL @"register/send_verify_code")

// 注册 http://sx.weiyi.com/register/register
#define REGISTER_ACCOUNT_URL       (YBWEB_SERVER_URL @"register/register")

// http://tls.taomee.com/register/check_verify_code
#define CHECK_VERIFYCODE_URL       (YBWEB_SERVER_URL @"register/check_verify_code")

// 用户登录 http://sx.weiyi.com/login/login
#define LOGIN_URL                   (YBWEB_SERVER_URL @"login/login")

// 用户注销 http://sx.weiyi.com/login/logout
#define LOGOUT_URL                  (YBWEB_SERVER_URL @"login/logout")

// http://tls.taomee.com/login/check_login
#define CHECK_LOGIN_URL             (YBWEB_SERVER_URL @"login/check_login")

// 家长重置密码 http://api.weiyi.com/register/parent_reset_passwd
#define RESET_PASSWORD_URL          (YBWEB_SERVER_URL @"register/parent_reset_passwd")

// 获取系统配置信息 http://sx.weiyi.com/common/get_user_conf
#define GET_NORMAL_CONF_URL         (YBWEB_SERVER_URL @"common/get_user_conf")

// 设置用户的头像 http://sx.weiyi.com/user_info/set_face
#define SET_FACE_URL                (YBWEB_SERVER_URL @"user_info/set_face")

// 设置用户的昵称 http://sx.weiyi.com/user_info/set_nick
#define SET_NICK_URL                (YBWEB_SERVER_URL @"user_info/set_nick")

// http://api.weiyi.com/common/check_version_parent
#define CHECK_VERSION_UPDATE_URL    (YBWEB_COMMON_SERVER_URL @"common/check_version_parent")

/** ---------- check server ---------- **/
#define CHECK_VERSION_URL           (YBWEB_SERVER_URL @"c=common&d=check_version")

// 提交百度推送token http://api.weiyi.com/common/upload_push_token
#define UPLOAD_PUSH_TOKEN_URL       (YBWEB_SERVER_URL @"common/upload_push_token")

// http://tls.taomee.com/lesson_manage/get_room_info
#define GET_ROOM_INFO_URL          (YBWEB_SERVER_URL @"lesson_manage/get_room_info")

// 批量邀请好友 http://sx.weiyi.com/invite/invite_user
#define INVITE_USER_PHONE_URL          (YBWEB_SERVER_URL @"invite/invite_user")

// 获取用户的好友列表 http://sx.weiyi.com/friend/get_user_friend
#define GET_USER_FRIENDS_URL          (YBWEB_SERVER_URL @"friend/get_user_friend")

// 获取用户信息 http://sx.weiyi.com/user_info/get_user_info
#define GET_USER_INFO_URL          (YBWEB_SERVER_URL @"user_info/get_user_info")

// 获取邀请但是未注册好友 http://sx.weiyi.com/invite/get_invite_user
#define GET_INVITE_USER_URL          (YBWEB_SERVER_URL @"invite/get_invite_user")

// 获取七牛文件上传token http://sx.weiyi.com/common/get_upload_token
#define GET_PUBLIC_UPLOAD_TOKEN_URL          (YBWEB_SERVER_URL @"common/get_upload_token")

// 获取未处理邀请信息 http://sx.weiyi.com/invite/get_confirm_list
#define GET_CONFIRM_LIST_URL          (YBWEB_SERVER_URL @"invite/get_confirm_list")

// 确认是否接收邀请 http://sx.weiyi.com/invite/confirm_invite
#define CONFIRM_INVITE_URL          (YBWEB_SERVER_URL @"invite/confirm_invite")

// 通知用户信息 http://sx.weiyi.com/message/notice_user
#define MESSAGE_NOTICE_USER_URL          (YBWEB_SERVER_URL @"message/notice_user")


@protocol HttpClientDelegate <NSObject>

@optional
- (void)onHTTPRequestError:(NSError*)error;
- (void)onUnLoginError:(NSDictionary*)data;

/** ---------- register and login ---------- **/

- (void)onCheckUser:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onVerifyPhoneNumber:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onCheckVerifyCode:(NSDictionary*)data;
- (void)onRegister:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onLogin:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onLogout:(NSDictionary*)data;
- (void)onCheckLogin:(NSDictionary*)data;
- (void)onResetPwd:(NSDictionary*)data userData:(NSDictionary*)userData;

- (void)onGetConfigure:(NSDictionary*)data;

- (void)onGetChildren:(NSDictionary*)data;
- (void)onGetLessonList:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onGetLessonInfo:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onConfirmQuiz:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onConfirmLesson:(NSDictionary*)data userData:(NSDictionary*)userData;

- (void)onGetOrderList:(NSDictionary*)data;
- (void)onGetUnconfirmLessonList:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onGetUnconfirmQuizList:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onSetFace:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onSetNick:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onGetParentInfo:(NSDictionary*)data;
- (void)onGetQuizScore:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onGetCourseVideos:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onGetCourseHomeworks:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onGetCourseQuiz:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onUploadPushToken:(NSDictionary*)data;
- (void)onGetAssitantInfo:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onGetRoomInfo:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onCheckVersion:(NSDictionary*)data;

- (void)onInviteUserWithPhone:(NSDictionary*)data userData:(NSDictionary*)userData;

- (void)onGetFriends:(NSDictionary*)data;
- (void)onGetUserInfo:(NSDictionary*)data;
- (void)onGetInviteUser:(NSDictionary*)data;
- (void)onGetConfirmList:(NSDictionary*)data;
- (void)onAcceptInvite:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onRefuseInvite:(NSDictionary*)data userData:(NSDictionary*)userData;
- (void)onSendMessage:(NSDictionary*)data userData:(NSDictionary*)userData;

@end


@interface HttpClient : NSObject

+ (void)checkUser:(NSString*)phone delegate:(id<HttpClientDelegate>)delegate;

// >>>> phone	bytes	单一变量[1]	手机号
// >>>> verify_code	bytes	单一变量[1]	注册验证码
// >>>> passwd	bytes	单一变量[1]	用户密码（MD5）
// >>>> reg_channel	bytes	单一变量[1]	注册渠道
+ (void)registerWithPhoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode password:(NSString*)password delegate:(id<HttpClientDelegate>)delegate;

/** ---------- register and login ---------- **/
// >>>> phone	bytes	单一变量[1]	手机号
// >>>> type	uint32	单一变量[1]	发送的验证码类型 1 注册 2 修改密码
+ (void)verifyPhoneNumber:(NSString *)phoneNumber type:(NSNumber*)type delegate:(id<HttpClientDelegate>)delegate;
+ (void)checkVerifyCode:(NSString*)phone verifyCode:(NSString*)verifyCode delegate:(id<HttpClientDelegate>)delegate;

+ (void)loginWithAccount:(NSString *)account password:(NSString *)password delegate:(id<HttpClientDelegate>)delegate;
+ (void)logout:(id<HttpClientDelegate>)delegate;
+ (void)checkLogin:(id<HttpClientDelegate>)delegate;
+ (void)resetPwd:(NSString*)phone pwd:(NSString*)passwd verifyCode:(NSString*)verify_code delegate:(id<HttpClientDelegate>)delegate;


/** ---------- get configure ---------- **/
+ (void)getConfigure:(id<HttpClientDelegate>)delegate;

+ (void)setFace:(NSString*)face delegate:(id<HttpClientDelegate>)delegate;
+ (void)setNick:(NSString*)nick delegate:(id<HttpClientDelegate>)delegate;

+ (void)uploadPushToken:(NSString*)token deviceType:(NSNumber*)device_type channelid:(NSString*)channelid delegate:(id<HttpClientDelegate>)delegate;
+ (void)checkVersion:(NSNumber*)device_type version:(NSString*)version app_type:(NSNumber*)app_type delegate:(id<HttpClientDelegate>)delegate;

+ (void)inviteUserWithPhones:(NSString*)phones delegate:(id<HttpClientDelegate>)delegate;
+ (void)getFriends:(id<HttpClientDelegate>)delegate;
+ (void)getUserInfo:(id<HttpClientDelegate>)delegate;
+ (void)getInviteUser:(id<HttpClientDelegate>)delegate;
+ (void)getConfirmList:(id<HttpClientDelegate>)delegate;
+ (void)acceptInviteWithUser:(NSString*)userId delegate:(id<HttpClientDelegate>)delegate;
+ (void)refuseInviteWithUser:(NSString*)userId delegate:(id<HttpClientDelegate>)delegate;
+ (void)sendMessage:(NSString*)message to:(NSString*)userIds audio:(NSString*)audioFile time:(NSNumber*)timestamp delegate:(id<HttpClientDelegate>)delegate;

@end

