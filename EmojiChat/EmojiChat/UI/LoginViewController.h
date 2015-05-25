//
//  LoginViewController.h
//  iParent
//
//  Created by michael on 13/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController

@property(copy) dispatch_block_t backBlock;
@property(copy) dispatch_block_t successBlock;

@end
