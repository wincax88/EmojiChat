//
//  SMSRegisterViewController.m
//  iChat
//
//  Created by michael on 28/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "SMSRegisterViewController.h"
#import "YBUtility.h"
#import "ApplicationManager.h"
#import "SetPwdViewController.h"
#import "MBProgressHUD.h"
#import "VerifyViewController.h"
#import "UIAlertView+Blocks.h"
#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>
#import "SectionsViewController.h"

@interface SMSRegisterViewController ()
<
SectionsViewControllerDelegate,
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray             *identifiers;
    
    NSMutableArray      *_areaArray;

    NSString            *_defaultCode;
    
    NSString            *_defaultCountryName;
    
    CountryAndAreaCode  *_countryAndAreaCode;
}

//@property (strong, nonatomic) IBOutlet UITextField *countryTextField;
//@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
//@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITextField *phoneField;

- (IBAction)onNextTouched:(id)sender;
- (IBAction)onBackTouched:(id)sender;

@end

@implementation SMSRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    identifiers = @[@"Comment", @"Country", @"PhoneNumber", @"NextStep"];
    
    // Do any additional setup after loading the view.
//    self.phoneTextField.text = self.phoneNumber;
    
    _areaArray= [NSMutableArray array];
    
    //设置本地区号
    [self setTheLocalAreaCode];
    //获取支持的地区列表
    [SMS_SDK getZone:^(enum SMS_ResponseState state, NSArray *array)
     {
         if (1==state)
         {
             NSLog(@"sucessfully get the area code");
             //区号数据
             _areaArray=[NSMutableArray arrayWithArray:array];
         }
         else if (0==state)
         {
             NSLog(@"failed to get the area code");
         }
         
     }];

    self.phoneField.text = self.phoneNumber;
}

- (void)viewWillAppear:(BOOL)animated {
    [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
    
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    [[ApplicationManager sharedManager].httpClientHandler unregisterDelegate:self];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action
- (IBAction)onNextTouched:(id)sender {
    /*
//    [self.phoneTextField resignFirstResponder];
    
//    self.phoneNumber = self.phoneTextField.text;
    
    // prevent a strange UI bug
    if ([self.phoneNumber length] <= 0)
    {
        [YBUtility showInfoHUDInView:self.view message:@"请输入手机号"];
//        [self.phoneTextField becomeFirstResponder];
        return;
    }
    
    if ([YBUtility validatePhoneNumber:self.phoneNumber ] == NO)
    {
        [YBUtility showInfoHUDInView:self.view message:@"手机号格式无效"];
//        [self.phoneTextField becomeFirstResponder];
        return;
    }
    // show hud
//    [YBUtility showInfoHUDInView:self.view message:nil];
    // login
//    HttpClientHandler *handler = [ApplicationManager sharedManager].httpClientHandler;
//    [handler verifyPhoneNumber:self.phoneNumber];
     */
    self.phoneNumber = self.phoneField.text;
    [self nextStep];
}

- (IBAction)onBackTouched:(id)sender {
    if (self.backBlock) {
        self.backBlock();
    }
}

#pragma mark - tableview

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [identifiers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [identifiers objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // @"Comment", @"Country", @"PhoneNumber", @"NextStep"
    if ([identifier isEqualToString:@"Country"]) {
        UILabel *countryLabel = (UILabel*)[cell.contentView viewWithTag:1];
        if (_countryAndAreaCode)
        {
            countryLabel.text = _countryAndAreaCode.countryName;
        }
        else
        {
            countryLabel.text = _defaultCountryName;
        }
    }
    else if ([identifier isEqualToString:@"PhoneNumber"]) {
        UITextField *areaCodeField = (UITextField*)[cell.contentView viewWithTag:1];
        if (_countryAndAreaCode) {
            areaCodeField.text = [NSString stringWithFormat:@"+%@", _countryAndAreaCode.areaCode];
        }
        else {
            areaCodeField.text = [NSString stringWithFormat:@"+%@", _defaultCode];
        }
        self.phoneField = (UITextField*)[cell.contentView viewWithTag:2];
        self.phoneField.text = self.phoneNumber;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [identifiers objectAtIndex:indexPath.row];
    if ([identifier isEqualToString:@"Country"]) {
        // popup section view
        SectionsViewController* sectionsViewController = [[SectionsViewController alloc] init];
        sectionsViewController.delegate = self;
        [sectionsViewController setAreaArray:_areaArray];
        [self presentViewController:sectionsViewController animated:YES completion:^{
            ;
        }];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - private
- (void)nextStep
{
    int compareResult = 0;
    for (int i = 0; i < _areaArray.count; i++)
    {
        NSDictionary * areaDict = [_areaArray objectAtIndex:i];
        NSString* zoneCode = [areaDict valueForKey:@"zone"];

        NSString *defaultCode = _defaultCode;
        if ([zoneCode isEqualToString:[defaultCode stringByReplacingOccurrencesOfString:@"+" withString:@""]])
        {
            compareResult = 1;
            NSString *rule = [areaDict valueForKey:@"rule"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", rule];
            BOOL isMatch = [predicate evaluateWithObject:self.phoneNumber];
            if (!isMatch)
            {
                // 手机号码不正确
                [UIAlertView showWithTitle:NSLocalizedString(@"notice", nil) message:NSLocalizedString(@"errorphonenumber", nil) cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    ;
                }];
                return;
            }
            break;
        }
    }
    
    if (!compareResult)
    {
        if (self.phoneNumber.length != 11)
        {
            // 手机号码不正确
            [UIAlertView showWithTitle:NSLocalizedString(@"notice", nil) message:NSLocalizedString(@"errorphonenumber", nil) cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                ;
            }];
            return;
        }
    }
    
    NSString *message = [NSString stringWithFormat:@"%@:+%@ %@",NSLocalizedString(@"willsendthecodeto", nil), _defaultCode, self.phoneNumber];
    [UIAlertView showWithTitle:NSLocalizedString(@"surephonenumber", nil) message:message cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:@[NSLocalizedString(@"sure", nil)] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (1 == buttonIndex)
        {
            // load VerifyViewController
            NSString *areaCode = [_defaultCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
            [SMS_SDK getVerificationCodeBySMSWithPhone:self.phoneNumber
                                                  zone:areaCode
                                                result:^(SMS_SDKError *error)
             {
                 if (!error)
                 {
                     [self loadVerifyCodeViewController];
                 }
                 else
                 {
                     NSString *message = [NSString stringWithFormat:@"状态码：%zi ,错误描述：%@",error.errorCode,error.errorDescription];
                     [UIAlertView showWithTitle:NSLocalizedString(@"codesenderrtitle", nil) message:message cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                         ;
                     }];
                 }
             }];
        }
    }];

}

-(void)setTheLocalAreaCode
{
    NSLocale *locale = [NSLocale currentLocale];
    
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    NSString* countryCode = [locale objectForKey:NSLocaleCountryCode];
    NSString* defaultCode = [dictCodes objectForKey:countryCode];
    
    NSString* defaultCountryName = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
    _defaultCode = defaultCode;
    _defaultCountryName = defaultCountryName;
}

- (void)loadVerifyCodeViewController {
    if ([self.presentedViewController isKindOfClass:[VerifyViewController class]]) {
        return;
    }
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"SMSRegister" bundle:[NSBundle mainBundle]];
    UINavigationController *nv = [storyboard instantiateViewControllerWithIdentifier:@"VerifyViewController"];
    VerifyViewController* controller = [[nv childViewControllers] firstObject];
    NSString *areaCode = _defaultCode;
    areaCode = [areaCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [controller setPhone:self.phoneNumber AndAreaCode:areaCode];
    
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak __typeof(self) weakSelf = self;
    controller.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    controller.successBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:NO];
        if (self.successBlock) {
            self.successBlock(weakSelf.phoneNumber);
        }
    };
}

- (void)loadSetPwdViewController {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"RegisterAndLogin" bundle:[NSBundle mainBundle]];
    UINavigationController *nv = [storyboard instantiateViewControllerWithIdentifier:@"SetPwdViewController"];
    SetPwdViewController* controller = [[nv childViewControllers] firstObject];
    controller.phoneNumber = self.phoneNumber;
    controller.verifyCode = self.verifyCode;
    controller.registerMode = YES;
    
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak __typeof(self) weakSelf = self;
    controller.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    controller.successBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:NO];
        if (self.successBlock) {
            self.successBlock(weakSelf.phoneNumber);
        }
    };
}

#pragma mark - private

- (void)didVerifyPhoneNumberSuccess:(NSDictionary*)userData {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if ([[userData objectForKey:@"phone"] isEqual:self.phoneNumber]) {
        self.verifyCode = [userData objectForKey:@"code"];
        self.messageNumber = [userData objectForKey:@"msg_num"];
    }

    [self loadVerifyCodeViewController];
    
}

- (void)didVerifyPhoneNumberFailed:(NSNumber*)errorCode message:(NSString*)errorMessage {
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

#pragma mark - SecondViewControllerDelegate
- (void)setSecondData:(CountryAndAreaCode *)data
{
    _countryAndAreaCode = data;
    _defaultCode = _countryAndAreaCode.areaCode;
    [self.tableView reloadData];
}

@end
