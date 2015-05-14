//
//  MineInfoCell.m
//  iParent
//
//  Created by michael on 22/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "MineInfoCell.h"

@implementation MineInfoCell

- (void)awakeFromNib {
    // Initialization code
    self.badgeView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
