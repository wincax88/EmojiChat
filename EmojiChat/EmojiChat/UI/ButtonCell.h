//
//  ButtonCell.h
//  iChat
//
//  Created by michael on 25/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *answerButton;

@property (copy) dispatch_block_t touchedBlock;

- (IBAction)onButtonTouched:(id)sender;

@end
