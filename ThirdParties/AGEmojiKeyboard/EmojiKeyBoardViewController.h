//
//  EmojiKeyBoardViewController.h
//  EmojiKeyboardTest
//
//  Created by michael on 15/5/31.
//  Copyright (c) 2015年 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EmojiSelectedBlock)(NSString *emoji);

@interface EmojiKeyBoardViewController : UIViewController

@property(copy) dispatch_block_t    backTouchBlock;
@property(copy) EmojiSelectedBlock  emojiSelectedBlock;

- (void)showKeyBoard;
- (void)hideKeyBoard;

@end
