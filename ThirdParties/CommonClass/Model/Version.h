//
//  Version.h
//  iStudent
//
//  Created by Stephen on 1/30/15.
//  Copyright (c) 2015 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Version : NSObject

@property (nonatomic, retain) NSString* download_url;
@property (nonatomic, retain) NSNumber* type;
@property (nonatomic, retain) NSNumber* need_update;
@property (nonatomic, retain) NSNumber* update_content;

@end
