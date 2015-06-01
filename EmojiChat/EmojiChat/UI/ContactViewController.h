//
//  ContactViewController.h
//  iChat
//
//  Created by michael on 23/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ContactSelectBlock) (NSString *phone);

@interface ContactViewController : UIViewController

@property(assign, readwrite) BOOL singleSelect;
@property(copy) ContactSelectBlock contactSelectBlock;

@end
