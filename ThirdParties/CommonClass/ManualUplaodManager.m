//
//  ManualUplaodManager.m
//  iTao
//
//  Created by michaelwong on 8/6/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "ManualUplaodManager.h"
#import "AFNetworking.h"
#import "MD5.h"
#import "YBUtility.h"

#ifdef PUBLICTEST  // pre-distribution url

#define GET_UPLOAD_TOKEN            @"http://test.api.yb1v1.com/upload/get_upload_token"
#define GET_PUBLIC_UPLOAD_TOKEN     @"http://test.api.yb1v1.com/upload/get_pub_upload_token" // 获取公共上传token

#elif DISTRIBUTION      // distribution url

#define GET_UPLOAD_TOKEN            @"http://api.yb1v1.com/upload/get_upload_token"
#define GET_PUBLIC_UPLOAD_TOKEN     @"http://api.yb1v1.com/upload/get_pub_upload_token" // 获取公共上传token

#elif INNERTEST         // inner url

#define GET_UPLOAD_TOKEN            @"http://api.weiyi.com/upload/get_upload_token" //
#define GET_PUBLIC_UPLOAD_TOKEN     @"http://api.weiyi.com/upload/get_pub_upload_token" // 获取公共上传token

#else
#warning MUST define  PUBLICTEST or DISTRIBUTION or INNERTEST.
#endif

#define UPLOAD_FILE_URL             @"http://upload.qiniu.com"
#define PUBLIC_DOWNLOAD_FILE_URL    @"http://ebtestpub.qiniudn.com/"

@interface ManualUplaodManager ()
{
    NSMutableDictionary     *operationDic;
    
    NSString                *publicDownloadUrl;
}

@end

@implementation ManualUplaodManager

static ManualUplaodManager *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[ManualUplaodManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        operationDic = [[NSMutableDictionary alloc] init];
        publicDownloadUrl = PUBLIC_DOWNLOAD_FILE_URL;
        
        _privateUploadTokenUrl = GET_UPLOAD_TOKEN;
        _publicUploadTokenUrl = GET_PUBLIC_UPLOAD_TOKEN;
    }
    return self;
}

- (void)setPublicDownloadURL:(NSString*)url
{
    if ([url length] > 0) {
        publicDownloadUrl = url;
    }
    else {
        NSParameterAssert([url length] > 0);
    }
}

- (void)uploadDocFile:(NSString*)filePath  userId:(NSString*)userid public:(BOOL)isPublic
{
    if (isPublic) {
        [self requestTokenFrom:_publicUploadTokenUrl docFile:filePath image:nil userId:userid public:isPublic];
    }
    else {
        [self requestTokenFrom:_privateUploadTokenUrl docFile:filePath image:nil userId:userid public:isPublic];
    }
}

- (void)uploadAudioFile:(NSString*)filePath userId:(NSString*)userid public:(BOOL)isPublic
{
    if (isPublic) {
        [self requestTokenFrom:_publicUploadTokenUrl audioFile:filePath image:nil userId:userid public:isPublic];
    }
    else {
        [self requestTokenFrom:_privateUploadTokenUrl audioFile:filePath image:nil userId:userid public:isPublic];
    }
}

- (void)uploadImage:(UIImage*)image  userId:(NSString*)userid public:(BOOL)isPublic
{
    if (isPublic) {
        [self requestTokenFrom:_publicUploadTokenUrl docFile:nil image:image userId:userid public:isPublic];
    }
    else {
        [self requestTokenFrom:_privateUploadTokenUrl docFile:nil image:image userId:userid public:isPublic];
    }
}

- (AFHTTPRequestOperation*)uploadFile:(NSString*)filePath to:(NSString*)serverUrl
{
    if (![YBUtility fileExists:filePath]) {
        NSParameterAssert(false);
        return nil;
    }
    
    if ([operationDic objectForKey:filePath]) {
        return [operationDic objectForKey:filePath];
    }
    
    NSString *fileName = [filePath lastPathComponent];
    NSData *docData = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:
                              filePath , @"docKey",
                              nil];
    // image/jpeg application/pdf
    NSString *mimeType = @"text/plain";
    // 1. Create `AFHTTPRequestSerializer` which will create your request.
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    // 2. Create an `NSMutableURLRequest`.  type="file" name="file" id="file"
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:serverUrl
                                    parameters:nil
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         [formData appendPartWithFileData:docData name:@"file" fileName:fileName mimeType:mimeType];
                     } error:nil];
    
    // 3. Create and use `AFHTTPRequestOperationManager` to create an `AFHTTPRequestOperation` from the `NSMutableURLRequest` that we just created.
    __weak __typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
#ifdef DEBUG
                                         
                                         NSLog(@"Success %@", responseObject);
#endif
                                         [operationDic removeObjectForKey:filePath];
                                         
                                         [weakSelf notifyDelegates:userData selector:@selector(didManualUploadSuccess:)];
                                         
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
                                         
                                         NSLog(@"Failure %@", error.description);
#endif
                                         [operationDic removeObjectForKey:filePath];
                                         
                                         [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
                                     }];
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSDictionary *progressDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithLongLong:totalBytesWritten], @"totalBytesWritten",
                                     [NSNumber numberWithLongLong:totalBytesExpectedToWrite], @"totalBytesExpectedToWrite",
                                     nil];
        [weakSelf notifyDelegates:progressDic selector:@selector(onManualUploadProgress:userData:) object:userData];
    }];
    operation.userInfo = userData;
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    // 5. Begin!
    [operation start];
    
    [operationDic setObject:operation forKey:filePath];
    return operation;
}

#pragma mark - private

- (AFHTTPRequestOperation*)innerUploadDocFile:(NSString*)filePath token:(NSString*)uploadToken userId:(NSString*)userid public:(BOOL)isPublic
{
    if (![YBUtility fileExists:filePath]) {
        NSParameterAssert(false);
        return nil;
    }
    if ([operationDic objectForKey:filePath])
    {
        return [operationDic objectForKey:filePath];
    }
    NSString *fileName = [filePath lastPathComponent];
    NSString *key = fileName;
    if ([userid length] > 0) {
        key = [NSString stringWithFormat:@"%@_%@.%@", [fileName stringByDeletingPathExtension], userid, [fileName pathExtension]];
    }
    NSData *docData = [[filePath pathExtension] isEqualToString:@"pdf"] ? [NSData dataWithContentsOfFile:filePath] : UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:filePath], 0.7f);
    NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:
                              filePath , @"docKey",
                              nil];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [uploadToken dataUsingEncoding:NSUTF8StringEncoding] , @"token",
                                [key dataUsingEncoding:NSUTF8StringEncoding] , @"key",
                                nil];
    // image/jpeg application/pdf
    NSString *mimeType = [[filePath pathExtension] isEqualToString:@"pdf"] ? @"application/pdf" : @"image/jpeg";
    // 1. Create `AFHTTPRequestSerializer` which will create your request.
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    // 2. Create an `NSMutableURLRequest`.  type="file" name="file" id="file"
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:UPLOAD_FILE_URL
                                    parameters:parameters
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         [formData appendPartWithFileData:docData name:@"file" fileName:fileName mimeType:mimeType];
                     } error:nil];
    
    // 3. Create and use `AFHTTPRequestOperationManager` to create an `AFHTTPRequestOperation` from the `NSMutableURLRequest` that we just created.
    __weak __typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
#ifdef DEBUG

                                         NSLog(@"Success %@", responseObject);
#endif
                                         [operationDic removeObjectForKey:filePath];
                                         
                                         NSString *docUrl = @"";
                                         docUrl = [responseObject objectForKey:@"key"];
                                         if (isPublic) {
                                             docUrl = [NSString stringWithFormat:@"%@%@", publicDownloadUrl, docUrl];
                                         }

                                         // @"http://s21.postimg.org/xymh35zsn/201083121505316956.jpg"
                                         NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                               docUrl , @"docUrl",
                                                               filePath , @"docKey",
                                                               nil];
                                         [weakSelf notifyDelegates:dict selector:@selector(didManualUploadSuccess:)];
                                         
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG

                                         NSLog(@"Failure %@", error.description);
#endif
                                         [operationDic removeObjectForKey:filePath];
                                         
                                         [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
                                     }];
    
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSDictionary *progressDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithLongLong:totalBytesWritten], @"totalBytesWritten",
                                     [NSNumber numberWithLongLong:totalBytesExpectedToWrite], @"totalBytesExpectedToWrite",
                                     nil];
        [weakSelf notifyDelegates:progressDic selector:@selector(onManualUploadProgress:userData:) object:userData];
    }];
    operation.userInfo = userData;
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    // 5. Begin!
    [operation start];
    
    [operationDic setObject:operation forKey:filePath];
    return operation;
}

- (AFHTTPRequestOperation*)innerUploadAudioFile:(NSString*)filePath token:(NSString*)uploadToken userId:(NSString*)userid public:(BOOL)isPublic
{
    if (![YBUtility fileExists:filePath]) {
        NSParameterAssert(false);
        return nil;
    }
    if ([operationDic objectForKey:filePath])
    {
        return [operationDic objectForKey:filePath];
    }
    NSString *fileName = [filePath lastPathComponent];
    NSString *key = fileName;
    if ([userid length] > 0) {
        key = [NSString stringWithFormat:@"%@_%@.%@", [fileName stringByDeletingPathExtension], userid, [fileName pathExtension]];
    }
    NSData *docData = [[filePath pathExtension] isEqualToString:@"wav"] ? [NSData dataWithContentsOfFile:filePath] : UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:filePath], 0.7f);
    NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:
                              filePath , @"docKey",
                              nil];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [uploadToken dataUsingEncoding:NSUTF8StringEncoding] , @"token",
                                [key dataUsingEncoding:NSUTF8StringEncoding] , @"key",
                                nil];
    // image/jpeg application/pdf
    NSString *mimeType = [[filePath pathExtension] isEqualToString:@"wav"] ? @"audio/wav" : @"image/jpeg";
    // 1. Create `AFHTTPRequestSerializer` which will create your request.
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    // 2. Create an `NSMutableURLRequest`.  type="file" name="file" id="file"
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:UPLOAD_FILE_URL
                                    parameters:parameters
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         [formData appendPartWithFileData:docData name:@"file" fileName:fileName mimeType:mimeType];
                     } error:nil];
    
    // 3. Create and use `AFHTTPRequestOperationManager` to create an `AFHTTPRequestOperation` from the `NSMutableURLRequest` that we just created.
    __weak __typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
#ifdef DEBUG
                                         
                                         NSLog(@"Success %@", responseObject);
#endif
                                         [operationDic removeObjectForKey:filePath];
                                         
                                         NSString *docUrl = @"";
                                         docUrl = [responseObject objectForKey:@"key"];
                                         if (isPublic) {
                                             docUrl = [NSString stringWithFormat:@"%@%@", publicDownloadUrl, docUrl];
                                         }
                                         
                                         // @"http://s21.postimg.org/xymh35zsn/201083121505316956.jpg"
                                         NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                               docUrl , @"docUrl",
                                                               filePath , @"docKey",
                                                               nil];
                                         [weakSelf notifyDelegates:dict selector:@selector(didManualUploadSuccess:)];
                                         
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
                                         
                                         NSLog(@"Failure %@", error.description);
#endif
                                         [operationDic removeObjectForKey:filePath];
                                         
                                         [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
                                     }];
    
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSDictionary *progressDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithLongLong:totalBytesWritten], @"totalBytesWritten",
                                     [NSNumber numberWithLongLong:totalBytesExpectedToWrite], @"totalBytesExpectedToWrite",
                                     nil];
        [weakSelf notifyDelegates:progressDic selector:@selector(onManualUploadProgress:userData:) object:userData];
    }];
    operation.userInfo = userData;
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    // 5. Begin!
    [operation start];
    
    [operationDic setObject:operation forKey:filePath];
    return operation;
}

- (AFHTTPRequestOperation*)innerUploadImageData:(NSData*)imaegData imageKey:(NSString*)imageKey token:(NSString*)uploadToken userId:(NSString*)userid public:(BOOL)isPublic
{
    if (!imaegData) {
        NSParameterAssert(false);
        return nil;
    }
    
    if ([operationDic objectForKey:imageKey])
    {
        return [operationDic objectForKey:imageKey];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.png", [[NSUUID UUID] UUIDString], userid];
    
    NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:
                              imageKey , @"imageKey",
                              nil];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [uploadToken dataUsingEncoding:NSUTF8StringEncoding] , @"token",
                                [fileName dataUsingEncoding:NSUTF8StringEncoding] , @"key",
                              nil];
    // 1. Create `AFHTTPRequestSerializer` which will create your request.
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    // 2. Create an `NSMutableURLRequest`.  type="file" name="file" id="file"
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:UPLOAD_FILE_URL
                                    parameters:parameters
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         [formData appendPartWithFileData:imaegData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
                     } error:nil];
    
    // 3. Create and use `AFHTTPRequestOperationManager` to create an `AFHTTPRequestOperation` from the `NSMutableURLRequest` that we just created.
    __weak __typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
#ifdef DEBUG

                                         NSLog(@"Success %@", responseObject);
#endif
                                         [operationDic removeObjectForKey:imageKey];
                                         
                                         NSString *imageUrl = @"";
                                         imageUrl = [responseObject objectForKey:@"key"];
                                         if (isPublic) {
                                             imageUrl = [NSString stringWithFormat:@"%@%@", publicDownloadUrl, imageUrl];
                                         }
                                         // @"http://s21.postimg.org/xymh35zsn/201083121505316956.jpg"
                                         NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                               imageUrl , @"imageURL",
                                                               imageKey , @"imageKey",
                                                               nil];
                                         [weakSelf notifyDelegates:dict selector:@selector(didManualUploadSuccess:)];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG

                                         NSLog(@"Failure %@", error.description);
#endif
                                         
                                         [operationDic removeObjectForKey:imageKey];
                                         
                                         [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
                                     }];
    
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSDictionary *progressDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithLongLong:totalBytesWritten], @"totalBytesWritten",
                                     [NSNumber numberWithLongLong:totalBytesExpectedToWrite], @"totalBytesExpectedToWrite",
                                     nil];
        [weakSelf notifyDelegates:progressDic selector:@selector(onManualUploadProgress:userData:) object:userData];
    }];
    operation.userInfo = userData;
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    // 5. Begin!
    [operation start];
    
    [operationDic setObject:operation forKey:imageKey];
    return operation;
}
- (AFHTTPRequestOperation*)getRequestOperationWith:(NSNumber*)studentId questionId:(NSNumber*)questionId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", studentId, questionId];
    return [operationDic objectForKey:key];
}

- (void)pause:(NSNumber*)studentId questionId:(NSNumber*)questionId
{
    AFHTTPRequestOperation* operation = [self getRequestOperationWith:studentId questionId:questionId];
    if (operation) {
        [operation pause];
    }
    else {
        NSParameterAssert(false);
    }
}
- (void)resume:(NSNumber*)studentId questionId:(NSNumber*)questionId
{
    AFHTTPRequestOperation* operation = [self getRequestOperationWith:studentId questionId:questionId];
    if (operation && [operation isPaused]) {
        [operation resume];
    }
    else {
        NSParameterAssert(false);
    }
}

- (void)cancelAllRequestOperation
{
    for (AFHTTPRequestOperation* operation in [operationDic allValues]) {
        [operation cancel];
    }
    [operationDic removeAllObjects];
}

- (void)requestTokenFrom:(NSString*)urlString audioFile:(NSString*)audioFile image:(UIImage*)image userId:(NSString*)userid public:(BOOL)isPublic {
    
    NSDictionary *userData;
    NSData *imaegData;
    NSString *imageKey;
    NSString *key = @"";
    NSDictionary *parameters;
    
    if (audioFile) {
        userData = [NSDictionary dictionaryWithObjectsAndKeys:
                    audioFile , @"docKey",
                    nil];
        NSString *fileName = [audioFile lastPathComponent];
        if ([userid length] > 0) {
            key = [NSString stringWithFormat:@"%@_%@.%@", [fileName stringByDeletingPathExtension], userid, [fileName pathExtension]];
        }
        else {
            key = fileName;
        }
        parameters = @{@"file_name":key};
    }
    else if (image) {
        imaegData = UIImagePNGRepresentation(image);
        imageKey = [MD5 md5NSData:imaegData];
        userData = [NSDictionary dictionaryWithObjectsAndKeys:
                    imageKey , @"imageKey",
                    nil];
    }
    else {
        NSParameterAssert(false);
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:15.0f];
    __weak __typeof(self) weakSelf = self;
    
    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
                if (ret.intValue == 0) {
                    NSString *upload_token = [jsonObject objectForKey:@"upload_token"];
                    if (image) {
                        [weakSelf innerUploadImageData:imaegData imageKey:imageKey token:upload_token userId:userid public:isPublic];
                    }
                    else if (audioFile) {
                        [weakSelf innerUploadAudioFile:audioFile token:upload_token userId:userid public:isPublic];
                    }
                    else {
                        [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
                        NSParameterAssert(false);
                    }
                }
                else {
                    [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
                    //                    NSParameterAssert(false);
                }
            }
            else {
                [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
            }
        }
        else {
            [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
            NSParameterAssert(false);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
        
        NSLog(@"Error: %@", error);
#endif
        [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
        
    }];
}

- (void)requestTokenFrom:(NSString*)urlString docFile:(NSString*)docFile image:(UIImage*)image userId:(NSString*)userid public:(BOOL)isPublic {
    
    NSDictionary *userData;
    NSData *imaegData;
    NSString *imageKey;
    NSString *key = @"";
    NSDictionary *parameters;
    
    if (docFile) {
        userData = [NSDictionary dictionaryWithObjectsAndKeys:
                    docFile , @"docKey",
                    nil];
        NSString *fileName = [docFile lastPathComponent];
        if ([userid length] > 0) {
            key = [NSString stringWithFormat:@"%@_%@.%@", [fileName stringByDeletingPathExtension], userid, [fileName pathExtension]];
        }
        else {
            key = fileName;
        }
        parameters = @{@"file_name":key};
    }
    else if (image) {
        imaegData = UIImagePNGRepresentation(image);
        imageKey = [MD5 md5NSData:imaegData];
        userData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  imageKey , @"imageKey",
                                  nil];
    }
    else {
        NSParameterAssert(false);
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:15.0f];
    __weak __typeof(self) weakSelf = self;
    
    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
                if (ret.intValue == 0) {
                    NSString *upload_token = [jsonObject objectForKey:@"upload_token"];
                    if (image) {
                        [weakSelf innerUploadImageData:imaegData imageKey:imageKey token:upload_token userId:userid public:isPublic];
                    }
                    else if (docFile) {
                        [weakSelf innerUploadDocFile:docFile token:upload_token userId:userid public:isPublic];
                    }
                    else {
                        [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
                        NSParameterAssert(false);
                    }
                }
                else {
                    [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
//                    NSParameterAssert(false);
                }
            }
            else {
                [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
            }
        }
        else {
            [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
            NSParameterAssert(false);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG

        NSLog(@"Error: %@", error);
#endif
        [weakSelf notifyDelegates:error selector:@selector(didManualUploadFailed:userData:) object:userData];
        
    }];
}

@end
