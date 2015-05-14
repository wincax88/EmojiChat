//
//  VideoObject.m
//  iStudent
//
//  Created by Stephen on 1/8/15.
//  Copyright (c) 2015 taomee. All rights reserved.
//

#import "VideoObject.h"

@implementation VideoObject

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.video_url forKey:@"video_url"];
    [coder encodeObject:self.video_title forKey:@"video_title"];
    [coder encodeObject:self.video_thumbnail forKey:@"video_thumbnail"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.video_url = [decoder decodeObjectForKey:@"video_url"];
    self.video_title = [decoder decodeObjectForKey:@"video_title"];
    self.video_thumbnail = [decoder decodeObjectForKey:@"video_thumbnail"];
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    VideoObject *newVideo = [[VideoObject alloc] init];
    
    newVideo.video_url = self.video_url;
    newVideo.video_title = self.video_title;
    newVideo.video_thumbnail = self.video_thumbnail;
    
    return newVideo;
}

@end
