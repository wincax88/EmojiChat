//
//  ParseConfigure.m
//  EmojiChat
//
//  Created by michael on 15/6/1.
//  Copyright (c) 2015年 LeoEdu. All rights reserved.
//

#import "ParseConfigure.h"
#import "AppConstant.h"
#import "ConfigureObject.h"

void getConfigure(ConfigureObject *configureObject)
{
    //NSParameterAssert(configureObject != nil);
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (config && !error) {
            configureObject.downUrl = config[PF_CONFIG_DOWN_URL];
            configureObject.emojiSound = config[PF_CONFIG_EMOJI_SOUND];
        }
    }];
}