//
//  APaaSSDK.h
//  APaaSLog
//
//  Created by luochao04 on 2022/3/30.
//

#import <Foundation/Foundation.h>
#import "BDPanSDKConfig.h"
#import "BDPanQuotaInfoProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 初始化 SDK 回调
/// @param error 若 error 为 nil 说明初始化成功，否则初始化失败
typedef void(^BDPanAPaaSSDKInitializeBlock)(NSError *_Nullable error);

/// spcaeToken/accessToken 失效回调
typedef void(^BDPanAPaaSSDKSpaceTokenInvalidBlock)(void);

/// 退出登录方法回调
typedef void(^BDPanAPaaSSDKLogoutBlock)(void);

/// 获取空间使用信息回调
/// @param quotaInfo 包含空间总大小和已使用大小
/// @param error 若 error 为 nil 说明初始化成功，否则初始化失败
typedef void(^BDPanAPaaSSDKFetchQuotaInfoBlock)(id<BDPanQuotaInfoProtocol> _Nullable quotaInfo, NSError *_Nullable error);

@interface BDPanAPaaSSDK : NSObject

/// SDK config
@property (nonatomic, strong, readonly) BDPanSDKConfig *sdkConfig;

/// SDK 是否初始化完成
@property (nonatomic, assign, readonly, getter=isInitializeComplete) BOOL initializeComplete;

/// spaceToken 失效回调，收到该回调后需调用 refreshSpaceTokenWith 刷新spaceToken
@property (nonatomic, copy) BDPanAPaaSSDKSpaceTokenInvalidBlock spaceTokenInvalidBlock;

+ (instancetype)sharedInstance;

#pragma mark - apaas渠道初始化
/// 初始化 SDK - apaas
/// @param sdkConfig SDK配置项
/// @param completion 初始化回调
- (void)initializeSDKWithConfig:(BDPanSDKConfig *)sdkConfig
                     completion:(BDPanAPaaSSDKInitializeBlock)completion;



#pragma mark - 网盘开放平台使用
/// 初始化 SDK - 网盘开放平台
/// @param sdkConfig SDK配置项
/// @param completion 初始化回调
- (void)initializeSDKForOpenPlatformWithConfig:(BDPanSDKConfig *)sdkConfig
                                    completion:(BDPanAPaaSSDKInitializeBlock)completion;

#pragma mark - common

/// 宿主账号退出登录时调用，宿主重新登录时需重新走初始化 SDK 逻辑
/// @param completion 回调
- (void)destroyAPaaSWithCompletion:(BDPanAPaaSSDKLogoutBlock)completion;

/// 根据 requestId 取消网络请求
- (void)cancelRequestWithTag:(NSUInteger)requestId;

/// 取消所有网络请求
- (void)cancelAllRequest;

/// aPaaS-SDK 版本号
- (NSString *)version;

/// 获取当前用户空间使用信息
/// @param completion 回调
- (void)fetchQuotaInfoWithCompletion:(BDPanAPaaSSDKFetchQuotaInfoBlock)completion;


@end

NS_ASSUME_NONNULL_END
