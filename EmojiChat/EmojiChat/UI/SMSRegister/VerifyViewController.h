//
//  VerifyViewController.h
//  SMS_SDKDemo
//
//  Created by admin on 14-6-4.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SMS_SDK/SMS_UserInfo.h>

@interface VerifyViewController : UIViewController

@property(copy) dispatch_block_t backBlock;

@property(copy) dispatch_block_t successBlock;

- (void)setPhone:(NSString*)phone AndAreaCode:(NSString*)areaCode;

//-(void)submit;
//-(void)CannotGetSMS;

@end
