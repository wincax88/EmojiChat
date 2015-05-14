//
//  Video.h
//  iStudent
//
//  Created by stephen on 10/21/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video : NSObject  <NSCoding, NSCopying>

@property (nonatomic, retain) NSNumber* lessonid;             // 课次id
@property (nonatomic, retain) NSNumber* courseid;             // 课程id
@property (nonatomic, retain) NSNumber* lesson_num;           // 第几节课
@property (nonatomic, retain) NSString* lesson_name;          // 课次名称
@property (nonatomic, retain) NSString* thumbnail;            // 缩略图
@property (nonatomic, retain) NSString* draw;                 // 画笔信息
@property (nonatomic, retain) NSString* audio;                // 音频信息
@property (nonatomic, retain) NSNumber* stu_score;            // 老师对学生课堂表现评价
@property (nonatomic, retain) NSString* lesson_intro;         // 课次简介（包括知识点之类
@property (nonatomic, retain) NSNumber* lesson_start;         // 上课开始时间
@property (nonatomic, retain) NSNumber* lesson_end;           // 上课结束时间
@property (nonatomic, retain) NSNumber* pause_start_time;     // 暂停开始时间
@property (nonatomic, retain) NSNumber* pause_end_time;       // 暂停结束时间

//@property (nonatomic, retain) NSNumber* thumb_upload_time;  // 缩略图上传时间
//@property (nonatomic, retain) NSNumber* lesson_upload_time; // 课程上传时间

/*
@property (nonatomic, retain) NSString* audioCacheUrl;
@property (nonatomic, retain) NSString* drawCacheUrl;
@property (nonatomic, retain) NSString* thumbnailCacheUrl;
@property (nonatomic) float progress;

@property (nonatomic) BOOL isPause;

- (NSArray*)getDownloadUrls;
*/
@end
