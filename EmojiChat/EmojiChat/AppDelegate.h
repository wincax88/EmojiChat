//
//  AppDelegate.h
//  EmojiChat
//
//  Created by michael on 8/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

#define XMainViewController ([(AppDelegate*)[[UIApplication sharedApplication] delegate] mainViewController])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainViewController *mainViewController;

@end

