//
//  Video.m
//  iStudent
//
//  Created by stephen on 10/21/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "Video.h"

@implementation Video

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)dealloc
{
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.lessonid forKey:@"lessonid"];
    [coder encodeObject:self.courseid forKey:@"courseid"];
    [coder encodeObject:self.lesson_intro forKey:@"lesson_intro"];
    [coder encodeObject:self.lesson_num forKey:@"lesson_num"];
    [coder encodeObject:self.thumbnail forKey:@"thumbnail"];
    [coder encodeObject:self.draw forKey:@"draw"];
    [coder encodeObject:self.audio forKey:@"audio"];
    [coder encodeObject:self.stu_score forKey:@"stu_score"];
    [coder encodeObject:self.lesson_intro forKey:@"lesson_intro"];
    [coder encodeObject:self.lesson_start forKey:@"lesson_start"];
    [coder encodeObject:self.lesson_end forKey:@"lesson_end"];
    [coder encodeObject:self.pause_start_time forKey:@"pause_start_time"];
    [coder encodeObject:self.pause_end_time forKey:@"pause_end_time"];
    /*
    [coder encodeObject:self.audioCacheUrl forKey:@"audioCacheUrl"];
    [coder encodeObject:self.drawCacheUrl forKey:@"drawCacheUrl"];
    [coder encodeObject:self.thumbnailCacheUrl forKey:@"thumbnailCacheUrl"];
    [coder encodeBool:self.isPause forKey:@"isPause"];*/
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.lessonid = [decoder decodeObjectForKey:@"lessonid"];
    self.courseid = [decoder decodeObjectForKey:@"courseid"];
    self.lesson_name = [decoder decodeObjectForKey:@"lesson_name"];
    self.lesson_intro = [decoder decodeObjectForKey:@"lesson_intro"];
    self.lesson_num = [decoder decodeObjectForKey:@"lesson_num"];
    self.thumbnail = [decoder decodeObjectForKey:@"thumbnail"];
    self.draw = [decoder decodeObjectForKey:@"draw"];
    self.audio = [decoder decodeObjectForKey:@"audio"];
    self.stu_score = [decoder decodeObjectForKey:@"stu_score"];
    self.lesson_intro = [decoder decodeObjectForKey:@"lesson_intro"];
    self.lesson_start = [decoder decodeObjectForKey:@"lesson_start"];
    self.lesson_end = [decoder decodeObjectForKey:@"lesson_end"];
    self.pause_start_time = [decoder decodeObjectForKey:@"pause_start_time"];
    self.pause_end_time = [decoder decodeObjectForKey:@"pause_end_time"];
/*
    self.audioCacheUrl = [decoder decodeObjectForKey:@"audioCacheUrl"];
    self.drawCacheUrl = [decoder decodeObjectForKey:@"drawCacheUrl"];
    self.thumbnailCacheUrl = [decoder decodeObjectForKey:@"thumbnailCacheUrl"];
    self.isPause = [decoder decodeBoolForKey:@"isPause"];*/
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    Video *newVideo = [[Video alloc] init];
    
    newVideo.lessonid = self.lessonid;
    newVideo.courseid = self.courseid;
    newVideo.lesson_name = self.lesson_name;
    newVideo.lesson_num = self.lesson_num;
    newVideo.thumbnail = self.thumbnail;
    newVideo.draw = self.draw;
    newVideo.audio = self.audio;
    newVideo.stu_score = self.stu_score;
    newVideo.lesson_intro = self.lesson_intro;
    newVideo.lesson_start = self.lesson_start;
    newVideo.lesson_end = self.lesson_end;
    newVideo.pause_start_time = self.pause_start_time;
    newVideo.pause_end_time = self.pause_end_time;
    /*
    newVideo.thumb_upload_time = self.thumb_upload_time;
    newVideo.lesson_upload_time = self.lesson_upload_time;
    newVideo.audioCacheUrl = self.audioCacheUrl;
    newVideo.drawCacheUrl = self.drawCacheUrl;
    newVideo.thumbnailCacheUrl = self.thumbnailCacheUrl;
    newVideo.progress = self.progress;
    newVideo.isPause = self.isPause;*/
    
    return newVideo;
}

#pragma mark - public
- (NSArray*)getDownloadUrls
{
    NSArray *files = [[NSArray alloc] initWithObjects:_thumbnail, _draw, _audio, nil];
    return files;
}

@end
