//
//  WISenseTimeHelper.m
//  ImageSDK
//
//  Created by robbie on 2017/3/21.
//  Copyright © 2017年 weibo. All rights reserved.
//

#import "WISenseTimeHelper.h"

#import <CommonCrypto/CommonDigest.h>
#import "st_mobile_license.h"

NS_ASSUME_NONNULL_BEGIN

@implementation WISenseTimeHelper

+ (NSString *)getSHA1StringWithData:(NSData *)data
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *strSHA1 = [NSMutableString string];
    
    for (int i = 0 ; i < CC_SHA1_DIGEST_LENGTH ; i ++)
    {
        [strSHA1 appendFormat:@"%02x" , digest[i]];
    }
    
    return strSHA1;
}

+ (BOOL)checkActiveCode
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"WeiboImageSDK" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *strLicensePath = [sourceBundle pathForResource:@"SENSEME" ofType:@"lic"];
    NSData *dataLicense = [NSData dataWithContentsOfFile:strLicensePath];
    
    NSString *strKeySHA1 = @"SENSEME";
    NSString *strKeyActiveCode = @"ACTIVE_CODE";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *strStoredSHA1 = [userDefaults objectForKey:strKeySHA1];
    NSString *strLicenseSHA1 = [self getSHA1StringWithData:dataLicense];
    
    st_result_t iRet = ST_OK;
    
    if (strStoredSHA1.length > 0 && [strLicenseSHA1 isEqualToString:strStoredSHA1])
    {
        
        // Get current active code
        // In this app active code was stored in NSUserDefaults
        // It also can be stored in other places
        NSData *activeCodeData = [userDefaults objectForKey:strKeyActiveCode];
        
        // Check if current active code is available
#if CHECK_LICENSE_WITH_PATH
        
        // use file
        iRet = st_mobile_check_activecode(
                                          strLicensePath.UTF8String,
                                          (const char *)[activeCodeData bytes],
                                          (int)[activeCodeData length]
                                          );
        
#else
        
        // use buffer
        NSData *licenseData = [NSData dataWithContentsOfFile:strLicensePath];
        
        iRet = st_mobile_check_activecode_from_buffer(
                                                      [licenseData bytes],
                                                      (int)[licenseData length],
                                                      [activeCodeData bytes],
                                                      (int)[activeCodeData length]
                                                      );
#endif
        
        if (ST_OK == iRet)
        {
            // check success
            return YES;
        }
    }
    
    /*
     1. check fail
     2. new one
     3. update
     */
    
    char active_code[1024];
    int active_code_len = 1024;
    
    // generate one
#if CHECK_LICENSE_WITH_PATH
    
    // use file
    iRet = st_mobile_generate_activecode(
                                         strLicensePath.UTF8String,
                                         active_code,
                                         &active_code_len
                                         );
    
#else
    
    // use buffer
    NSData *licenseData = [NSData dataWithContentsOfFile:strLicensePath];
    
    iRet = st_mobile_generate_activecode_from_buffer(
                                                     [licenseData bytes],
                                                     (int)[licenseData length],
                                                     active_code,
                                                     &active_code_len
                                                     );
#endif
    
    if (ST_OK != iRet) {
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"使用 license 文件生成激活码时失败，可能是授权文件过期。" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
//
//        [alert show];
        
        return NO;
        
    }
    else
    {
        // Store active code
        NSData *activeCodeData = [NSData dataWithBytes:active_code length:active_code_len];
        
        [userDefaults setObject:activeCodeData forKey:strKeyActiveCode];
        [userDefaults setObject:strLicenseSHA1 forKey:strKeySHA1];
        
        [userDefaults synchronize];
    }
    
    return YES;
}

@end

NS_ASSUME_NONNULL_END
