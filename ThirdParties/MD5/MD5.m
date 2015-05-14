//
//  MD5.h
//
//  Created by andychen on 13-11-9.
//  Copyright (c) 2013年 andychen . All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "MD5.h"

@interface MD5 ()

+ (NSString *)makeMd5:(NSString *)str;

@end

@implementation MD5

+ (NSString *)makeMd5:(NSString *)str
{
    if ([str length] == 0) {
        return str;
    }
    const char *value = [str UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    [outputString appendFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
     outputBuffer[0],  outputBuffer[1],  outputBuffer[2],  outputBuffer[3],
     outputBuffer[4],  outputBuffer[5],  outputBuffer[6],  outputBuffer[7],
     outputBuffer[8],  outputBuffer[9],  outputBuffer[10], outputBuffer[11],
     outputBuffer[12], outputBuffer[13], outputBuffer[14], outputBuffer[15]];
    
    return outputString;
}

+ (NSString *)md5WithoutKey:(NSString *)plainString
{
    NSString *ret = [self makeMd5:plainString];
    return ret;
}

+ (NSString *)md5WithKey:(const char *)key string:(NSString *)plainString
{
    NSString *keyString = [NSString stringWithCString:key encoding:NSUTF8StringEncoding];
    NSString *strToHash = [NSString stringWithFormat:@"%@&key=%@", plainString, keyString];
    
    return [self makeMd5:strToHash];
}

+ (NSString *)md5:(NSString *)plainString
{
    char *key = malloc(36);
    
    key[0] = '2';
    key[1] = '1';
    key[2] = 'e';
    key[3] = 'e';
    
    key[4] = '5';
    key[5] = 'e';
    key[6] = '1';
    key[7] = 'd';
    
    key[8] = '8';
    key[9] = 'b';
    key[10] = 'f';
    key[11] = '7';
    
    key[12] = '8';
    key[13] = '1';
    key[14] = '5';
    key[15] = '7';
    
    key[16] = '6';
    key[17] = '7';
    key[18] = '5';
    key[19] = '4';
    
    key[20] = 'b';
    key[21] = 'e';
    key[22] = '7';
    key[23] = '0';
    
    key[24] = '9';
    key[25] = '3';
    key[26] = '0';
    key[27] = '1';
    
    key[28] = 'f';
    key[29] = 'f';
    key[30] = 'e';
    key[31] = '9';
    
    key[32] = '\0';
    
    NSString *ret = [self md5WithKey:key string:plainString];
    free(key);
    
    return ret;
}

+ (NSString *)md5DeviceToken:(NSString *)deviceToken
{
    char *token_key_md5_key = (char *)calloc(7, sizeof(char));
    token_key_md5_key[0] = 'T';
    token_key_md5_key[1] = '1';
    token_key_md5_key[2] = '#';
    token_key_md5_key[3] = 'L';
    token_key_md5_key[4] = 's';
    token_key_md5_key[5] = '@';
    token_key_md5_key[6] = '\0';
    
    NSString *md5DeviceToken = [MD5 md5WithKey:token_key_md5_key string:deviceToken];
    free(token_key_md5_key);
    
    return md5DeviceToken;
}

+ (NSString *)md5NSData:(NSData*)data {
    if ([data length] <= 0) {
        NSParameterAssert(false);
        return nil;
    }
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(data.bytes, (unsigned int)data.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end
