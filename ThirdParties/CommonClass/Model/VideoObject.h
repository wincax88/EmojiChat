//
//  VideoObject.h
//  iStudent
//
//  Created by Stephen on 1/8/15.
//  Copyright (c) 2015 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoObject : NSObject <NSCoding, NSCopying>

@property (nonatomic, retain) NSString* video_url;
@property (nonatomic, retain) NSString* video_title;
@property (nonatomic, retain) NSString* video_thumbnail;

@end
