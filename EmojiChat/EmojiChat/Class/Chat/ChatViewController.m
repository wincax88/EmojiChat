//
//  ChatViewController.m
//  XmppWhiteBoard
//
//  Created by michaelwong on 9/23/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "ChatViewController.h"
#import "JSQMessages.h"
//#import "XmppManager.h"
#import "ChatMessageData.h"
#import "CommonDefine.h"
#import "ApplicationManager.h"
#import "ConfigureObject.h"
#import "KxMenu.h"

@interface ChatViewController ()
<
UIActionSheetDelegate,
XmppManager4ChatDelegate
>

//@property (nonatomic, retain) XmppManager *xmppManager;

//@property (strong, nonatomic) NSMutableArray *messages;
//@property (strong, nonatomic) NSMutableDictionary *avatars;


@property (strong, nonatomic) ChatMessageData *chatMessageData;

- (IBAction)onDoneTouched:(id)sender;
- (IBAction)onMoreTouched:(UIControl *)sender;

@end

@implementation ChatViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _removeAvatars = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    _chatMessageData = [[ChatMessageData alloc] init];

    XmppManager4Chat *_xmppManager = [ApplicationManager sharedManager].xmppManager4Chat;
    
    NSParameterAssert([self.buddyId length] > 0);
    
    if (![self.buddyId containsString:@"@"]) {
        self.buddyId = [NSString stringWithFormat:@"%@@%@", self.buddyId, [ApplicationManager sharedManager].configureObject.chat_xmpp];
    }
    _xmppManager.partnerJID = self.buddyId;
    
    [_xmppManager setReadChatMessageFromStorage:self.buddyId];

    
    [_chatMessageData.messages  addObjectsFromArray:[_xmppManager fetchChatHistoryFromCoreData:self.buddyId]];
    
    // remove avatar
    if (self.removeAvatars) {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    }
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    self.senderId = _xmppManager.myJID;
    
    self.inputToolbar.contentView.textView.placeHolder = self.placeholder;

    if (self.canNotSent) {
        self.inputToolbar.hidden = YES;
        self.inputToolbar.frame = CGRectZero;
        //        [self.inputToolbar removeFromSuperview];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    
    
    [[ApplicationManager sharedManager].xmppManager4Chat registerDelegate:self];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[ApplicationManager sharedManager].xmppManager4Chat unregisterDelegateForce:self];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _chatMessageData = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQTextMessage *message = [[JSQTextMessage alloc] initWithSenderId:senderId
                                                     senderDisplayName:senderDisplayName
                                                                  date:date
                                                                  text:text];
    
    [self.chatMessageData.messages addObject:message];
    [self finishSendingMessage];
    
    [self sendTextMessage:text];
}

#pragma mark - public
- (void)sendTextMessage:(NSString*)text
{
    [[ApplicationManager sharedManager].xmppManager4Chat sendTextMessage:text];
}


- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send photo", @"Send location", nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self.chatMessageData addPhotoMediaMessage];
            break;
            
        case 1:
        {
            __weak UICollectionView *weakView = self.collectionView;
            
            [self.chatMessageData addLocationMediaMessageCompletion:^{
                [weakView reloadData];
            }];
        }
            break;
    }
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
}



#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.chatMessageData.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.chatMessageData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.chatMessageData.outgoingBubbleImageData;
    }
    
    return self.chatMessageData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.chatMessageData.messages objectAtIndex:indexPath.item];
    
    return [self.chatMessageData.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.chatMessageData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.chatMessageData.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatMessageData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.chatMessageData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.chatMessageData.messages objectAtIndex:indexPath.item];
    
    if ([msg isKindOfClass:[JSQTextMessage class]]) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.chatMessageData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatMessageData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
#ifdef DEBUG
    NSLog(@"Load earlier messages!");
#endif
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
#ifdef DEBUG
    NSLog(@"Tapped avatar!");
#endif
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{

#ifdef DEBUG
    NSLog(@"Tapped message bubble!");
#endif
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
#ifdef DEBUG
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
#endif
}

- (JSQMessage *)dictToJSQMessage:(NSDictionary *)dict
{
    JSQMessage *newMessage;
    //BOOL isOutgoing     = [dict[@"isOutgoing"] boolValue];
    NSDate *msgDate     = dict[@"timestamp"];
    NSString *body      = dict[@"body"];
    NSString *from      = dict[@"chatwith"];
    NSString *displayName      = @"";
    //NSData *avatarData  = dict[@"chatWithAvatar"];

    if (body) {
        newMessage = [[JSQTextMessage alloc] initWithSenderId:from
                                            senderDisplayName:displayName
                                                         date:msgDate
                                                         text:body];
    }
    return newMessage;
}

#pragma mark - XMPPMessageDelegate
- (void)newChatMessageReceived:(NSDictionary *)messageContent
{
    /**
     *  Show the typing indicator to be shown
     */
    self.showTypingIndicator = !self.showTypingIndicator;
    
    /**
     *  Scroll to actually view the indicator
     */
    [self scrollToBottomAnimated:YES];
    
    JSQMessage *newMessage = [self dictToJSQMessage:messageContent];
    if (newMessage) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            /**
             *  Upon receiving a message, you should:
             *
             *  1. Play sound (optional)
             *  2. Add new id<JSQMessageData> object to your data source
             *  3. Call `finishReceivingMessage`
             */
            [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
            [self.chatMessageData.messages addObject:newMessage];
            [self finishReceivingMessage];
        });
    }
}

- (IBAction)onDoneTouched:(id)sender {
    [[ApplicationManager sharedManager].xmppManager4Chat setReadChatMessageFromStorage:self.buddyId];
    if (self.completion) {
        self.completion();
    }
}

- (IBAction)onMoreTouched:(UIControl *)sender {
    NSArray *childNameArray = @[@"清除记录"];
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    for (NSString *name in childNameArray) {
        KxMenuItem * menuItem = [KxMenuItem menuItem:name
                                               image:nil
                                              target:self
                                              action:@selector(onClearMenuTouched:)];
        [menuItems addObject:menuItem];
    }
    [KxMenu setTintColor:[UIColor whiteColor]];
    CGRect rect = sender.frame;
    rect.origin.x = rect.origin.x + rect.size.height/2;
    [KxMenu showMenuInView:self.view
                  fromRect:rect
                 menuItems:menuItems];
}

- (void)onClearMenuTouched:(KxMenuItem*)sender
{
    [[ApplicationManager sharedManager].xmppManager4Chat removeChatMessageFromStorage:self.buddyId];
    [_chatMessageData.messages  removeAllObjects];
    [self.collectionView reloadData];
}

@end
