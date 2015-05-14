//
//  ForgotPasswordViewController.h
//  iParent
//
//  Created by michael on 13/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ResetPasswordSuccessBlock)(NSString *phoneNumber);

@interface ForgotPasswordViewController : UIViewController

@property(copy) ResetPasswordSuccessBlock successBlock;

@property(copy) dispatch_block_t backBlock;

@property(nonatomic, strong) NSString *phoneNumber;
@property(nonatomic, strong) NSString* verifyCode;
@property(nonatomic, strong) NSNumber* messageNumber;

@end
