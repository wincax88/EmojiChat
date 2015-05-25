//
//  LoginViewControllerEx.h
//  iChat
//
//  Created by michael on 5/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LoginSuccessBlock)(NSString *account, NSString *password);

@interface LoginViewControllerEx : UIViewController

@property(copy) dispatch_block_t backBlock;
@property(copy) LoginSuccessBlock successBlock;

@end
