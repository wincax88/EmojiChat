//
//  QuickAnswerCell.h
//  iChat
//
//  Created by michael on 25/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^QuickAnswerTouchBlock) (NSDictionary *quickAnswer, int index);

@class NotificationObject;

@interface QuickAnswerCell : UICollectionViewCell

@property (copy) QuickAnswerTouchBlock quickAnswerBlock;

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nickLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)setNotification:(NotificationObject*)notification;

@end
