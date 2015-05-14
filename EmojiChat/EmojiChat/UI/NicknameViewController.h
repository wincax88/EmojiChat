//
//  NicknameViewController.h
//  taozuoye
//
//  Created by michaelwong on 4/4/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^setNickNameSuccessBlock)(NSString *nickName);

@interface NicknameViewController : UIViewController

@property (retain, nonatomic) NSString *nickname;

@property(copy) dispatch_block_t backBlock;

@property(copy) setNickNameSuccessBlock  saveBlock;




@end
