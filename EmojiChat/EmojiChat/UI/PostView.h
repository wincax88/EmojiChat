//
//  PostView.h
//  taozuoye
//
//  Created by michael on 14-3-30.
//  Copyright (c) 2014年 taomee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostView;

@protocol PostViewDelegate <NSObject>

- (void)didSendButtonTouched:(PostView*)controller;

@end

@interface PostView : UIView

@property (weak, nonatomic) id<PostViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextView *textView;

- (IBAction)onSendButtonTouched:(id)sender;

@end
