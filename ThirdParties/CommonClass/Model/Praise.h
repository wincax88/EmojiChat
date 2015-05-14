//
//  Praise.h
//  iStudent
//
//  Created by Stephen on 11/20/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Praise : NSObject

@property (nonatomic, retain) NSNumber* timestamp;
@property (nonatomic, copy) NSString* reason;
@property (nonatomic, retain) NSNumber* praise_num;
@property (nonatomic, retain) NSNumber* type;

@end
