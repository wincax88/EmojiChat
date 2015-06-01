//
//  QuickAnswerViewController.m
//  iChat
//
//  Created by michael on 22/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "QuickAnswerViewController.h"
#import "ApplicationManager.h"
#import "YBUtility.h"
#import "QuickAnswerCell.h"
#import "NotificationObject.h"
#import "PostView.h"
#import "JSQSystemSoundPlayer.h"

@interface QuickAnswerViewController ()
<
PostViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UITextViewDelegate
>
{
    NSArray *quickMessageArray;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) IBOutlet UIView *inputView;

@property (weak, nonatomic) PostView *attachedPostView;

- (IBAction)onCloseTouched:(id)sender;
- (IBAction)onSendTouched:(id)sender;

@end

@implementation QuickAnswerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    quickMessageArray = [ApplicationManager sharedManager].quickAnswerList;
    
    self.collectionView.pagingEnabled = YES;
    
    self.textView.delegate = self;

    // play last sound
    [self playLastSound];
    
    // **********************************************
    // * Add gesture recognizer for single tap to display image rotation menu
    // **********************************************
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.collectionView addGestureRecognizer:singleTap];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadPostView];
    self.textView.inputAccessoryView = self.attachedPostView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
// play last sound
- (void)playLastSound
{
    if (quickMessageArray.count > 0) {
        NotificationObject *notification = quickMessageArray.lastObject;
        NSArray *component = [notification.sound componentsSeparatedByString:@"."];
        [[JSQSystemSoundPlayer sharedPlayer] playSoundWithName:[component firstObject]
                                                     extension:[component lastObject]];
    }
}

// load post view
- (void)loadPostView {
    if (!self.attachedPostView) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"QuickAnswer" bundle:[NSBundle mainBundle]];
        UIViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"PostMessageViewController"];
        self.attachedPostView = (PostView*)viewController.view;
        self.attachedPostView.delegate = self;
        CGRect rect = self.attachedPostView.frame;
        rect.size.width = self.view.frame.size.width;
        rect.size.height = self.inputView.frame.size.height;
        self.attachedPostView.frame = rect;
    }
}

- (void)sendMessage:(NSDictionary*)quickAnswer index:(int)index to:(NSNumber*)buddy time:(NSNumber*)timestamp {
#ifdef DEBUG
    NSLog(@"send : %@", quickAnswer);
#endif
    NSArray *answers = [quickAnswer objectForKey:@"answers"];
    NSString *message = [answers objectAtIndex:index];
    NSString *nick = [ApplicationManager sharedManager].account.nick;
    if (nick.length <= 0) {
        nick = [ApplicationManager sharedManager].account.phone;
    }
    message = [NSString stringWithFormat:@"%@ ：%@", nick ,message];
    [self sendMessage:message to:buddy.stringValue audio:nil time:timestamp];
}

- (void)sendMessage:(NSString*)message to:(NSString *)buddy audio:(NSString *)audio time:(NSNumber*)timestamp
{
    if (buddy.length <= 0 || message.length <= 0) {
        return;
    }
    [YBUtility showInfoHUDInView:self.view message:nil];
    // send via xmpp
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // send message to buddy
//        [[ApplicationManager sharedManager].xmppManager4Chat sendTextMessage:message to:buddy];
//    });
    // send to server
    NSString *audioFile = @"common.mp3";
    if (audio.length > 0) {
        audioFile = audio;
    }
//    [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
//    [[ApplicationManager sharedManager].httpClientHandler sendMessage:message to:buddy audio:audioFile time:timestamp];
}

#pragma mark - puclic
- (void)refresh
{
    // play last sound
    [self playLastSound];
    
    [self.collectionView reloadData];
}

#pragma mark - action
- (IBAction)onCloseTouched:(id)sender {
    if (quickMessageArray.count <= 0) {
        if (self.closeBlock) {
            self.closeBlock();
        }
    }
    else {
        NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
        if (indexPaths.count > 0) {
            NSIndexPath *indexPath = indexPaths.firstObject;
            [[ApplicationManager sharedManager].quickAnswerList removeObjectAtIndex:indexPath.row];
            [self.collectionView reloadData];
        }
        else {
            if (self.closeBlock) {
                self.closeBlock();
            }
        }
    }
}

- (IBAction)onSendTouched:(id)sender {
    if (self.textView.text.length > 0) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
        if (indexPath) {
            NotificationObject *notification = [[ApplicationManager sharedManager].quickAnswerList objectAtIndex:indexPath.row];
            [self sendMessage:self.textView.text to:notification.senderid audio:nil time:notification.timestamp];
        }
    }
}

#pragma mark - Http
/*
- (void)didSendMessageSuccess:(NSString*)senders time:(NSNumber*)timestamp
{
    [[ApplicationManager sharedManager].httpClientHandler unregisterDelegate:self];
    [YBUtility showInfoHUDInView:self.view message:@"发送成功"];
    
    NSArray *component = [senders componentsSeparatedByString:@","];
    NSString *userId = component.firstObject;
    NSArray *filter = [[ApplicationManager sharedManager].quickAnswerList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"senderid == %@ AND timestamp = %@", [NSNumber numberWithInt:userId.intValue], timestamp]];
    if (filter.count > 0) {
        [[ApplicationManager sharedManager].quickAnswerList removeObjectsInArray:filter];
        [self.collectionView reloadData];
    }
    else {
        NSParameterAssert(false);
    }
}

- (void)didSendMessageFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [[ApplicationManager sharedManager].httpClientHandler unregisterDelegate:self];
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}
*/
#pragma mark - UICollectionViewDataSource
#pragma mark -


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    self.collectionView.hidden = quickMessageArray.count > 0 ? NO : YES;
    self.inputView.hidden = quickMessageArray.count > 0 ? NO : YES;
    
    return  quickMessageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QuickAnswerCell *cell = (QuickAnswerCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"QuickAnswerCell" forIndexPath:indexPath];
    
    NotificationObject *notification = [quickMessageArray objectAtIndex:indexPath.row];
    [cell setNotification:notification];
    __weak __typeof(self) weakSelf = self;

    cell.quickAnswerBlock = ^ (NSDictionary *quickAnswer, int index) {
        [weakSelf sendMessage:quickAnswer index:index to:notification.senderid time:notification.timestamp];
    };
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(self.collectionView.frame));
}

#pragma mark - Gestures
#pragma mark -

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    self.textView.text = self.attachedPostView.textView.text;
    [self.textView resignFirstResponder];
    [self.attachedPostView.textView resignFirstResponder];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing: (UITextView *) textView
{
    if (textView == self.textView)
    {
        // only become first responder if the inputAccessoryTextField isn't the first responder.
        return ![self.attachedPostView.textView isFirstResponder];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (self.textView == textView) {
        // can't change responder directly during textFieldDidBeginEditing.  postpone:
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.attachedPostView.textView.text = textView.text;
            
            [self.attachedPostView.textView becomeFirstResponder];
        });
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == self.textView)
    {
        self.attachedPostView.textView.text = textView.text;
    }
}
#pragma mark - PostViewDelegate

- (void)didSendButtonTouched:(PostView*)controller
{
    self.textView.text = self.attachedPostView.textView.text;
    
    [self.textView resignFirstResponder];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self onSendTouched:nil];
    });
}


@end
