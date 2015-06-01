//
//  EmojiKeyBoardViewController.m
//  EmojiKeyboardTest
//
//  Created by michael on 15/5/31.
//  Copyright (c) 2015年 LeoEdu. All rights reserved.
//

#import "EmojiKeyBoardViewController.h"
#import "AGEmojiKeyboardView.h"

@interface EmojiKeyBoardViewController ()
<
AGEmojiKeyboardViewDelegate,
AGEmojiKeyboardViewDataSource
>
{
    AGEmojiKeyboardView *emojiKeyboardView;
}

@property (strong, nonatomic) IBOutlet UITextField *textField;

- (IBAction)onBackViewTouched:(id)sender;

@end

@implementation EmojiKeyBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadKeyboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showKeyBoard];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideKeyBoard];
}

- (void)dealloc
{
    emojiKeyboardView = nil;
}

#pragma mark - private
- (void)loadKeyboard
{
    if (!emojiKeyboardView) {
        emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
        emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        emojiKeyboardView.delegate = self;
    }
    
    self.textField.inputView = emojiKeyboardView;
}

#pragma mark - public
- (IBAction)onBackViewTouched:(id)sender
{
    if (self.backTouchBlock) {
        self.backTouchBlock();
    }
}

#pragma mark - public
- (void)showKeyBoard
{
    self.view.userInteractionEnabled = YES;
    [self.textField becomeFirstResponder];
}

- (void)hideKeyBoard
{
    [self.textField resignFirstResponder];
    self.view.userInteractionEnabled = NO;
}

#pragma mark - AGEmojiKeyboardViewDelegate
- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    // self.textField.text = emoji;
    if (self.emojiSelectedBlock) {
        self.emojiSelectedBlock(emoji);
    }
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    
}

#pragma mark - private

#pragma mark - AGEmojiKeyboardViewDataSource
- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img;
    if (category == AGEmojiKeyboardViewCategoryImageRecent) {
        img = [UIImage imageNamed:@"ic_emoji_recent_light_activated"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageFace) {
        img = [UIImage imageNamed:@"ic_emoji_people_light_activated"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageBell) {
        img = [UIImage imageNamed:@"ic_emoji_objects_light_activated"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageFlower) {
        img = [UIImage imageNamed:@"ic_emoji_nature_light_activated"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageCar) {
        img = [UIImage imageNamed:@"ic_emoji_places_light_activated"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageCharacters) {
        img = [UIImage imageNamed:@"ic_emoji_symbols_light_activated"];
    }
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    ///    UIImage *img = [self randomImage];
    ///    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *img;
    if (category == AGEmojiKeyboardViewCategoryImageRecent) {
        img = [UIImage imageNamed:@"ic_emoji_recent_light_normal"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageFace) {
        img = [UIImage imageNamed:@"ic_emoji_people_light_normal"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageBell) {
        img = [UIImage imageNamed:@"ic_emoji_objects_light_normal"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageFlower) {
        img = [UIImage imageNamed:@"ic_emoji_nature_light_normal"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageCar) {
        img = [UIImage imageNamed:@"ic_emoji_places_light_normal"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageCharacters) {
        img = [UIImage imageNamed:@"ic_emoji_symbols_light_normal"];
    }
    
    return img;
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    //    UIImage *img = [self randomImage];
    //    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *img = [UIImage imageNamed:@"orca_emoji_backspace_back_normal"];
    return img;
}

@end
