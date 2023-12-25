//
//  BDPanOpenPlatformTokenProcessor.h
//  BDPanOpenPlatformSDK
//
//  Created by luochao04 on 2022/7/6.
//

#import <Foundation/Foundation.h>
#import "BDPanOpenPlatformOauthResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 获取 access_token 回调
/// @param oauthResponse 获取access token信息
/// @param error 若 error 为 nil 说明获取成功，否则获取失败
typedef void(^BDPanAPaaSSDKFetchAccesTokenInfoBlock)(id<BDPanOpenPlatformOauthResponseProtocol> _Nullable oauthResponse, NSError *_Nullable error);

@interface BDPanOpenPlatformTokenProcessor : NSObject

/// 获取 access_token
/// @param oauthCode 通过百度 Oauth-SDK 认证后获取到的 code
/// @param appKey 网盘开放平台创建应用后生成的 appKey
/// @param secretKey 网盘开放平台创建应用后生成的 secretKey
/// @param redirectUri 网盘开放平台创建应用填入的 redirectUri
+ (NSUInteger)fetchAccessTokenWithOauthCode:(NSString *)oauthCode
                                     appKey:(NSString *)appKey
                                  secretKey:(NSString *)secretKey
                                redirectUri:(NSString *)redirectUri
                                 completion:(BDPanAPaaSSDKFetchAccesTokenInfoBlock)completion;


/// 刷新 access_token
/// @param appKey 网盘开放平台创建应用后生成的 appKey
/// @param secretKey 网盘开放平台创建应用后生成的 secretKey
/// @param refreshToken 获取/刷新 access_token 后返回的 refresh_token
+ (NSUInteger)refreshTokenWithAppKey:(NSString *)appKey
                           secretKey:(NSString *)secretKey
                        refreshToken:(NSString *)refreshToken
                          completion:(BDPanAPaaSSDKFetchAccesTokenInfoBlock)completion;

@end

NS_ASSUME_NONNULL_END
