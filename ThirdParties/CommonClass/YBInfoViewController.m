//
//  YBInfoViewController.m
//  iStudent
//
//  Created by Stephen on 12/6/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "YBInfoViewController.h"

@interface YBInfoViewController ()

@end

@implementation YBInfoViewController

- (void)dealloc {
    _infoView = nil;
    _touchBlock = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.infoView.infoLabel.text = @"名师在线专业测评，全面了解薄弱环节，点击进入";
    self.infoView.imageView.image = [UIImage imageNamed:@"info_oval_white.png"];
    self.infoView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)infoTouched:(YBInfoView*)view {
    self.touchBlock();
}

- (void)infoBack:(YBInfoView*)view {
    self.backBlock();
}

@end
