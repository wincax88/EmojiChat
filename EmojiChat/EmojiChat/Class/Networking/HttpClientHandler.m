//
//  HttpClientHandler.m
//  TaoLaoShiHttp
//
//  Created by michaelwong on 6/18/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "HttpClientHandler.h"
#import "HttpClient.h"
#import "CommonDefine.h"
#import "YBUtility.h"
#import "ApplicationManager.h"
#import "MD5.h"
#import "AccountObject.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface HttpClientHandler () <HttpClientDelegate> {
}

@end

@implementation HttpClientHandler
- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


#pragma mark - Public Method

/** ---------- register and login ---------- **/
- (void)verifyPhoneNumber:(NSString *)phoneNumber
{
    // 发送的验证码类型 1 注册 2 修改密码
    [HttpClient verifyPhoneNumber:phoneNumber type:[NSNumber numberWithInt:2] delegate:self];
}

- (void)checkVerifyCode:(NSString*)phone verifyCode:(NSString*)verifyCode {
    
    [HttpClient checkVerifyCode:phone verifyCode:verifyCode delegate:self];
}

- (void)loginWithAccount:(NSString *)account password:(NSString *)password
{
    [HttpClient loginWithAccount:account password:password delegate:self];
}
- (void)logout
{
    [HttpClient logout:self];
}
- (void)checkLogin
{
    [HttpClient checkLogin:self];
}

- (void)resetPwd:(NSString*)phone pwd:(NSString*)passwd verifyCode:(NSString*)verify_code
{
    [HttpClient resetPwd:phone pwd:passwd verifyCode:verify_code delegate:self];
}


/** ---------- get configure ---------- **/
- (void)getConfigure
{
    [HttpClient getConfigure:self];
}

- (void)setFace:(NSString*)face
{
    [HttpClient setFace:face delegate:self];
}

- (void)setNick:(NSString*)nick
{
    [HttpClient setNick:nick delegate:self];
    
}

- (void)acceptInviteWithUser:(NSString*)userId
{
    [HttpClient acceptInviteWithUser:userId delegate:self];
}

- (void)refuseInviteWithUser:(NSString*)userId
{
    [HttpClient refuseInviteWithUser:userId delegate:self];
}

- (void)inviteUserWithPhones:(NSString*)phones
{
    [HttpClient inviteUserWithPhones:phones delegate:self];
}

- (void)registerWithPhoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode password:(NSString*)password
{
    [HttpClient registerWithPhoneNumber:phoneNumber verifyCode:verifyCode password:password delegate:self];
}

- (void)uploadPushToken:(NSString*)token channelid:(NSString*)channelid
{
    // device_type	uint32	单一变量[1]	1 ios 2 android
    // token	bytes	单一变量[1]	百度的userId
    // channelid	bytes	单一变量[1]	推送的channel_id
    if (token.length > 0 && channelid.length > 0) {
        [HttpClient uploadPushToken:token deviceType:[NSNumber numberWithInt:1] channelid:channelid delegate:self];
    }
}
- (void)getFriends
{
    [HttpClient getFriends:self];
}

- (void)getUserInfo
{
    [HttpClient getUserInfo:self];
}

- (void)getInviteUser
{
    [HttpClient getInviteUser:self];
}

- (void)getConfirmList
{
    [HttpClient getConfirmList:self];
}

- (void)sendMessage:(NSString*)message to:(NSString*)userIds audio:(NSString*)audioFile time:(NSNumber*)timestamp
{
    [HttpClient sendMessage:message to:userIds audio:audioFile time:timestamp delegate:self];
}

#pragma mark - Private Method

- (NSArray*)parseFriendList:(NSArray*)items
{
    //>>>>>>>> userid	uint32	单一变量[1]	用户的id
    //>>>>>>>> nick	bytes	单一变量[1]	昵称
    //>>>>>>>> face	bytes	单一变量[1]	头像地址（可以直接使用）
    //>>>>>>>> remark	bytes	单一变量[1]	备注信息
    //>>>>>>>> group_name	bytes	单一变量[1]	分组组名
    // phone
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSDictionary *item in items) {
        ChatBuddy *user = [[ChatBuddy alloc] init];
        user.userId = [NSString stringWithFormat:@"%@", [item objectForKey:@"userid"]];
        user.nickName = [item objectForKey:@"nick"];
        user.avatarUrl = [item objectForKey:@"face"];
        user.phoneNumber = [item objectForKey:@"phone"];
        [result addObject:user];
    }
    return result;
}

- (AccountObject*)parseUser:(NSDictionary*)item
{
    AccountObject *user = [[AccountObject alloc] init];
    for (NSString *key in [item allKeys]) {
        if ([user respondsToSelector:NSSelectorFromString(key)]) {
            [user setValue:[item valueForKey:key] forKey:key];
        }
        else {
            NSParameterAssert(false);
        }
    }
    return user;
}

- (NSArray*)parseConfirmList:(NSArray*)items
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSDictionary *item in items) {
        AccountObject *user = [[AccountObject alloc] init];
        for (NSString *key in [item allKeys]) {
            if ([user respondsToSelector:NSSelectorFromString(key)]) {
                [user setValue:[item valueForKey:key] forKey:key];
            }
            else {
                NSParameterAssert(false);
            }
        }
        user.relationShip = kContactIsInvitee;
        [result addObject:user];
    }
    return result;
}

#pragma mark - HttpClientDelegate

- (void)onHTTPRequestError:(NSError*)error
{
    [self notifyDelegates:[NSNumber numberWithInteger:error.code] selector:@selector(didHTTPRequestError:message:) object:error.localizedDescription];
}

- (void)onUnLoginError:(NSDictionary*)data
{
    [self notifyDelegates:data selector:@selector(didUnLoginError:)];
}

/** ---------- register and login ---------- **/

- (void)onCheckUser:(NSDictionary*)data userData:(NSDictionary*)userData
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            // save account and password to keychain
            NSString *phoneNumber = [userData objectForKey:@"phone"];
            
            [self notifyDelegates:phoneNumber selector:@selector(didCheckUserSuccess:)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didCheckUserFailed:message:) object:info];
        }
    }
}

- (void)onVerifyPhoneNumber:(NSDictionary*)data userData:(NSDictionary*)userData
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            NSString *code = [data objectForKey:@"code"];
            NSNumber *msg_num = [data objectForKey:@"msg_num"];
            // save account and password to keychain
            NSString *phoneNumber = [userData objectForKey:@"phone"];
            // userinfo
            NSDictionary *userData2 = @{@"phone":phoneNumber,
                                       @"code":code,
                                       @"msg_num":msg_num};
            
            [self notifyDelegates:userData2 selector:@selector(didVerifyPhoneNumberSuccess:)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didVerifyPhoneNumberFailed:message:) object:info];
        }
    }
}

- (void)onCheckVerifyCode:(NSDictionary*)data
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            [self notifyDelegates:nil selector:@selector(didCheckVerifyCodeSuccess)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didCheckVerifyCodeFailed:message:) object:info];
        }
    }
}

- (void)onRegister:(NSDictionary*)data userData:(NSDictionary*)userData
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            // save account and password to keychain
            NSString *account = [data objectForKey:@"userid"];
            NSNumber *userid = [NSNumber numberWithInt:account.intValue];
            NSString *phoneNumber = [userData objectForKey:@"account"];
            NSString *password = [data objectForKey:@"passwd"];
            [YBUtility savePassword:password account:phoneNumber];
            [self notifyDelegates:ret selector:@selector(didRegisterSuccess:account:) object:userid];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didRegisterFailed:message:) object:info];
        }
    }
}

- (void)onLogin:(NSDictionary*)data userData:(NSDictionary*)userData
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            // userinfo
            NSDictionary *user_info = [data objectForKey:@"user_info"];
            [ApplicationManager sharedManager].account = [self parseUser:user_info];
            NSString *account = [userData objectForKey:@"account"];
            NSString *password = [userData objectForKey:@"password"];
            NSString *md5Password = [password length] >= 32 ? password : [MD5 md5WithoutKey:password];
            
            [YBUtility savePassword:md5Password account:account];
            [ApplicationManager sharedManager].isLogin = YES;
            [[ApplicationManager sharedManager].localSettingData setLastLoginAccount:account];
            [ApplicationManager sharedManager].account.password = md5Password;
            [[ApplicationManager sharedManager].localSettingData setAutoLoginFlag:YES];
            [self notifyDelegates:nil selector:@selector(didLoginSuccess:)];
        }
        else {
            [ApplicationManager sharedManager].account.userid = nil;
            [ApplicationManager sharedManager].isLogin = NO;
            [[ApplicationManager sharedManager].localSettingData setAutoLoginFlag:NO];
            [self notifyDelegates:ret selector:@selector(didLoginFailed:message:) object:info];
        }
    }
}

- (void)onLogout:(NSDictionary*)data
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            [ApplicationManager sharedManager].account.userid = nil;
            [ApplicationManager sharedManager].isLogin = NO;
            [[ApplicationManager sharedManager].localSettingData setAutoLoginFlag:NO];
            [self notifyDelegates:nil selector:@selector(didLogoutSuccess)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didLogoutFailed:message:) object:info];
        }
    }
}

- (void)onCheckLogin:(NSDictionary*)data
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            [ApplicationManager sharedManager].isLogin = YES;
            [self notifyDelegates:nil selector:@selector(didCheckLoginSuccess)];
        }
        else {
            [ApplicationManager sharedManager].isLogin = NO;
            [self notifyDelegates:ret selector:@selector(didCheckLoginFailed:message:) object:info];
        }
    }
}

- (void)onResetPwd:(NSDictionary*)data userData:(NSDictionary*)userData
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            [self notifyDelegates:userData selector:@selector(didResetPwdSuccess:)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didResetPwdFailed:message:) object:info];
        }
    }
}

- (void)onGetConfigure:(NSDictionary*)data
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            NSDictionary *user_conf = [data objectForKey:@"user_conf"];
            [ApplicationManager sharedManager].configureObject.download_pub = [user_conf objectForKey:@"download_pub"];
            [ApplicationManager sharedManager].configureObject.chat_xmpp = [user_conf objectForKey:@"chat_xmpp"];
            [ApplicationManager sharedManager].configureObject.update = [NSNumber numberWithBool:YES];
            [[ApplicationManager sharedManager].localSettingData setConfigure:[ApplicationManager sharedManager].configureObject];
            [[ApplicationManager sharedManager].manualUplaodManager setPublicDownloadURL:[ApplicationManager sharedManager].configureObject.download_pub];
            
            [self notifyDelegates:nil selector:@selector(didGetConfigureSuccess)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didGetConfigureFailed:message:) object:info];
        }
    }
}

- (void)onInviteUserWithPhone:(NSDictionary*)data userData:(NSDictionary*)userData
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            NSString *phones = [userData objectForKey:@"invitees"];
            [self notifyDelegates:phones selector:@selector(didInviteUserWithPhoneSuccess:)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didInviteUserWithPhoneFailed:message:) object:info];
        }
    }
}


- (void)onGetFriends:(NSDictionary*)data
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            NSArray *friend_list = [data objectForKey:@"friend_list"];
            NSArray *friendArray = [self parseFriendList:friend_list];
            
//            [[ApplicationManager sharedManager].chatBuddyList removeAllObjects];
//            [[ApplicationManager sharedManager].chatBuddyList addObjectsFromArray:friendArray];
            
            [self notifyDelegates:nil selector:@selector(didGetFriendsSuccess)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didGetFriendsFailed:message:) object:info];
        }
    }
}

- (void)onGetUserInfo:(NSDictionary*)data
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            NSDictionary *user_info = [data objectForKey:@"user_info"];
            [ApplicationManager sharedManager].account = [self parseUser:user_info];
            [self notifyDelegates:nil selector:@selector(didGetUserInfoSuccess)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didGetUserInfoFailed:message:) object:info];
        }
    }
}

- (void)onGetInviteUser:(NSDictionary*)data
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            NSArray *invitee_list = [data objectForKey:@"invitee_list"];
            [[ApplicationManager sharedManager].inviteUserArray removeAllObjects];
            if (invitee_list.count > 0) {
                [[ApplicationManager sharedManager].inviteUserArray addObjectsFromArray:invitee_list];
            }
            [self notifyDelegates:nil selector:@selector(didGetInviteUserSuccess)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didGetInviteUserFailed:message:) object:info];
        }
    }
}

- (void)onUploadPushToken:(NSDictionary*)data
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            [self notifyDelegates:nil selector:@selector(didUploadPushTokenSuccess)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didUploadPushTokenFailed:message:) object:info];
        }
    }
    
}

- (void)onSetFace:(NSDictionary*)data userData:(NSDictionary*)userData
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            [self notifyDelegates:userData selector:@selector(didSetFaceSuccess:)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didSetFaceFailed:message:) object:info];
        }
    }
}

- (void)onSetNick:(NSDictionary*)data userData:(NSDictionary*)userData
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            [self notifyDelegates:userData selector:@selector(didSetNickSuccess:)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didSetNickFailed:message:) object:info];
        }
    }
}

- (void)onGetConfirmList:(NSDictionary*)data
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            NSArray *confirm_list = [data objectForKey:@"confirm_list"];
            NSArray *confirmList = [self parseConfirmList:confirm_list];
            [[ApplicationManager sharedManager].confirmList removeAllObjects];
            if (confirmList.count > 0) {
                [[ApplicationManager sharedManager].confirmList addObjectsFromArray:confirmList];
            }
            [self notifyDelegates:nil selector:@selector(didGetConfirmListSuccess:)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didGetConfirmListFailed:message:) object:info];
        }
    }
}

- (void)onAcceptInvite:(NSDictionary*)data userData:(NSDictionary*)userData
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            NSString *userId = [userData objectForKey:@"inviterid"];
            [self notifyDelegates:userId selector:@selector(didAcceptInviteSuccess:)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didAcceptInviteFailed:message:) object:info];
        }
    }
}

- (void)onRefuseInvite:(NSDictionary*)data userData:(NSDictionary*)userData
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            NSString *userId = [userData objectForKey:@"inviterid"];
            [self notifyDelegates:userId selector:@selector(didRefuseInviteSuccess:)];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didRefuseInviteFailed:message:) object:info];
        }
    }
}

- (void)onSendMessage:(NSDictionary*)data userData:(NSDictionary*)userData
{
    if (data) {
        NSNumber *ret = [data objectForKey:@"ret"];
        NSString *info = [data objectForKey:@"info"];
        if ([ret intValue] == 0) {
            NSString *senders = [userData objectForKey:@"senders"];
            NSString *timestamp = [userData objectForKey:@"timestamp"];
            [self notifyDelegates:senders selector:@selector(didSendMessageSuccess:time:) object:timestamp];
        }
        else {
            [self notifyDelegates:ret selector:@selector(didSendMessageFailed:message:) object:info];
        }
    }
}

@end
