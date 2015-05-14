//
//  Student.h
//  iStudent
//
//  Created by stephen on 10/10/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STU_GRADE @[@"六年级", @"七年级", @"八年级", @"九年级"]

@interface Student : NSObject

@property (nonatomic, retain) NSNumber *userid;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, copy) NSString* nick;
@property (nonatomic, retain) NSNumber* grade;
@property (nonatomic, copy) NSString* address;
@property (nonatomic, retain) NSNumber* addr_code;
@property (nonatomic, copy) NSString* face;
@property (nonatomic, retain)NSNumber* praise;
@property (nonatomic, retain) NSNumber* teacherid;
@property (nonatomic, retain) NSString* teacher_nick;
@property (nonatomic, retain) NSNumber* assistantid;
@property (nonatomic, retain) NSNumber* course_type;
@property (nonatomic, retain) NSNumber* course_start;
@property (nonatomic, retain) NSNumber* course_end;
@property (nonatomic, retain) NSNumber* lesson_total;
@property (nonatomic, retain) NSNumber* lesson_left;
@property (nonatomic, retain) NSNumber* quiz_total;
@property (nonatomic, retain) NSNumber* quiz_left;
@property (nonatomic, retain) NSNumber* course_status;
@property (nonatomic, retain) NSString* phone;
@property (nonatomic, retain) NSString* school;
@property (nonatomic, retain) NSString* textbook;
@property (nonatomic, retain) NSMutableArray* lesson_record;
@property (nonatomic, retain) NSNumber* test_status;
@property (nonatomic, retain) NSNumber* gift_sent;
@property (nonatomic, retain) NSNumber* is_paid;
@property (nonatomic, retain) NSNumber* has_quiz;
@property (nonatomic, retain) NSNumber* revisit_cnt;
@property (nonatomic, retain) NSString* parent_phone;
@property (nonatomic, retain) NSString* teacher_phone;
@property (nonatomic, retain) NSNumber* course_color;

@end
