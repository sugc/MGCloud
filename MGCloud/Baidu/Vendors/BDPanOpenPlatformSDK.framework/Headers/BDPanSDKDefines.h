//
//  BDPanSDKDefines.h
//  BDPanAPaaSSDK
//
//  Created by luochao04 on 2022/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const BDPanSDKErrorDomain = @"com.bdpan.netdisk.BDPanSDKErrorDomain";

// 错误枚举定义
typedef NS_ENUM(NSUInteger, BDPanSDKErrorCode) {
    BDPanSDKErrorCodeUnknow = 0,                     // 未知错误
    BDPanSDKErrorAPIInvalid = 1,                     // API 废弃
    BDPanSDKErrorCodeNoAccount = 2001,               // 当前未初始化
    BDPanSDKErrorCodeParamsError = 4001,             // 参数错误
    BDPanSDKErrorCodeOverSizeLimitError = 4002,      // 参数错误
    BDPanSDKErrorCodeNoBundle = 4004,                // SDK 依赖资源文件缺失
    BDPanSDKErrorSpaceTokenInvalid = 10104,          // 当前spacetoken失效
};

@interface BDPanSDKDefines : NSObject

+ (NSError *)errorWith:(BDPanSDKErrorCode)errorCode;

+ (NSError *)errorWithCode:(NSInteger)code errMsg:(NSString *)errMsg;

@end

NS_ASSUME_NONNULL_END
