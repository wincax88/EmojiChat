//
//  ManualUplaodManager.h
//  iTao
//
//  Created by michaelwong on 8/6/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpHandlerBase.h"

@class AFHTTPRequestOperation;

@protocol ManualUplaodManagerDelegate <NSObject>

@optional
- (void)onManualUploadProgress:(NSDictionary*)progressDic userData:(NSDictionary*)userData;
- (void)didManualUploadSuccess:(NSDictionary*)userData;
- (void)didManualUploadFailed:(NSError*)error userData:(NSDictionary*)userData;

@end

@interface ManualUplaodManager : HttpHandlerBase

@property (strong, nonatomic) NSString *privateUploadTokenUrl;
@property (strong, nonatomic) NSString *publicUploadTokenUrl;

+ (instancetype)sharedInstance;

- (AFHTTPRequestOperation*)getRequestOperationWith:(NSNumber*)studentId questionId:(NSNumber*)questionId;

- (void)uploadImage:(UIImage*)image userId:(NSString*)userid public:(BOOL)isPublic;
- (void)uploadDocFile:(NSString*)filePath userId:(NSString*)userid public:(BOOL)isPublic;
- (void)uploadAudioFile:(NSString*)filePath userId:(NSString*)userid public:(BOOL)isPublic;

- (AFHTTPRequestOperation*)uploadFile:(NSString*)filePath to:(NSString*)serverUrl;

- (void)pause:(NSNumber*)studentId questionId:(NSNumber*)questionId;
- (void)resume:(NSNumber*)studentId questionId:(NSNumber*)questionId;
- (void)cancelAllRequestOperation;

- (void)setPublicDownloadURL:(NSString*)url;

@end
