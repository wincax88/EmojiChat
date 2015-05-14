//
//  VerifyCodeViewController.h
//  iStudent
//
//  Created by stephen on 11/7/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VerifyCodeSuccessBlock)(NSString *verifyCode);

@interface VerifyCodeViewController : UIViewController

@property(copy) VerifyCodeSuccessBlock successBlock;

@property(copy) dispatch_block_t backBlock;

@property (nonatomic, strong) NSString* phoneNumber;
@property (nonatomic, strong) NSString* verifyCode;
@property (nonatomic, strong) NSNumber* messageNumber;


@end
