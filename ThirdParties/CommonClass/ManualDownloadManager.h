//
//  ManualDownloadManager.h
//  iTao
//
//  Created by michaelwong on 8/6/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpHandlerBase.h"

@class AFHTTPRequestOperation;

@protocol ManualDownloadManagerDelegate <NSObject>

@optional

- (void)onManualDownloadProgress:(NSDictionary*)progressDic userData:(NSString*)userData;
- (void)didManualDownloadSuccess:(NSString*)localPath userData:(NSString*)userData;
- (void)didManualDownloadFailed:(NSError*)error userData:(NSString*)userData;

@end

@interface ManualDownloadManager : HttpHandlerBase

+ (instancetype)sharedInstance;

- (void)download:(NSString*)fileURL toLoaclPath:(NSString*)localPath;
- (void)pause:(NSString*)fileURL;
- (void)resume:(NSString*)fileURL;
- (void)cancelAllDownloadTask;

@end
