//
//  RegisterViewController.h
//  iChat
//
//  Created by michael on 21/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RegisterSuccessBlock)(NSString *phoneNumber);

@interface RegisterViewController : UIViewController

@property(copy) RegisterSuccessBlock successBlock;

@property(copy) dispatch_block_t backBlock;

@property(nonatomic, strong) NSString *phoneNumber;
@property(nonatomic, strong) NSString* verifyCode;
@property(nonatomic, strong) NSNumber* messageNumber;

@end
