//
//  SetPasswordViewController.h
//  iChat
//
//  Created by michael on 6/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ResetPasswordBlock)(NSString *phoneNumber);

@interface SetPasswordViewController : UIViewController

@property(copy) dispatch_block_t backBlock;
@property(copy) dispatch_block_t successBlock;
@property(copy) ResetPasswordBlock resetPasswordBlock;

@property (nonatomic, retain) IBOutlet UITextField* nickTextField;
@property (nonatomic, retain) IBOutlet UITextField* pwdTextField1;
@property (nonatomic, retain) IBOutlet UITextField* pwdTextField2;

@property (nonatomic, strong) NSString* phoneNumber;
@property (assign, readwrite) BOOL      registerMode;

@end
