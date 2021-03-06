//
//  ViewController.m
//  EmojiKeyboardTest
//
//  Created by michael on 21/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "ViewController.h"
#import "AGEmojiKeyboardView.h"
#import "EmojiKeyBoardViewController.h"

@interface ViewController ()
<
AGEmojiKeyboardViewDelegate,
AGEmojiKeyboardViewDataSource
>
{
    //AGEmojiKeyboardView *emojiKeyboardView;
    
    EmojiKeyBoardViewController *keyBoard;
}

@property (strong, nonatomic) IBOutlet UITextField *textField;

- (IBAction)onShowTouched:(id)sender;
- (IBAction)onHideTouched:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[self loadKeyboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)loadKeyboard
{
    if (!emojiKeyboardView) {
        emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
        emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        emojiKeyboardView.delegate = self;
    }

    self.textField.inputView = emojiKeyboardView;
}
*/
#pragma mark - action
- (IBAction)onShowTouched:(id)sender
{
    //[self.textField becomeFirstResponder];
    if (keyBoard) {
        [keyBoard showKeyBoard];
        return;
    }
    keyBoard = [[EmojiKeyBoardViewController alloc] initWithNibName:@"EmojiKeyBoardViewController" bundle:nil];
    [self addChildViewController:keyBoard];
    [self.view addSubview:keyBoard.view];
    __weak EmojiKeyBoardViewController *weakKeyBoard = keyBoard;
    keyBoard.backTouchBlock = ^ { // hide key board
        [weakKeyBoard hideKeyBoard];
        //[weakKeyBoard.view removeFromSuperview];
        //[weakKeyBoard removeFromParentViewController];
    };
}

- (IBAction)onHideTouched:(id)sender
{
    //[self.textField resignFirstResponder];
}
/*
#pragma mark - AGEmojiKeyboardViewDelegate
- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    self.textField.text = emoji;
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
*/

@end
