//
//  Lesson.m
//  iStudent
//
//  Created by stephen on 10/29/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "Lesson.h"

@implementation Lesson

- (id)init
{
    self = [super init];
    if (self) {
        _cw_info    = [[CourseWareObject alloc] init];
        _comment_info = [[Comment alloc] init];
        _video_info = [[Video alloc] init];
        _work_info  = [[FileObject alloc] init];
    }
    return self;
}

- (void)dealloc
{
    _cw_info        = nil;
    _comment_info   = nil;
    _video_info     = nil;
    _work_info      = nil;
}

#pragma mark - NSCoding

-(id) initWithCoder: (NSCoder*) coder {
    if (self = [super init]) {
//        self.u_grade = [coder decodeObjectForKey:@"u_grade"];
    }
    return self;
}


-(void) encodeWithCoder: (NSCoder*) coder {
//    [coder encodeObject:self.u_grade forKey:@"u_grade"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    Lesson *newLesson = [[Lesson alloc] init];
    return newLesson;
}

- (void)setComment_info:(NSDictionary *)comment_info
{
    for (NSString *key in [comment_info allKeys]) {
        if ([self.comment_info respondsToSelector:NSSelectorFromString(key)]) {
            [self.comment_info setValue:[comment_info valueForKey:key] forKey:key];
        }
        else {
            NSParameterAssert(false);
        }
    }
}

- (void)setCw_info:(NSDictionary *)cw_info
{
    for (NSString *key in [cw_info allKeys]) {
        if ([self.cw_info respondsToSelector:NSSelectorFromString(key)]) {
            [self.cw_info setValue:[cw_info valueForKey:key] forKey:key];
        }
        else {
            NSParameterAssert(false);
        }
    }
}

- (void)setVideo_info:(NSDictionary *)video_info
{
    for (NSString *key in [video_info allKeys]) {
        if ([self.video_info respondsToSelector:NSSelectorFromString(key)]) {
            [self.video_info setValue:[video_info valueForKey:key] forKey:key];
        }
        else {
            NSParameterAssert(false);
        }
    }
}

- (void)setWork_info:(NSDictionary *)work_info
{
    for (NSString *key in [work_info allKeys]) {
        if ([self.work_info respondsToSelector:NSSelectorFromString(key)]) {
            [self.work_info setValue:[work_info valueForKey:key] forKey:key];
        }
        else {
            NSParameterAssert(false);
        }
    }
}

@end
