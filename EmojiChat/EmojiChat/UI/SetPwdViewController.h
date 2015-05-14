//
//  SetPwdViewController.h
//  iStudent
//
//  Created by stephen on 11/7/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetPwdViewController : UIViewController

@property(copy) dispatch_block_t backBlock;
@property(copy) dispatch_block_t successBlock;

@property (nonatomic, retain) IBOutlet UITextField* pwdTextField1;
@property (nonatomic, retain) IBOutlet UITextField* pwdTextField2;

@property (nonatomic, strong) NSString* phoneNumber;
@property (nonatomic, strong) NSString* verifyCode;
@property (assign, readwrite) BOOL      registerMode;

- (IBAction)back:(id)sender;
- (IBAction)setPwd:(id)sender;

@end
