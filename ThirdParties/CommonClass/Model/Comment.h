//
//  Comment.h
//  iStudent
//
//  Created by stephen on 10/30/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject <NSCoding, NSCopying>

@property (nonatomic, retain) NSString* teacher_comment;
@property (nonatomic, retain) NSNumber* teacher_effect;
@property (nonatomic, retain) NSNumber* teacher_quality;
@property (nonatomic, retain) NSNumber* teacher_interact;
@property (nonatomic, retain) NSNumber* teacherid;
@property (nonatomic, retain) NSNumber* studentid;
@property (nonatomic, retain) NSNumber* stu_score;
@property (nonatomic, retain) NSNumber* teacher_score;
@property (nonatomic, retain) NSNumber* stu_comment;
@property (nonatomic, retain) NSNumber* stu_attention;
@property (nonatomic, retain) NSNumber* stu_attitude;
@property (nonatomic, retain) NSNumber* stu_ability;

@end
