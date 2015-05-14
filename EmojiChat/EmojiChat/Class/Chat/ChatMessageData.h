//
//  ChatMessageData.h
//  XmppWhiteBoard
//
//  Created by michaelwong on 10/8/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessages.h"


@interface ChatMessageData : NSObject

// JSQMessage array
@property (strong, nonatomic) NSMutableArray *messages;

// [@"avatr id", JSQMessagesAvatarImage]
@property (strong, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) NSDictionary *users;

- (void)addPhotoMediaMessage;

- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion;

@end
