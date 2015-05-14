//
//  QuickAnswerViewController.h
//  iChat
//
//  Created by michael on 22/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickAnswerViewController : UIViewController

@property (copy) dispatch_block_t closeBlock;

- (void)refresh;

@end
