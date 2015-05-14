//
//  Comment.m
//  iStudent
//
//  Created by stephen on 10/30/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "Comment.h"

@implementation Comment

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
        self.teacher_comment    = [coder decodeObjectForKey:@"teacher_comment"];
        self.teacher_effect     = [coder decodeObjectForKey:@"teacher_effect"];
        self.teacher_quality    = [coder decodeObjectForKey:@"teacher_quality"];
        self.teacher_interact   = [coder decodeObjectForKey:@"teacher_interact"];
        self.stu_score        = [coder decodeObjectForKey:@"stu_score"];
        self.teacherid        = [coder decodeObjectForKey:@"teacherid"];
        self.studentid        = [coder decodeObjectForKey:@"studentid"];
        self.teacher_score    = [coder decodeObjectForKey:@"teacher_score"];
        self.stu_comment      = [coder decodeObjectForKey:@"stu_comment"];
        self.stu_attention    = [coder decodeObjectForKey:@"stu_attention"];
        self.stu_attitude     = [coder decodeObjectForKey:@"stu_attitude"];
        self.stu_ability      = [coder decodeObjectForKey:@"stu_ability"];
    }
    return self;
}


-(void) encodeWithCoder: (NSCoder*) coder {
    [coder encodeObject:self.teacher_comment forKey:@"teacher_comment"];
    [coder encodeObject:self.teacher_effect forKey:@"teacher_effect"];
    [coder encodeObject:self.teacher_quality forKey:@"teacher_quality"];
    [coder encodeObject:self.teacher_interact forKey:@"teacher_interact"];
    [coder encodeObject:self.stu_score forKey:@"stu_score"];
    [coder encodeObject:self.teacherid forKey:@"teacherid"];
    [coder encodeObject:self.studentid forKey:@"studentid"];
    [coder encodeObject:self.teacher_score forKey:@"teacher_score"];
    [coder encodeObject:self.stu_comment forKey:@"stu_comment"];
    [coder encodeObject:self.stu_attention forKey:@"stu_attention"];
    [coder encodeObject:self.stu_attitude forKey:@"stu_attitude"];
    [coder encodeObject:self.stu_ability forKey:@"stu_ability"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    Comment *newComment = [[Comment alloc] init];
    
    newComment.teacher_comment      = self.teacher_comment;
    newComment.teacher_effect       = self.teacher_effect;
    newComment.teacher_quality      = self.teacher_quality;
    newComment.teacher_interact     = self.teacher_interact;
    newComment.stu_score            = self.stu_score;
    newComment.teacherid            = self.teacherid;
    newComment.studentid            = self.studentid;
    newComment.teacher_score        = self.teacher_score;
    newComment.stu_comment          = self.stu_comment;
    newComment.stu_attention        = self.stu_attention;
    newComment.stu_attitude         = self.stu_attitude;
    newComment.stu_ability          = self.stu_ability;
    
    return newComment;
}

@end
