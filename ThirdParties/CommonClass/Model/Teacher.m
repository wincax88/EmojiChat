//
//  Teacher.m
//  iStudent
//
//  Created by stephen on 10/10/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "Teacher.h"
#import "Video.h"
#import "VideoObject.h"

@implementation Teacher

- (void)dealloc {
    _quiz_analyse = nil;
    _quiz_video = nil;
}

- (id)init {
    if (self = [super init]) {
        _quiz_analyse = [[NSMutableArray alloc] init];
        _quiz_video = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setQuiz_analyse:(id)quiz_analyse
{
    [_quiz_analyse removeAllObjects];
    for (NSString *item in quiz_analyse) {
        [_quiz_analyse addObject:item];
    }
}

- (void)setQuiz_video:(id)quiz_video
{
    [_quiz_video removeAllObjects];
    for (NSDictionary *item in quiz_video) {
        VideoObject *video = [[VideoObject alloc] init];
        for (NSString *key in item.allKeys) {
            if ([video respondsToSelector:NSSelectorFromString(key)]) {
                [video setValue:[item valueForKey:key] forKey:key];
            }
            else {
                NSParameterAssert(false);
            }
        }
        [_quiz_video addObject:video];
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.teacherid forKey:@"teacherid"];
    [coder encodeObject:self.nick forKey:@"nick"];
    [coder encodeObject:self.face forKey:@"face"];
    [coder encodeObject:self.work_year forKey:@"work_year"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.level forKey:@"level"];
    [coder encodeObject:self.base_intro forKey:@"base_intro"];
    [coder encodeObject:self.rate_cnt forKey:@"rate_cnt"];
    [coder encodeObject:self.rate_score forKey:@"rate_score"];
    [coder encodeObject:self.rate_effect forKey:@"rate_effect"];
    [coder encodeObject:self.rate_quality forKey:@"rate_quality"];
    [coder encodeObject:self.rate_interact forKey:@"rate_interact"];
    [coder encodeObject:self.advantage forKey:@"advantage"];
    [coder encodeObject:self.phone forKey:@"phone"];
    [coder encodeObject:self.gender forKey:@"gender"];
    [coder encodeObject:self.grade forKey:@"grade"];
    [coder encodeObject:self.school forKey:@"school"];
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeObject:self.birth forKey:@"birth"];
    [coder encodeObject:self.lesson_desc forKey:@"lesson_desc"];
    [coder encodeObject:self.tutor_grade forKey:@"tutor_grade"];
    [coder encodeObject:self.tutor_subject forKey:@"tutor_subject"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.teacherid = [decoder decodeObjectForKey:@"teacherid"];
    self.nick = [decoder decodeObjectForKey:@"nick"];
    self.face = [decoder decodeObjectForKey:@"face"];
    self.work_year = [decoder decodeObjectForKey:@"work_year"];
    self.title = [decoder decodeObjectForKey:@"title"];
    self.level = [decoder decodeObjectForKey:@"level"];
    self.base_intro = [decoder decodeObjectForKey:@"base_intro"];
    self.rate_cnt = [decoder decodeObjectForKey:@"rate_cnt"];
    self.rate_score = [decoder decodeObjectForKey:@"rate_score"];
    self.rate_effect = [decoder decodeObjectForKey:@"rate_effect"];
    self.rate_quality = [decoder decodeObjectForKey:@"rate_quality"];
    self.rate_interact = [decoder decodeObjectForKey:@"rate_interact"];
    self.advantage = [decoder decodeObjectForKey:@"advantage"];
    self.phone = [decoder decodeObjectForKey:@"phone"];
    self.gender = [decoder decodeObjectForKey:@"gender"];
    self.grade = [decoder decodeObjectForKey:@"grade"];
    self.school = [decoder decodeObjectForKey:@"school"];
    self.address = [decoder decodeObjectForKey:@"address"];
    self.birth = [decoder decodeObjectForKey:@"birth"];
    self.lesson_desc = [decoder decodeObjectForKey:@"lesson_desc"];
    self.tutor_grade = [decoder decodeObjectForKey:@"tutor_grade"];
    self.tutor_subject = [decoder decodeObjectForKey:@"tutor_subject"];
    
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    Teacher* teacher = [[Teacher alloc] init];
    teacher.teacherid = self.teacherid;
    teacher.nick = self.nick;
    teacher.face = self.face;
    teacher.work_year = self.work_year;
    teacher.title = self.title;
    teacher.level = self.level;
    teacher.base_intro = self.base_intro;
    teacher.rate_cnt = self.rate_cnt;
    teacher.rate_score = self.rate_score;
    teacher.rate_effect = self.rate_effect;
    teacher.rate_quality = self.rate_quality;
    teacher.rate_interact = self.rate_interact;
    teacher.advantage = self.advantage;
    teacher.phone = self.phone;
    teacher.gender = self.gender;
    teacher.grade = self.grade;
    teacher.school = self.school;
    teacher.address = self.address;
    teacher.birth = self.birth;
    teacher.lesson_desc = self.lesson_desc;
    teacher.tutor_grade = self.tutor_grade;
    teacher.tutor_subject = self.tutor_subject;
    return teacher;
}

@end
