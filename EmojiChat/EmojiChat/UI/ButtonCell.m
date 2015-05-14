//
//  ButtonCell.m
//  iChat
//
//  Created by michael on 25/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "ButtonCell.h"

@implementation ButtonCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onButtonTouched:(id)sender {
    if (self.touchedBlock) {
        self.touchedBlock();
    }
}
@end
