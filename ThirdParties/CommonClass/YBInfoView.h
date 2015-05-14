//
//  YBInfoView.h
//  iStudent
//
//  Created by Stephen on 12/4/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YBInfoView;
@protocol YBInfoViewDelegate <NSObject>

- (void)infoTouched:(YBInfoView*)view;
- (void)infoBack:(YBInfoView*)view;

@end
@interface YBInfoView : UIView

@property (nonatomic, retain) IBOutlet UILabel* infoLabel;
@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, assign) id <YBInfoViewDelegate>delegate;


- (IBAction)infoTouch:(id)sender;
- (IBAction)infoBack:(id)sender;

@end
