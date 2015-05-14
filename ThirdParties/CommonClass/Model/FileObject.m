//
//  FileObject.m
//  iTao
//
//  Created by stephen on 14-8-12.
//  Copyright (c) 2014年 taomee. All rights reserved.
//

#import "FileObject.h"
#import "YBUtility.h"

@implementation FileObject

- (id)init {
    if (self = [super init]) {
        _isOpen = NO;
        _needsUpdate = NO;
    }
    
    return self;
}

- (void)setDownload_url:(NSString *)download_url {
    _download_url = download_url;
    if (download_url && download_url.length > 0) {
        _cacheUrl = [YBUtility getDownloadPath4Document:download_url];
    }
    
}

- (void)dealloc
{
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.lesson_type forKey:@"lesson_type"];
    [coder encodeObject:self.courseid forKey:@"courseid"];
    [coder encodeObject:self.teacherid forKey:@"teacherid"];
    [coder encodeObject:self.file_name forKey:@"file_name"];
    [coder encodeObject:self.work_intro forKey:@"work_intro"];
    [coder encodeObject:self.lesson_num forKey:@"lesson_num"];
    [coder encodeObject:self.lessonid forKey:@"lessonid"];
    [coder encodeObject:self.work_status forKey:@"work_status"];
    [coder encodeObject:self.upload_time forKey:@"upload_time"];
    [coder encodeObject:self.download_url forKey:@"download_url"];
    [coder encodeObject:self.finish_time forKey:@"finish_time"];
    [coder encodeObject:self.finish_url forKey:@"finish_url"];
    [coder encodeObject:self.check_time forKey:@"check_time"];
    [coder encodeObject:self.check_url forKey:@"check_url"];
    [coder encodeObject:self.score forKey:@"score"];
    [coder encodeObject:self.work_start forKey:@"work_start"];
    [coder encodeObject:self.work_end forKey:@"work_end"];
    
    [coder encodeBool:self.isOpen forKey:@"isOpen"];
    [coder encodeBool:self.needsUpdate forKey:@"needsUpdate"];
    [coder encodeObject:self.image forKey:@"image"];
    [coder encodeObject:self.cacheUrl forKey:@"cacheUrl"];
    [coder encodeFloat:self.fileSize forKey:@"fileSize"];
    [coder encodeInt:self.filePage forKey:@"filePage"];
    [coder encodeFloat:self.progress forKey:@"progress"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.lesson_type = [decoder decodeObjectForKey:@"lesson_type"];
    self.courseid = [decoder decodeObjectForKey:@"courseid"];
    self.teacherid = [decoder decodeObjectForKey:@"teacherid"];
    self.work_intro = [decoder decodeObjectForKey:@"work_intro"];
    self.lesson_num = [decoder decodeObjectForKey:@"lesson_num"];
    self.lessonid = [decoder decodeObjectForKey:@"lessonid"];
    self.work_status = [decoder decodeObjectForKey:@"work_status"];
    self.file_name = [decoder decodeObjectForKey:@"file_name"];
    self.upload_time = [decoder decodeObjectForKey:@"upload_time"];
    self.download_url = [decoder decodeObjectForKey:@"download_url"];
    self.finish_time = [decoder decodeObjectForKey:@"finish_time"];
    self.finish_url = [decoder decodeObjectForKey:@"finish_url"];
    self.check_time = [decoder decodeObjectForKey:@"check_time"];
    self.check_url = [decoder decodeObjectForKey:@"check_url"];
    self.score = [decoder decodeObjectForKey:@"score"];
    self.work_start = [decoder decodeObjectForKey:@"work_start"];
    self.work_end = [decoder decodeObjectForKey:@"work_end"];
    
    self.isOpen = [decoder decodeBoolForKey:@"isOpen"];
    self.needsUpdate = [decoder decodeBoolForKey:@"needsUpdate"];
    self.image = [decoder decodeObjectForKey:@"image"];
    self.cacheUrl = [decoder decodeObjectForKey:@"cacheUrl"];
    self.fileSize = [decoder decodeFloatForKey:@"fileSize"];
    self.filePage = [decoder decodeIntForKey:@"filePage"];
    self.progress = [decoder decodeFloatForKey:@"progress"];
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    FileObject *newFileObject = [[FileObject alloc] init];
    
    newFileObject.lesson_type       = self.lesson_type;
    newFileObject.courseid          = self.courseid;
    newFileObject.teacherid         = self.teacherid;
    newFileObject.work_intro        = self.work_intro;
    newFileObject.lesson_num        = self.lesson_num;
    newFileObject.preview_status    = self.preview_status;
    newFileObject.work_status       = self.work_status;
    newFileObject.file_name         = self.file_name;
    newFileObject.upload_time       = self.upload_time;
    newFileObject.download_url      = self.download_url;
    newFileObject.finish_time       = self.finish_time;
    newFileObject.finish_url        = self.finish_url;
    newFileObject.check_time        = self.check_time;
    newFileObject.check_url         = self.check_url;
    newFileObject.score             = self.score;
    newFileObject.isOpen            = self.isOpen;
    newFileObject.needsUpdate       = self.needsUpdate;
    newFileObject.image             = self.image;
    newFileObject.cacheUrl          = self.cacheUrl;
    newFileObject.fileSize          = self.fileSize;
    newFileObject.filePage          = self.filePage;
    newFileObject.progress          = self.progress;
    
    return newFileObject;
}

@end
