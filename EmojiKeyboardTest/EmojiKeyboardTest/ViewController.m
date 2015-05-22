//
//  ViewController.m
//  EmojiKeyboardTest
//
//  Created by michael on 21/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "ViewController.h"
#import "AGEmojiKeyboardView.h"

@interface ViewController ()
<
AGEmojiKeyboardViewDelegate,
AGEmojiKeyboardViewDataSource
>
{
    AGEmojiKeyboardView *emojiKeyboardView;
}

@property (strong, nonatomic) IBOutlet UITextField *textField;

- (IBAction)onShowTouched:(id)sender;
- (IBAction)onHideTouched:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadKeyboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadKeyboard
{
    if (!emojiKeyboardView) {
        emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
        emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        emojiKeyboardView.delegate = self;
    }

    self.textField.inputView = emojiKeyboardView;
}

#pragma mark - action
- (IBAction)onShowTouched:(id)sender
{
    [self.textField becomeFirstResponder];
}

- (IBAction)onHideTouched:(id)sender
{
    [self.textField resignFirstResponder];
}

#pragma mark - AGEmojiKeyboardViewDelegate
- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    self.textField.text = emoji;
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    
}

#pragma mark - private
- (UIColor *)randomColor {
    return [UIColor colorWithRed:drand48()
                           green:drand48()
                            blue:drand48()
                           alpha:drand48()];
}

- (UIImage *)randomImage {
    CGSize size = CGSizeMake(30, 10);
    UIGraphicsBeginImageContextWithOptions(size , NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(context, rect);
    
    fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGFloat xxx = 3;
    rect = CGRectMake(xxx, xxx, size.width - 2 * xxx, size.height - 2 * xxx);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - AGEmojiKeyboardViewDataSource
- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img;
    if (category == AGEmojiKeyboardViewCategoryImageRecent) {
        img = [UIImage imageNamed:@"ic_emoji_recent_light_normal"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageFace) {
        img = [UIImage imageNamed:@"orca_emoji_category_people"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageBell) {
        img = [UIImage imageNamed:@"orca_emoji_category_objects"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageFlower) {
        img = [UIImage imageNamed:@"orca_emoji_category_nature"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageCar) {
        img = [UIImage imageNamed:@"orca_emoji_category_cars"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageCharacters) {
        img = [UIImage imageNamed:@"orca_emoji_category_punctuation"];
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
        img = [UIImage imageNamed:@"orca_emoji_category_people"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageBell) {
        img = [UIImage imageNamed:@"orca_emoji_category_objects"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageFlower) {
        img = [UIImage imageNamed:@"orca_emoji_category_nature"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageCar) {
        img = [UIImage imageNamed:@"orca_emoji_category_cars"];
    }
    else if (category == AGEmojiKeyboardViewCategoryImageCharacters) {
        img = [UIImage imageNamed:@"orca_emoji_category_punctuation"];
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
