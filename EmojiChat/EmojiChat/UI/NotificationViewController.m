//
//  NotificationViewController.m
//  iChat
//
//  Created by michael on 22/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController ()
{
    NSArray *identifierArray;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    identifierArray = @[@"NotificationCell", @"NotificationCell2", @"DetailCell", @"DetailCell2", @"AudioCell", @"AudioCell2"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [identifierArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // @"CacheCell", @"AboutCell"
    NSString *cellIdentifier = [identifierArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    return cell;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
