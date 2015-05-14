//
//  UITabBarItem+CustomBadge.m
//  CityGlance
//
//  Created by Enrico Vecchio on 18/05/14.
//  Copyright (c) 2014 Cityglance SRL. All rights reserved.
//

#import "UITabBarItem+CustomBadge.h"


#define CUSTOM_BADGE_TAG 99
#define OFFSET 0.6f


@implementation UITabBarItem (CustomBadge)


- (void)setMyAppCustomBadgeValue:(NSString *)value size:(CGSize)size
{
    UIFont  *myAppFont      = [UIFont systemFontOfSize:13.0];
    UIColor *myAppFontColor = [UIColor whiteColor];
    UIColor *myAppBackColor = [UIColor redColor]; // [UIColor colorWithRed:1.0f green:59.0f/255 blue:48.0f/255 alpha:1.0f];
    
    [self setCustomBadgeValue:value withFont:myAppFont andFontColor:myAppFontColor andBackgroundColor:myAppBackColor size:size];
}



- (void)setCustomBadgeValue: (NSString *) value withFont: (UIFont *) font andFontColor: (UIColor *) color andBackgroundColor: (UIColor *) backColor size:(CGSize)size
{
    UIView *view = (UIView*)[self valueForKey:@"view"];
    
    [self setBadgeValue:value];
    
    // remove old one
    for (UIView *subview in [view subviews])
    {
        if (subview.tag == CUSTOM_BADGE_TAG) // badge has tag of 99
        {
            [subview removeFromSuperview];
            break;
        }
    }
    UIView *imageView = nil;
    for (UIView *subview in [view subviews]) {
        NSString *classStrring = NSStringFromClass([subview class]);
        if ([classStrring isEqualToString:@"UITabBarSwappableImageView"]) {
            imageView = subview;
        }
    }
    for (UIView *subview in [imageView subviews])
    {
        if (subview.tag == CUSTOM_BADGE_TAG) // badge has tag of 99
        {
            [subview removeFromSuperview];
            break;
        }
    }
    if (!value) {
        return;
    }
    for (UIView *subview in [view subviews])
    {
        NSString *classStrring = NSStringFromClass([subview class]);
         // UITabBarSwappableImageView UITabBarButtonLabel _UIBadgeView
        if ([classStrring isEqualToString:@"_UIBadgeView"])
        {
            // create new label view that we can style.
            // remove background, add border, make it nice
            CGRect rect = subview.frame;
            rect.size = size;
            UILabel* label = [[UILabel alloc] initWithFrame:rect];
            
            label.backgroundColor = backColor;
            label.layer.cornerRadius = label.frame.size.height / 2;
            label.layer.masksToBounds = true;
            
            if (imageView) {
                rect = [view convertRect:rect toView:imageView];
                label.frame = rect;
                [imageView addSubview:label];
            }
            else {
                [view addSubview:label];
                [view bringSubviewToFront:label];
            }
            subview.hidden = true;
            
            label.Tag = CUSTOM_BADGE_TAG; // fake it here for iOS ;)
            
            break;
        }
    }
}


@end
