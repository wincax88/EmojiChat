//
//  QuickAnswerCell.m
//  iChat
//
//  Created by michael on 25/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "QuickAnswerCell.h"
#import "YBUtility.h"
#import "ApplicationManager.h"
#import "NotificationObject.h"
#import "AccountObject.h"
#import "ButtonCell.h"
#import "NSString+ContainString.h"
#import "AppConstant.h"

@interface QuickAnswerCell()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSDictionary *quickAnswer;
}

@end
@implementation QuickAnswerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [YBUtility makeRoundForImageView:self.avatarImageView];
}

- (IBAction)onAnswerTouched:(id)sender {
}

- (void)setNotification:(NotificationObject*)notification
{
    NSParameterAssert(notification);
    NSArray *filter = [[ApplicationManager sharedManager].friendList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"buddy.phone == %@", notification.senderid]];
    if (filter.count > 0) {
        FriendObject *friend = [filter firstObject];
//        [YBUtility setImageView:self.avatarImageView withURLString:friend.buddy[PF_USER_PICTURE] placeHolder:nil];
        self.nickLabel.text = friend.nickName;
    }
    NSString *message2 = notification.message;
    NSRange range = [message2 rangeOfString:@" ："];
    if (range.location != NSNotFound) {
        message2 = [message2 substringFromIndex:(range.location + range.length)];
    }
    self.messageLabel.text = message2;
    // find answers
    filter = [[ApplicationManager sharedManager].quickChatGroups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"message == %@", message2]];
    quickAnswer = filter.count > 0 ? filter.firstObject : nil;
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *answers = [quickAnswer objectForKey:@"answers"];
    return [answers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ButtonCell *cell = (ButtonCell*)[tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
    NSArray *answers = [quickAnswer objectForKey:@"answers"];
    [cell.answerButton setTitle:[answers objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    
    cell.touchedBlock = ^ {
        if (self.quickAnswerBlock) {
            self.quickAnswerBlock(quickAnswer, indexPath.row);
        }
    };
    
    return cell;
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.quickAnswerBlock) {
        self.quickAnswerBlock(quickAnswer, indexPath.row);
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
