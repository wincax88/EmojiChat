//
//  PublicCourseMember.h
//  PlaybackDemo
//
//  Created by michael on 13/4/15.
//  Copyright (c) 2015 michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicCourseMember : NSObject

@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* nickName;
@property (nonatomic, strong) NSString* avatarUrl;
@property (nonatomic, strong) NSNumber* latestDate;
@property (nonatomic, strong) NSNumber* handUpDate;
@property (nonatomic, readwrite) BOOL isHandUp;
@property (nonatomic, readwrite) BOOL isInVoice;

- (NSComparisonResult)compareByHandUpDate:(PublicCourseMember *)another;

@end
