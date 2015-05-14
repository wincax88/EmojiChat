//
//  HttpClientHandler.h
//  TaoLaoShiHttp
//
//  Created by michaelwong on 6/18/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpHandlerBase.h"

@protocol HttpClientHandlerDelegate <NSObject>

@optional

- (void)didHTTPRequestError:(NSNumber*)errorCode message:(NSString*)errorMessage;
- (void)didUnLoginError:(NSDictionary*)data;

/** ---------- register and login ---------- **/
- (void)didCheckUserSuccess:(NSString*)phone;
- (void)didCheckUserFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;
- (void)didVerifyPhoneNumberSuccess:(NSDictionary*)userData;
- (void)didVerifyPhoneNumberFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;
- (void)didCheckVerifyCodeSuccess;
- (void)didCheckVerifyCodeFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;
- (void)didRegisterSuccess:(NSNumber*)successCode account:(NSNumber*)userid;
- (void)didRegisterFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;
- (void)didLoginSuccess:(NSNumber*)userid;
- (void)didLoginFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;
- (void)didLogoutSuccess;
- (void)didLogoutFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;
- (void)didCheckLoginSuccess;
- (void)didCheckLoginFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;
- (void)didResetPwdSuccess:(NSDictionary*)userData;
- (void)didResetPwdFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;

/** ------------ get configure ------------ **/
- (void)didGetConfigureSuccess;
- (void)didGetConfigureFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;

- (void)didInviteUserWithPhoneSuccess:(NSString*)phones;
- (void)didInviteUserWithPhoneFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;


- (void)didGetFriendsSuccess;
- (void)didGetFriendsFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;

- (void)didGetUserInfoSuccess;
- (void)didGetUserInfoFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;

- (void)didGetInviteUserSuccess;
- (void)didGetInviteUserFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;

- (void)didUploadPushTokenSuccess;
- (void)didUploadPushTokenFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;

- (void)didSetFaceSuccess:(NSDictionary*)userData;
- (void)didSetFaceFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;

- (void)didSetNickSuccess:(NSDictionary*)userData;
- (void)didSetNickFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;

- (void)didGetConfirmListSuccess:(NSDictionary*)userData;
- (void)didGetConfirmListFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;

- (void)didAcceptInviteSuccess:(NSString*)userId;
- (void)didAcceptInviteFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;

- (void)didRefuseInviteSuccess:(NSString*)userId;
- (void)didRefuseInviteFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;

- (void)didSendMessageSuccess:(NSString*)senders time:(NSNumber*)timestamp;
- (void)didSendMessageFailed:(NSNumber*)errorCode message:(NSString*)errorMessage;

@end

@interface HttpClientHandler : HttpHandlerBase

/** ---------- register and login ---------- **/
- (void)verifyPhoneNumber:(NSString *)phoneNumber;
- (void)checkVerifyCode:(NSString*)phone verifyCode:(NSString*)verifyCode;
- (void)loginWithAccount:(NSString *)account password:(NSString *)password;
- (void)logout;
- (void)checkLogin;
- (void)resetPwd:(NSString*)phone pwd:(NSString*)passwd verifyCode:(NSString*)verify_code;
- (void)getOrderList;
- (void)getUnconfirmLessonList:(NSNumber*)studentid viewType:(NSNumber*)view_type;
- (void)getUnconfirmQuizList:(NSNumber*)studentid viewType:(NSNumber*)view_type;

/** ---------- get configure ---------- **/
- (void)getConfigure;

- (void)setFace:(NSString*)face;
- (void)setNick:(NSString*)nick;

- (void)registerWithPhoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode password:(NSString*)password;
- (void)uploadPushToken:(NSString*)token channelid:(NSString*)channelid;
- (void)inviteUserWithPhones:(NSString*)phones;
- (void)getFriends;
- (void)getUserInfo;
- (void)getInviteUser;
- (void)getConfirmList;
- (void)acceptInviteWithUser:(NSString*)userId;
- (void)refuseInviteWithUser:(NSString*)userId;
- (void)sendMessage:(NSString*)message to:(NSString*)userIds audio:(NSString*)audioFile time:(NSNumber*)timestamp;

@end
