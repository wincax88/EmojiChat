//
//  VerifyViewController.m
//  SMS_SDKDemo
//
//  Created by admin on 14-6-4.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import "VerifyViewController.h"

#import "SMS_MBProgressHUD+Add.h"
#import <AddressBook/AddressBook.h>
//#import "YJViewController.h"
#import "YBUtility.h"

#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/SMS_UserInfo.h>
#import <SMS_SDK/SMS_AddressBook.h>

@interface VerifyViewController ()
{
    NSString* _phone;
    NSString* _areaCode;
    int _state;
    NSMutableData* _data;
    NSString* _localVerifyCode;
    
    NSString* _appKey;
    NSString* _appSecret;
    NSString* _duid;
    NSString* _token;
    NSString* _localPhoneNumber;
    
    NSString* _localZoneNumber;
    NSMutableArray* _addressBookTemp;
    NSString* _contactkey;
    SMS_UserInfo* _localUser;
    
    NSTimer* _timer1;
    NSTimer* _timer2;
    NSTimer* _timer3;
    
    UIAlertView* _alert1;
    UIAlertView* _alert2;
    UIAlertView* _alert3;
    
    UIAlertView *_tryVoiceCallAlertView;

}

@property (nonatomic, strong)  IBOutlet UILabel* titleLabel;
@property (nonatomic, strong)  IBOutlet UILabel* telLabel;
@property (nonatomic, strong)  IBOutlet UITextField* verifyCodeField;
@property (nonatomic, strong)  IBOutlet UILabel* timeLabel;
@property (nonatomic, strong)  IBOutlet UIButton* repeatSMSBtn;
@property (nonatomic, strong)  IBOutlet UIButton* submitBtn;
@property (nonatomic, assign)  NSString* isVerify;

@property (nonatomic, strong)  IBOutlet UILabel *voiceCallMsgLabel;
@property (nonatomic, strong)  IBOutlet UIButton *voiceCallButton;

@end

static int count = 0;

//最近新好友信息
static NSMutableArray* _userData2;

@implementation VerifyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.tintColor = [UIColor orangeColor];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    //创建一个导航栏
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil)
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(clickLeftButton)];
    
    //设置导航栏内容
    [navigationItem setTitle:NSLocalizedString(@"verifycode", nil)];
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    [navigationItem setLeftBarButtonItem:leftButton];
    
    _titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"verifylabel", nil)];
    
    _telLabel.text = [NSString stringWithFormat:@"+%@ %@", _areaCode, _phone];
    
    _verifyCodeField.placeholder = NSLocalizedString(@"verifycode", nil);
    _verifyCodeField.keyboardType = UIKeyboardTypePhonePad;
    _verifyCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    _timeLabel.numberOfLines = 0;
    _timeLabel.text = NSLocalizedString(@"timelabel", nil);
    
    [_repeatSMSBtn setTitle:NSLocalizedString(@"repeatsms", nil) forState:UIControlStateNormal];
    [_repeatSMSBtn addTarget:self action:@selector(CannotGetSMS) forControlEvents:UIControlEventTouchUpInside];
    _repeatSMSBtn.hidden = YES;
    
    [_submitBtn setTitle:NSLocalizedString(@"submit", nil) forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    
    _voiceCallMsgLabel.text = NSLocalizedString(@"voiceCallMsgLabel", nil);
    _voiceCallMsgLabel.hidden = YES;
    
    [_voiceCallButton setTitle:NSLocalizedString(@"try voice call", nil) forState:UIControlStateNormal];
    [_voiceCallButton addTarget:self action:@selector(tryVoiceCall) forControlEvents:UIControlEventTouchUpInside];
    _voiceCallButton.hidden = YES;
    
    
    [_timer2 invalidate];
    [_timer1 invalidate];
    
    count = 0;
    
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:60
                                                    target:self
                                                  selector:@selector(showRepeatButton)
                                                  userInfo:nil
                                                   repeats:YES];
    
    NSTimer* timer2 = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(updateTime)
                                                   userInfo:nil
                                                    repeats:YES];
    _timer1 = timer;
    _timer2 = timer2;
    
    [YBUtility showInfoHUDInView:self.view message:NSLocalizedString(@"sendingin", nil)];
    
}

#pragma mark - public
-(void)setPhone:(NSString*)phone AndAreaCode:(NSString*)areaCode
{
    _phone = phone;
    _areaCode = areaCode;
}

#pragma mark - action
- (void)clickLeftButton
{
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                  message:NSLocalizedString(@"codedelaymsg", nil)
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"back", nil)
                                        otherButtonTitles:NSLocalizedString(@"wait", nil), nil];
    _alert2 = alert;
    [alert show];    
}


- (void)submit
{
    //验证号码
    //验证成功后 获取通讯录 上传通讯录
    [self.view endEditing:YES];
    
    if (self.verifyCodeField.text.length < 4)
    {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                      message:NSLocalizedString(@"verifycodeformaterror", nil)
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                            otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        //[[SMS_SDK sharedInstance] commitVerifyCode:self.verifyCodeField.text];
        [SMS_SDK commitVerifyCode:self.verifyCodeField.text result:^(enum SMS_ResponseState state) {
            if (1 == state)
            {
                NSString* str = [NSString stringWithFormat:NSLocalizedString(@"verifycoderightmsg", nil)];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"verifycoderighttitle", nil)
                                                              message:str
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                    otherButtonTitles:nil, nil];
                [alert show];
                _alert3 = alert;
            }
            else if (0 == state)
            {
                NSString* str = [NSString stringWithFormat:NSLocalizedString(@"verifycodeerrormsg", nil)];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"verifycodeerrortitle", nil)
                                                              message:str
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                    otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    }
}


- (void)CannotGetSMS
{
    NSString* str = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"cannotgetsmsmsg", nil) , _phone];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"surephonenumber", nil) message:str delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
    _alert1 = alert;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alert1)
    {
        if (1 == buttonIndex)
        {
            [SMS_SDK getVerifyCodeByPhoneNumber:_phone AndZone:_areaCode result:^(enum SMS_GetVerifyCodeResponseState state)
            {
                if (1 == state)
                {
                    NSLog(@"block 获取验证码成功");
                }
                else if (0 == state)
                {
                    NSLog(@"block 获取验证码失败");
                    NSString* str=[NSString stringWithFormat:NSLocalizedString(@"codesenderrormsg", nil)];
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"codesenderrtitle", nil) message:str delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
                    [alert show];
                }
                else if (SMS_ResponseStateMaxVerifyCode==state)
                {
                    NSString* str=[NSString stringWithFormat:NSLocalizedString(@"maxcodemsg", nil)];
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"maxcode", nil) message:str delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
                    [alert show];
                }
                else if(SMS_ResponseStateGetVerifyCodeTooOften==state)
                {
                    NSString* str=[NSString stringWithFormat:NSLocalizedString(@"codetoooftenmsg", nil)];
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil) message:str delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
                    [alert show];
                }

            }];

        }
        
    }
    
    if (alertView == _alert2) {
        if (0 == buttonIndex)
        {
            [_timer2 invalidate];
            [_timer1 invalidate];
            if (self.backBlock) {
                self.backBlock();
            }
            //[self dismissViewControllerAnimated:YES completion:^{
            //}];
        }
    }
    
    if (alertView == _alert3)
    {
        [_timer2 invalidate];
        [_timer1 invalidate];
        if (self.successBlock) {
            self.successBlock();
        }
        /*
        YJViewController* yj=[[YJViewController alloc] init];
        [self presentViewController:yj animated:YES completion:^{
            //解决等待时间乱跳的问题
            [_timer2 invalidate];
            [_timer1 invalidate];
        }];*/
    }
    
    if (alertView == _tryVoiceCallAlertView)
    {
        if (0 == buttonIndex)
        {
            [SMS_SDK getVerificationCodeByVoiceCallWithPhone:_phone
                                                        zone:_areaCode
                                                      result:^(SMS_SDKError *error)
             {
                 
                 if (error)
                 {
                     UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"codesenderrtitle", nil)
                                                                   message:[NSString stringWithFormat:@"状态码：%zi",error.errorCode]
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                         otherButtonTitles:nil, nil];
                     [alert show];
                 }
             }];
        }
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (void)tryVoiceCall
{
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"verificationByVoiceCallConfirm", nil)
                                                  message:[NSString stringWithFormat:@"%@: +%@ %@",NSLocalizedString(@"willsendthecodeto", nil),_areaCode, _phone]
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                        otherButtonTitles:NSLocalizedString(@"cancel", nil), nil];
    _tryVoiceCallAlertView = alert;
    [alert show];
}


- (void)updateTime
{
    count++;
    if (count>=60)
    {
        [_timer2 invalidate];
        return;
    }
    //NSLog(@"更新时间");
    self.timeLabel.text=[NSString stringWithFormat:@"%@%i%@",NSLocalizedString(@"timelablemsg", nil),60-count,NSLocalizedString(@"second", nil)];
    
    if (count == 30)
    {
        if (_voiceCallMsgLabel.hidden)
        {
            _voiceCallMsgLabel.hidden = NO;
        }
        
        if (_voiceCallButton.hidden)
        {
            _voiceCallButton.hidden = NO;
        }
    }
}

- (void)showRepeatButton{
    self.timeLabel.hidden=YES;
    self.repeatSMSBtn.hidden=NO;
    
    [_timer1 invalidate];
    return;
}

@end
