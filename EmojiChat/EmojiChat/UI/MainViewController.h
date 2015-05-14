//
//  MainViewController.h
//  handChat
//
//  Created by michael on 8/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MainViewController : BaseViewController

- (BOOL)autoLogin;
- (void)loadLoginViewController;
- (void)showQuickAnswerView;

@end
