
//
//  HttpClient.m
//  iTao
//
//  Created by michaelwong on 11/14/13.
//  Copyright (c) 2013 taomee. All rights reserved.
//

#import "HttpClient.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "MD5.h"
#import "OpenUDID.h"


@implementation HttpClient

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
    
}

- (void) dealloc {
}

+ (void)cancelAllRequests
{
    [[AFHTTPRequestOperationManager manager].operationQueue cancelAllOperations];
}


+ (void)requestDataWithParam:(NSDictionary*)param url:(NSString*)urlString delegate:(id<HttpClientDelegate>)delegate selector:(SEL)aSelector
{
    [HttpClient requestDataWithParam:param url:urlString delegate:delegate selector:aSelector userData:nil fileData:nil];
}

+ (void)requestDataWithParam:(NSDictionary*)param url:(NSString*)urlString delegate:(id<HttpClientDelegate>)delegate selector:(SEL)aSelector userData:(NSDictionary*)userData fileData:(NSDictionary*)param2
{
    // check networking status
    /*
     if (([AppManager sharedManager].reachabilityManager.networkReachabilityStatus != AFNetworkReachabilityStatusUnknown) &&
     ![[AppManager sharedManager].reachabilityManager isReachable]) {
     // post notification
     [[NSNotificationCenter defaultCenter] postNotificationName:TM_NOTIFICATION_NETWORKING_ERROR object:nil];
     }*/
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:15.0f];
    
    if (!manager.reachabilityManager.reachable && manager.reachabilityManager.networkReachabilityStatus != AFNetworkReachabilityStatusUnknown)
    {
        [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    }
    else {
        [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    }
    
    [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (param) {
            for (NSString *key in param.allKeys) {
#ifdef DEBUG
                NSParameterAssert([[param objectForKey:key] isKindOfClass:[NSData class]]);
#endif
                [formData appendPartWithFormData:[param objectForKey:key] name:key];
            }
        }
        if (param2) {
            for (NSString *key in param2.allKeys) {
                [formData appendPartWithFileData:[param2 objectForKey:key] name:key fileName:@"Picture.jpg" mimeType:@"image/jpeg"];
            }
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // do default postprocess
        if (delegate) {
            NSError *error = nil;
            id jsonObject = nil;
            if (responseObject)
            {
                jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:kNilOptions
                                                               error:&error];
            }
            else {
                NSParameterAssert(false);
            }
            
            if (jsonObject != nil && error == nil)
            {
                // check unlogin error
                NSNumber *ret = [jsonObject objectForKey:@"ret"];
                if (ret.intValue == 6003) {
                    if (aSelector && [delegate respondsToSelector:@selector(onUnLoginError:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            [delegate performSelector:@selector(onUnLoginError:) withObject:jsonObject];
#pragma clang diagnostic pop
                        });
                        return;
                    }
                }
                if (aSelector && [delegate respondsToSelector:aSelector]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (userData) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            [delegate performSelector:aSelector withObject:jsonObject withObject:userData];
#pragma clang diagnostic pop
                        }
                        else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            [delegate performSelector:aSelector withObject:jsonObject];
#pragma clang diagnostic pop
                        }
                    });
                }
                else {
                    NSParameterAssert(false);
                }
            }
            else {
                if (delegate && [delegate respondsToSelector:@selector(onHTTPRequestError:)]) {
                    [delegate performSelector:@selector(onHTTPRequestError:) withObject:error];
                }
                else {
                    NSParameterAssert(false);
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
        NSLog(@"Error: %@", error);
#endif
        if (delegate && [delegate respondsToSelector:@selector(onHTTPRequestError:)]) {
            [delegate performSelector:@selector(onHTTPRequestError:) withObject:error];
        }
        
    }];
}

#pragma mark - register and login
+ (void)checkUser:(NSString*)phone delegate:(id<HttpClientDelegate>)delegate
{
    NSDictionary *param = @{@"phone": [phone dataUsingEncoding:NSUTF8StringEncoding]};
    NSDictionary *userData = @{@"phone": phone};
    [HttpClient requestDataWithParam:param url:CHECK_USER_URL delegate:delegate selector:@selector(onCheckUser:userData:) userData:userData fileData:nil];
}

+ (void)registerWithPhoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode password:(NSString*)password delegate:(id<HttpClientDelegate>)delegate
{
    if (phoneNumber.length <= 0 || verifyCode.length <= 0 || password.length <= 0) {
        NSParameterAssert(false);
        return;
    }
    // >>>> phone	bytes	 单一变量[1]	手机号
    // >>>> verify_code	bytes	 单一变量[1]	手机验证码
    // >>>> passwd	bytes	 单一变量[1]	用户密码
    NSString *deviceToken = [OpenUDID value];
    NSString *md5DeviceToken = [MD5 md5DeviceToken:deviceToken];
    NSString *md5Password = nil;
    if (password == nil || [password isEqualToString:@""]) {
        md5Password = @"";
    }else {
        md5Password = [password length] >= 32 ? password : [MD5 md5WithoutKey:password];
    }
    NSString *channel = @"AppStore";
#ifdef ENTERPRISE
    channel = @"OfficialWebsite";
#endif
    NSDictionary *param = @{@"phone": [phoneNumber dataUsingEncoding:NSUTF8StringEncoding],
                            @"verify_code": [verifyCode dataUsingEncoding:NSUTF8StringEncoding],
                            @"passwd": [md5Password dataUsingEncoding:NSUTF8StringEncoding],
                            @"device": [[UIDevice currentDevice].model dataUsingEncoding:NSUTF8StringEncoding],
                            @"device_token": [deviceToken dataUsingEncoding:NSUTF8StringEncoding],
                            @"sign": [md5DeviceToken dataUsingEncoding:NSUTF8StringEncoding],
                            @"reg_channel": [channel dataUsingEncoding:NSUTF8StringEncoding]
                            };
    
    NSDictionary *userData = @{@"account": phoneNumber,
                               @"password": md5Password};
    [HttpClient requestDataWithParam:param url:REGISTER_ACCOUNT_URL delegate:delegate selector:@selector(onRegister:userData:) userData:userData fileData:nil];
}

+ (void)verifyPhoneNumber:(NSString *)phoneNumber type:(NSNumber*)type delegate:(id<HttpClientDelegate>)delegate
{
    // >>>> phone	bytes	 单一变量[1]	手机号
    NSDictionary *param = @{@"phone": [phoneNumber dataUsingEncoding:NSUTF8StringEncoding]};
    NSDictionary *userData = @{@"phone": phoneNumber};
    [HttpClient requestDataWithParam:param url:VERIFY_PHONE_URL delegate:delegate selector:@selector(onVerifyPhoneNumber:userData:) userData:userData fileData:nil];
}

+ (void)checkVerifyCode:(NSString*)phone verifyCode:(NSString*)verifyCode delegate:(id<HttpClientDelegate>)delegate
{
    NSDictionary *param = @{@"phone": [phone dataUsingEncoding:NSUTF8StringEncoding],
                            @"verify_code": [verifyCode dataUsingEncoding:NSUTF8StringEncoding]};
    NSDictionary *userData = @{@"phone": [phone dataUsingEncoding:NSUTF8StringEncoding],
                               @"verify_code": [verifyCode dataUsingEncoding:NSUTF8StringEncoding]};
    [HttpClient requestDataWithParam:param url:CHECK_VERIFYCODE_URL delegate:delegate selector:@selector(onCheckVerifyCode:) userData:userData fileData:nil];
}


+ (void)loginWithAccount:(NSString *)account
                password:(NSString *)password
                delegate:(id<HttpClientDelegate>)delegate
{
    if (account.length <= 0 || password.length <= 0) {
        NSParameterAssert(false);
        return;
    }
    // >>>> phone	bytes	 单一变量[1]	手机号
    // >>>> passwd	bytes	 单一变量[1]	用户密码
    NSParameterAssert([account length] > 0);
    NSParameterAssert([password length] > 0);
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *md5Password = [password length] >= 32 ? password : [MD5 md5WithoutKey:password];//md5DeviceToken
    NSDictionary *param = @{@"phone": [account dataUsingEncoding:NSUTF8StringEncoding],
                            @"passwd": [md5Password dataUsingEncoding:NSUTF8StringEncoding],
                            @"version": [currentVersion dataUsingEncoding:NSUTF8StringEncoding]};
    NSDictionary *userData = @{@"account": account,
                               @"password": md5Password};
    [HttpClient requestDataWithParam:param url:LOGIN_URL delegate:delegate selector:@selector(onLogin:userData:) userData:userData fileData:nil];
}

+ (void)logout:(id<HttpClientDelegate>)delegate
{
    [HttpClient requestDataWithParam:nil url:LOGOUT_URL delegate:delegate selector:@selector(onLogout:)];
}

+ (void)checkLogin:(id<HttpClientDelegate>)delegate
{
    [HttpClient requestDataWithParam:nil url:CHECK_LOGIN_URL delegate:delegate selector:@selector(onCheckLogin:)];
}

+ (void)resetPwd:(NSString*)phone pwd:(NSString*)passwd verifyCode:(NSString*)verify_code delegate:(id<HttpClientDelegate>)delegate
{
    if (phone.length <= 0 || passwd.length <= 0 || verify_code.length <= 0) {
        NSParameterAssert(false);
        return;
    }
    NSString *md5Password = [passwd length] >= 32 ? passwd : [MD5 md5WithoutKey:passwd];
    NSDictionary* param = @{@"phone": [phone dataUsingEncoding:NSUTF8StringEncoding],
                            @"passwd": [md5Password dataUsingEncoding:NSUTF8StringEncoding],
                            @"verify_code": [verify_code dataUsingEncoding:NSUTF8StringEncoding]};
    NSDictionary* userData = @{@"phone": phone,
                               @"passwd": md5Password};
    [HttpClient requestDataWithParam:param url:RESET_PASSWORD_URL delegate:delegate selector:@selector(onResetPwd:userData:) userData:userData fileData:nil];
}


/** ---------- get configure ---------- **/
+ (void)getConfigure:(id<HttpClientDelegate>)delegate
{
    [HttpClient requestDataWithParam:nil url:GET_NORMAL_CONF_URL delegate:delegate selector:@selector(onGetConfigure:)];
}

+ (void)setFace:(NSString*)face delegate:(id<HttpClientDelegate>)delegate
{
    if (face.length <= 0) {
        NSParameterAssert(false);
        return;
    }
    NSDictionary* param = @{@"face": [face dataUsingEncoding:NSUTF8StringEncoding]};
    NSDictionary* userData = @{@"face": face};
    [HttpClient requestDataWithParam:param url:SET_FACE_URL delegate:delegate selector:@selector(onSetFace:userData:) userData:userData fileData:nil];
}

+ (void)setNick:(NSString*)nick delegate:(id<HttpClientDelegate>)delegate
{
    if (nick.length <= 0) {
        NSParameterAssert(false);
        return;
    }
    NSDictionary* param = @{@"nick": [nick dataUsingEncoding:NSUTF8StringEncoding]};
    NSDictionary* userData = @{@"nick": nick};
    [HttpClient requestDataWithParam:param url:SET_NICK_URL delegate:delegate selector:@selector(onSetNick:userData:) userData:userData fileData:nil];
}


// device_type	uint32	单一变量[1]	1 ios 2 android
// token	bytes	单一变量[1]	百度的userId
// channelid	bytes	单一变量[1]	推送的channel_id
+ (void)uploadPushToken:(NSString*)token deviceType:(NSNumber*)device_type channelid:(NSString*)channelid delegate:(id<HttpClientDelegate>)delegate
{
    NSDictionary* param = @{@"device_type": [device_type.stringValue dataUsingEncoding:NSUTF8StringEncoding],
                            @"token": [token dataUsingEncoding:NSUTF8StringEncoding],
                            @"channelid": [channelid dataUsingEncoding:NSUTF8StringEncoding]};

    [HttpClient requestDataWithParam:param url:UPLOAD_PUSH_TOKEN_URL delegate:delegate selector:@selector(onUploadPushToken:)];
}


+ (void)checkVersion:(NSNumber*)device_type version:(NSString*)version app_type:(NSNumber*)app_type delegate:(id<HttpClientDelegate>)delegate
{
    NSDictionary* param = @{@"device_type": [device_type.stringValue dataUsingEncoding:NSUTF8StringEncoding],
                            @"version": [version dataUsingEncoding:NSUTF8StringEncoding],
                            @"app_type": [app_type.stringValue dataUsingEncoding:NSUTF8StringEncoding]};
    
    [HttpClient requestDataWithParam:param url:CHECK_VERSION_UPDATE_URL delegate:delegate selector:@selector(onCheckVersion:)];
}

+ (void)inviteUserWithPhones:(NSString*)phones delegate:(id<HttpClientDelegate>)delegate
{
    NSDictionary* param = @{@"invitees": [phones dataUsingEncoding:NSUTF8StringEncoding]};
    NSDictionary* userData = @{@"invitees": phones};
    
    [HttpClient requestDataWithParam:param url:INVITE_USER_PHONE_URL delegate:delegate selector:@selector(onInviteUserWithPhone:userData:) userData:userData fileData:nil];
}

+ (void)acceptInviteWithUser:(NSString*)userId delegate:(id<HttpClientDelegate>)delegate
{
    // 1 同意 2 拒绝
    NSDictionary* param = @{@"confirm_type": [[NSString stringWithFormat:@"%d", 1] dataUsingEncoding:NSUTF8StringEncoding],
                            @"inviterid": [userId dataUsingEncoding:NSUTF8StringEncoding]};
    NSDictionary* userData = @{@"inviterid": userId};
    
    [HttpClient requestDataWithParam:param url:CONFIRM_INVITE_URL delegate:delegate selector:@selector(onAcceptInvite:userData:) userData:userData fileData:nil];
}

+ (void)refuseInviteWithUser:(NSString*)userId delegate:(id<HttpClientDelegate>)delegate
{
    // 1 同意 2 拒绝
    NSDictionary* param = @{@"confirm_type": [[NSString stringWithFormat:@"%d", 2] dataUsingEncoding:NSUTF8StringEncoding],
                            @"inviterid": [userId dataUsingEncoding:NSUTF8StringEncoding]};
    NSDictionary* userData = @{@"inviterid": userId};
    
    [HttpClient requestDataWithParam:param url:CONFIRM_INVITE_URL delegate:delegate selector:@selector(onRefuseInvite:userData:) userData:userData fileData:nil];
}

+ (void)getFriends:(id<HttpClientDelegate>)delegate
{
    [HttpClient requestDataWithParam:nil url:GET_USER_FRIENDS_URL delegate:delegate selector:@selector(onGetFriends:)];
}

+ (void)getUserInfo:(id<HttpClientDelegate>)delegate
{
    [HttpClient requestDataWithParam:nil url:GET_USER_INFO_URL delegate:delegate selector:@selector(onGetUserInfo:)];
}

+ (void)getInviteUser:(id<HttpClientDelegate>)delegate
{
    [HttpClient requestDataWithParam:nil url:GET_INVITE_USER_URL delegate:delegate selector:@selector(onGetInviteUser:)];
}

+ (void)getConfirmList:(id<HttpClientDelegate>)delegate
{
    [HttpClient requestDataWithParam:nil url:GET_CONFIRM_LIST_URL delegate:delegate selector:@selector(onGetConfirmList:)];
}

+ (void)sendMessage:(NSString*)message to:(NSString*)userIds audio:(NSString*)audioFile time:(NSNumber*)timestamp delegate:(id<HttpClientDelegate>)delegate
{
    //>>>> userids	bytes	单一变量[1]	用户id构成的字符串（以英文逗号，分割）
    //>>>> message	bytes	单一变量[1]	信息内容
    //>>>> audio	bytes	单一变量[1]	audio文件名
    NSDictionary* param = @{@"userids": [userIds dataUsingEncoding:NSUTF8StringEncoding],
                            @"message": [message dataUsingEncoding:NSUTF8StringEncoding],
                            @"audio": [audioFile dataUsingEncoding:NSUTF8StringEncoding]
                            };
    NSDictionary* userData = @{@"senders": userIds,
                               @"timestamp": timestamp
                               };
    [HttpClient requestDataWithParam:param url:MESSAGE_NOTICE_USER_URL delegate:delegate selector:@selector(onSendMessage:userData:) userData:userData fileData:nil];
}

@end
