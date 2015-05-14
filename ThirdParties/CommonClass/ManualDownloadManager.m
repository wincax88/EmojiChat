//
//  ManualDownloadManager.m
//  iTao
//
//  Created by michaelwong on 8/6/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "ManualDownloadManager.h"
#import "AFNetworking.h"
#import "YBUtility.h"
#import "ApplicationManager.h"

// http://tls.taomee.com/upload/get_download_url

#ifdef PUBLICTEST  // pre-distribution url

#define GET_DOWNLOAD_URL (@"http://test.api.yb1v1.com/upload/get_download_url")

#elif DISTRIBUTION      // distribution url

#define GET_DOWNLOAD_URL (@"http://api.yb1v1.com/upload/get_download_url")

#elif INNERTEST         // inner url

#define GET_DOWNLOAD_URL (@"http://api.weiyi.com/upload/get_download_url")

#else
#warning MUST define  PUBLICTEST or DISTRIBUTION or INNERTEST.
#endif

@interface ManualDownloadManager()
{
    NSMutableDictionary     *downloadTaskDic;
    NSMutableDictionary     *downloadPathDic;
}

@end
@implementation ManualDownloadManager

static ManualDownloadManager *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[ManualDownloadManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        downloadTaskDic = [[NSMutableDictionary alloc] init];
        downloadPathDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - public
- (void)download:(NSString*)fileURL toLoaclPath:(NSString*)localPath
{
    // check full path or short path
    NSArray *component = [fileURL pathComponents];
    if (component.count > 2) { // full path
        NSString *lastPath = [fileURL lastPathComponent];
        // 6336504d12c005abba42954bd19ee08e1420717605755.pdf?e=1422948619&token=yPmhHAZNeHlKndKBLvhwV3fw4pzNBVvGNU5ne6Px:U9lOzG7n4XASRQw9J1oE9X9frLQ=
        NSArray *subPaths = [lastPath componentsSeparatedByString:@"?"];
        if ([subPaths count] >= 1) {
            lastPath = [subPaths objectAtIndex:0];
        }
        NSString *fileName = [localPath stringByAppendingPathComponent:lastPath];
        if ([YBUtility fileExists:fileName]) {
            [self notifyDelegates:fileName selector:@selector(didManualDownloadSuccess:userData:) object:fileURL];
        }
        else {
            [self innerdownload:fileURL originUrl:fileURL toLoaclPath:localPath];
        }
    }
    else {
        [downloadPathDic setObject:localPath forKey:fileURL];
        [[ApplicationManager sharedManager].httpClientHandler registerDelegate:self];
        NSDictionary* param = @{@"file_url": [fileURL dataUsingEncoding:NSUTF8StringEncoding]};
        NSDictionary* userDic = @{@"origin_url": fileURL};
        [self requestDataWithParam:param url:GET_DOWNLOAD_URL userData:userDic toLoaclPath:localPath];
    }
}

#pragma mark - ApplicationManager delegate
- (void)didGetDownLoadUrlSuccess:(NSMutableDictionary*)dic {
    
    NSString* downloadUrl = [dic objectForKey:@"downloadUrl"];
    NSString* originUrl = [dic objectForKey:@"originUrl"];
    NSString* localPath = [downloadPathDic objectForKey:originUrl];
    [self innerdownload:downloadUrl originUrl:originUrl toLoaclPath:localPath];
}

- (void)didGetDownLoadUrlFailed:(NSMutableDictionary*)dic message:(NSString*)errorMessage {
    NSString* fileURL = [dic objectForKey:@"originUrl"];
    NSNumber* ret = [dic objectForKey:@"ret"];
    [self notifyDelegates:ret selector:@selector(didManualDownloadFailed:userData:) object:fileURL];
}

#pragma mark - private

- (NSURLSessionDownloadTask*)innerdownload:(NSString*)fileURL originUrl:(NSString*)originUrl toLoaclPath:(NSString*)localPath
{
    // check local storage
    NSString *lastPath = [fileURL lastPathComponent];
    // 6336504d12c005abba42954bd19ee08e1420717605755.pdf?e=1422948619&token=yPmhHAZNeHlKndKBLvhwV3fw4pzNBVvGNU5ne6Px:U9lOzG7n4XASRQw9J1oE9X9frLQ=
    NSArray *subPaths = [lastPath componentsSeparatedByString:@"?"];
    if ([subPaths count] >= 1) {
        lastPath = [subPaths objectAtIndex:0];
    }

    NSString* fileName = [localPath stringByAppendingPathComponent:lastPath];
    if ([YBUtility fileExists:fileName]) {
        [self notifyDelegates:[localPath stringByAppendingPathComponent:[originUrl lastPathComponent]] selector:@selector(didManualDownloadSuccess:userData:) object:originUrl];
        return nil;
    }
    if ([downloadTaskDic objectForKey:originUrl]) {
        return [downloadTaskDic objectForKey:originUrl];
    }

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    NSURL *URL = [NSURL URLWithString:[RESOURCE_DOWNLOAD_URL stringByAppendingString:fileURL]];
    NSURL *URL = [NSURL URLWithString:fileURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSString* extension = [URL pathExtension];
    
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        if ([localPath length] <= 0) {
            NSString *docPath = [YBUtility getCacheFolder4Document];
            NSURL *localPathRrl = [NSURL fileURLWithPath:docPath];
            return [localPathRrl URLByAppendingPathComponent:[response suggestedFilename]];
        }
        else {
            NSURL *localPathRrl = [NSURL fileURLWithPath:localPath];
            return [localPathRrl URLByAppendingPathComponent:[response suggestedFilename]];
        }
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [downloadTaskDic removeObjectForKey:originUrl];
        if (filePath && [[filePath pathExtension] isEqualToString:extension] && error == nil) {
            [weakSelf notifyDelegates:[filePath path]  selector:@selector(didManualDownloadSuccess:userData:) object:originUrl];
        }
        else if (error) {
            [weakSelf notifyDelegates:error selector:@selector(didManualDownloadFailed:userData:) object:originUrl];
        }
        else {
            NSParameterAssert(false);
        }
    }];
    [downloadTask resume];
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
#ifdef DEBUG

        NSLog(@"Progress… %lld", totalBytesWritten);
#endif
        NSDictionary *progressDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithLongLong:totalBytesWritten], @"totalBytesWritten",
                                     [NSNumber numberWithLongLong:totalBytesExpectedToWrite], @"totalBytesExpectedToWrite",
                                     nil];
        [weakSelf notifyDelegates:progressDic selector:@selector(onManualDownloadProgress:userData:) object:originUrl];
    }];
    [downloadTaskDic setObject:downloadTask forKey:originUrl];
    return downloadTask;
}

- (NSURLSessionDownloadTask*)getDownloadTaskWith:(NSString*)fileURL
{
    return [downloadTaskDic objectForKey:fileURL];
}

- (void)pause:(NSString*)fileURL
{
    NSURLSessionDownloadTask *task = [self getDownloadTaskWith:fileURL];
    if (task && task.state == NSURLSessionTaskStateRunning) {
        [task suspend];
    }
    else {
//        NSParameterAssert(false);
    }
}

- (void)resume:(NSString*)fileURL
{
    NSURLSessionDownloadTask *task = [self getDownloadTaskWith:fileURL];
    if (task && task.state == NSURLSessionTaskStateSuspended) {
        [task resume];
    }
    else {
//        NSParameterAssert(false);
    }
}

- (void)cancelAllDownloadTask
{
    for (AFHTTPRequestOperation *operation in [downloadTaskDic allValues]) {
        [operation cancel];
    }
    [downloadTaskDic removeAllObjects];
    [downloadPathDic removeAllObjects];
}

- (void)requestDataWithParam:(NSDictionary*)param url:(NSString*)urlString userData:(NSDictionary*)userData toLoaclPath:(NSString*)localPath {
    
    NSString* originUrl = [userData objectForKey:@"origin_url"];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:15.0f];
    __weak __typeof(self) weakSelf = self;
    
    [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (param) {
            for (NSString *key in param.allKeys) {
#ifdef DEBUG
                NSParameterAssert([[param objectForKey:key] isKindOfClass:[NSData class]]);
#endif
                [formData appendPartWithFormData:[param objectForKey:key] name:key];
            }
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // do default postprocess
        NSError *error = nil;
        id jsonObject = nil;
        if (responseObject)
        {
            jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject
                                                         options:kNilOptions
                                                           error:&error];
            if (jsonObject != nil && error == nil) {
                NSNumber *ret = [jsonObject objectForKey:@"ret"];
                // NSString *info = [jsonObject objectForKey:@"info"];
                if (ret.intValue == 0) {
                    NSString *download_url = [jsonObject objectForKey:@"download_url"];
                    [self innerdownload:download_url originUrl:originUrl toLoaclPath:localPath];
                }
                else {
                    [weakSelf notifyDelegates:error selector:@selector(didManualDownloadFailed:userData:) object:originUrl];
                }
                
            }
            else {
                [weakSelf notifyDelegates:error selector:@selector(didManualDownloadFailed:userData:) object:originUrl];
            }
        }
        else {
            [weakSelf notifyDelegates:error selector:@selector(didManualDownloadFailed:userData:) object:originUrl];
            NSParameterAssert(false);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG

        NSLog(@"Error: %@", error);
#endif
        [weakSelf notifyDelegates:error selector:@selector(didManualDownloadFailed:userData:) object:originUrl];
        
    }];
}

@end
