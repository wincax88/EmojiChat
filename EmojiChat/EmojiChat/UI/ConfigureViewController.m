//
//  ConfigureViewController.m
//  iChat
//
//  Created by michael on 22/4/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "ConfigureViewController.h"
#import "MineInfoCell.h"
#import "YBUtility.h"
#import "UIAlertView+Blocks.h"
#import "AboutViewController.h"
#import "ApplicationManager.h"
#import <Parse/Parse.h>

@interface ConfigureViewController ()
{
    NSArray *identifierArray;
    NSString *cachePath;
    
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onLogoutButtonTouched:(id)sender;

@end

@implementation ConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    identifierArray = @[@"CacheCell", @"AboutCell"];
    
    cachePath = [YBUtility getCachePath];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [[ApplicationManager sharedManager].httpClientHandler unregisterDelegate:self];
//    [iVersion sharedInstance].delegate = nil;
//    [iRate sharedInstance].delegate = nil;
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearCache
{
    [YBUtility deleteFile:cachePath];
}

#pragma mark - private
// get cache folder size
- (unsigned long long)getCacheFolderSize {
    unsigned long long size = 0;
    NSString *filePath = cachePath;
    if ([YBUtility fileExists:filePath]){
        size = [YBUtility getFolderSize:filePath];
    }
    return size;
}

- (NSString*)getCacheSizeString {
    unsigned long long folderSize = [self getCacheFolderSize];
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
    // NSString *folderSizeStr = [NSString stringWithFormat:@"%.2f MB", size/(1024*1024.0f)];
    if ([folderSizeStr hasPrefix:@"Zero"] || [folderSizeStr hasPrefix:@"zero"]) {
        folderSizeStr = @"0 KB";
    }
    return folderSizeStr;
}

- (void)loadAboutViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MineViewController" bundle:[NSBundle mainBundle]];
    UINavigationController * nv = [storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
    AboutViewController *controller = [[nv childViewControllers] firstObject];
    __weak __typeof(self)weakSelf = self;
    controller.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

#pragma mark - action

- (IBAction)onLogoutButtonTouched:(id)sender
{
//    [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
//    [[ApplicationManager sharedManager].httpClientHandler logout];
    [YBUtility showInfoHUDInView:self.view message:nil];
    
    [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
        if (error) {
            [YBUtility showErrorMessageInView:self.view message:error.localizedDescription errorCode:nil];
        }
        else {
            [YBUtility hideInfoHUDInView:self.view];
            
            if (self.logoutBlock) {
                self.logoutBlock();
            }
        }
    }];
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
    MineInfoCell *cell = (MineInfoCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([cellIdentifier isEqualToString:@"CacheCell"]) {
        cell.valueLabel.text = [self getCacheSizeString];
    }
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // @"CacheCell", @"AboutCell"
    NSString *cellIdentifier = [identifierArray objectAtIndex:indexPath.row];
    if ([cellIdentifier isEqualToString:@"CacheCell"]) {
        // clear cache
        if ([self getCacheFolderSize] > 0) {
            [UIAlertView showWithTitle:nil message:@"确定清除缓存吗？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self clearCache];
                    [self.tableView reloadData];
                }
            }];
        }
    }
    else if ([cellIdentifier isEqualToString:@"AboutCell"]) {
        // load
        [self loadAboutViewController];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - HttpClientHandlerDelegate
- (void)didLogoutSuccess
{
    [YBUtility hideInfoHUDInView:self.view];
    
    [[ApplicationManager sharedManager].localSettingData setAutoLoginFlag:NO];
    [[ApplicationManager sharedManager] clean4Logout];
    
    if (self.logoutBlock) {
        self.logoutBlock();
    }
    
}

- (void)didLogoutFailed:(NSNumber*)errorCode message:(NSString*)errorMessage
{
    [YBUtility showErrorMessageInView:self.view message:errorMessage errorCode:errorCode];
}

@end
