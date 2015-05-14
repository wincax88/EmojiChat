//
//  ContactObject.h
//  iParent
//
//  Created by michael on 14/11/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactObject : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *latestMessage;
@property (nonatomic, retain) NSString *latestTime;
@property (nonatomic, retain) NSString *avatarUrl;

@end
