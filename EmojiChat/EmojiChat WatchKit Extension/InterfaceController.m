//
//  InterfaceController.m
//  EmojiChat WatchKit Extension
//
//  Created by michael on 13/5/15.
//  Copyright (c) 2015 LeoEdu. All rights reserved.
//

#import "InterfaceController.h"

#import <Parse/Parse.h>

@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    
    // Enable data sharing in app extensions.
    [Parse enableDataSharingWithApplicationGroupIdentifier:@"group.com.parse.parseuidemo" containingApplication:@"com.parse.parseuidemo"];
    // Setup Parse
    [Parse setApplicationId:@"f5Eiapb3uDqD6wODSmEYpbbpNvfpGTwjL5ePuXLh" clientKey:@"5JD23aAWSKvHhdjiRVuiPTO88QQ6TaTUjLfKoCpm"];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



