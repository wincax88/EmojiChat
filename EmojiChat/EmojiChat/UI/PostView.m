//
//  PostView.m
//  taozuoye
//
//  Created by michael on 14-3-30.
//  Copyright (c) 2014年 taomee. All rights reserved.
//

#import "PostView.h"
#import "CommonDefine.h"

@implementation PostView

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Action
- (IBAction)onSendButtonTouched:(id)sender
{
    [self.textView resignFirstResponder];
    if (self.delegate) {
        [self.delegate didSendButtonTouched:self];
    }
}

@end
