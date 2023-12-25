//
//  BDPanSDKConfig.h
//  BDPanAPaaSSDK
//
//  Created by luochao04 on 2022/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BDPanSDKConfig : NSObject

/// 平台注册生成 - 必须设置
@property (nonatomic, assign) NSInteger appId;
/// 第三方用户身份唯一标识，需确保唯一性
@property (nonatomic, copy) NSString *userIdentifier;
/// 开放平台为 access token，调用 BDPanOpenPlatformTokenProcessor.fetchAccessTokenWithOauthCode 获取
@property (nonatomic, copy) NSString *spaceToken;

/// 是否打印日志，默认false - 可选设置
@property (nonatomic, assign) BOOL debugEnable;
/// 上传最大并发数 默认并发数2，最大为5 - 可选设置
@property (nonatomic, assign) NSInteger uploadConcurrentCount;
/// 上传最大文件数，包含文件夹内文件数，默认不限制 - 可选设置
@property (nonatomic, assign) NSInteger maxUploadFileCount;

@end

NS_ASSUME_NONNULL_END
