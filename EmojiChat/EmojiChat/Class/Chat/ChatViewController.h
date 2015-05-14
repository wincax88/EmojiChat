//
//  ChatViewController.h
//  XmppWhiteBoard
//
//  Created by michaelwong on 9/23/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "JSQMessagesViewController.h"

@interface ChatViewController : JSQMessagesViewController

@property (copy) dispatch_block_t           completion;

@property(assign, readwrite) BOOL           removeAvatars;
@property(assign, readwrite) BOOL           canNotSent;

@property (nonatomic, retain) NSString      *buddyId;
@property (nonatomic, retain) NSString      *placeholder;

- (void)sendTextMessage:(NSString*)text;

@end
