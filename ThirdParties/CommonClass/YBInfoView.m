//
//  YBInfoView.m
//  iStudent
//
//  Created by Stephen on 12/4/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "YBInfoView.h"

@implementation YBInfoView

- (void)dealloc {
    _infoLabel = nil;
    _imageView = nil;
    _delegate = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)infoTouch:(id)sender {
    [self.delegate infoTouched:self];
}

- (IBAction)infoBack:(id)sender {
    [self.delegate infoBack:self];
}

@end
