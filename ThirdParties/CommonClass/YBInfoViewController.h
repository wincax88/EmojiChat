//
//  YBInfoViewController.h
//  iStudent
//
//  Created by Stephen on 12/6/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBInfoView.h"

@interface YBInfoViewController : UIViewController <YBInfoViewDelegate>

@property (nonatomic, copy) void(^touchBlock)();
@property (nonatomic, copy) void(^backBlock)();
@property (nonatomic, retain) IBOutlet YBInfoView* infoView;

@end
