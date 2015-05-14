//
//  PublicCourseMember.m
//  PlaybackDemo
//
//  Created by michael on 13/4/15.
//  Copyright (c) 2015 michael. All rights reserved.
//

#import "PublicCourseMember.h"

@implementation PublicCourseMember


/**
 * Returns the result of invoking compareByName:options: with no options.
 **/
- (NSComparisonResult)compareByHandUpDate:(PublicCourseMember *)another
{
    if (another.handUpDate.doubleValue > self.handUpDate.doubleValue) {
        return NSOrderedAscending;
    }
    else if (another.handUpDate.doubleValue < self.handUpDate.doubleValue) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}


@end
