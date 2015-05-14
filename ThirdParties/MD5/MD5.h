//
//  MD5.h
//
//  Created by andychen on 13-11-9.
//  Copyright (c) 2013年 andychen . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5 : NSObject

+ (NSString *)md5:(NSString *)plainString;

+ (NSString *)md5DeviceToken:(NSString *)deviceToken;

+ (NSString *)md5WithoutKey:(NSString *)plainString;

+ (NSString *)md5WithKey:(const char *)key string:(NSString *)plainString;

+ (NSString *)md5NSData:(NSData*)data;

@end
