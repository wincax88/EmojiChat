//
//  Student.m
//  iStudent
//
//  Created by stephen on 10/10/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "Student.h"
#import "Lesson.h"

@implementation Student

- (void)dealloc {
    _lesson_record = nil;
}

- (id)init {
    if (self = [super init]) {
        _lesson_record = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setLesson_record:(NSMutableArray *)lessonRecord
{
    [_lesson_record removeAllObjects];
    
    for (NSDictionary *item in lessonRecord) {
        Lesson *lesson = [[Lesson alloc] init];
        for (NSString *key in [item allKeys]) {
            if ([lesson respondsToSelector:NSSelectorFromString(key)]) {
                [lesson setValue:[item valueForKey:key] forKey:key];
            }
            else {
                NSParameterAssert(false);
            }
        }
        [_lesson_record addObject:lesson];
    }
}

@end
