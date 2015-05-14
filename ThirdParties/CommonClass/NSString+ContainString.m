//
//  NSString+ContainString.m
//  iTeacher
//
//  Created by michael on 11/12/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "NSString+ContainString.h"

@implementation NSString (ContainsString)

- (BOOL)containsString:(NSString*)subString
{
    BOOL result = NO;
    
    NSRange range = [self rangeOfString:subString];
    result = range.location != NSNotFound;
    return result;
}

@end
