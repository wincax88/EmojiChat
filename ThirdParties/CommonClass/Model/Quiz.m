//
//  Quiz.m
//  iStudent
//
//  Created by stephen on 10/29/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "Quiz.h"

@implementation Quiz

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
}

#pragma mark - NSCoding

-(id) initWithCoder: (NSCoder*) coder {
    if (self = [super init]) {
        
        self.quizid            = [coder decodeObjectForKey:@"quizid"];
        self.courseid          = [coder decodeObjectForKey:@"courseid"];
        self.teacherid         = [coder decodeObjectForKey:@"teacherid"];
        self.assistantid       = [coder decodeObjectForKey:@"assistantid"];
//        self.lesson_num        = [coder decodeObjectForKey:@"lesson_num"];
//        self.lesson_type       = [coder decodeObjectForKey:@"lesson_type"];
        self.work_start        = [coder decodeObjectForKey:@"work_start"];
        self.work_end          = [coder decodeObjectForKey:@"work_end"];
        self.work_intro        = [coder decodeObjectForKey:@"work_intro"];
        self.work_status       = [coder decodeObjectForKey:@"work_status"];
        self.score             = [coder decodeObjectForKey:@"score"];
        self.quiz_num          = [coder decodeObjectForKey:@"quiz_num"];
        self.quiz_type         = [coder decodeObjectForKey:@"quiz_type"];
        self.quiz_name         = [coder decodeObjectForKey:@"quiz_name"];
        self.download_url      = [coder decodeObjectForKey:@"download_url"];
//        self.upload_time       = [coder decodeObjectForKey:@"upload_time"];
        self.cacheUrl          = [coder decodeObjectForKey:@"cacheUrl"];
//        self.quizFile          = [coder decodeObjectForKey:@"quizFile"];
    }
    return self;
}


-(void) encodeWithCoder: (NSCoder*) coder {
    [coder encodeObject:self.quizid forKey:@"quizid"];
    [coder encodeObject:self.courseid forKey:@"courseid"];
    [coder encodeObject:self.teacherid forKey:@"teacherid"];
    [coder encodeObject:self.assistantid forKey:@"assistantid"];
//    [coder encodeObject:self.lesson_num forKey:@"lesson_num"];
//    [coder encodeObject:self.lesson_type forKey:@"lesson_type"];
    [coder encodeObject:self.work_start forKey:@"work_start"];
    [coder encodeObject:self.work_end forKey:@"work_end"];
    [coder encodeObject:self.work_intro forKey:@"work_intro"];
    [coder encodeObject:self.work_status forKey:@"work_status"];
    [coder encodeObject:self.score forKey:@"score"];
    [coder encodeObject:self.quiz_num forKey:@"quiz_num"];
    [coder encodeObject:self.quiz_type forKey:@"quiz_type"];
    [coder encodeObject:self.quiz_name forKey:@"quiz_name"];
    [coder encodeObject:self.download_url forKey:@"download_url"];
//    [coder encodeObject:self.upload_time forKey:@"upload_time"];
    [coder encodeObject:self.cacheUrl forKey:@"cacheUrl"];
//    [coder encodeObject:self.quizFile forKey:@"quizFile"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    Quiz *quiz = [[Quiz alloc] init];
    
    quiz.quizid              = self.quizid;
    quiz.courseid            = self.courseid;
    quiz.teacherid           = self.teacherid;
    quiz.assistantid         = self.assistantid;
//    quiz.lesson_num          = self.lesson_num;
//    quiz.lesson_type         = self.lesson_type;
    quiz.work_start          = self.work_start;
    quiz.work_end            = self.work_end;
    quiz.work_intro          = self.work_intro;
    quiz.work_status         = self.work_status;
    quiz.score               = self.score;
    quiz.quiz_num            = self.quiz_num;
    quiz.quiz_type           = self.quiz_type;
    quiz.quiz_name           = self.quiz_name;
    quiz.download_url        = self.download_url;
//    quiz.upload_time         = self.upload_time;
    quiz.cacheUrl            = self.cacheUrl;
//    quiz.quizFile            = self.quizFile;
    
    return quiz;
}

@end
