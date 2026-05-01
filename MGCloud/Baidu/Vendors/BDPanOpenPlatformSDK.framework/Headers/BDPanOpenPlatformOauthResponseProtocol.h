//
//  BDPanOpenPlatformOauthResponseProtocol.h
//  BDPanAPaaSSDK
//
//  Created by luochao04 on 2022/6/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BDPanOpenPlatformOauthResponseProtocol <NSObject>

/// 获取到的Access Token，Access Token是调用网盘开放API访问用户授权资源的凭证。
@property (nonatomic, copy) NSString *accessToken;
/// Access Token的有效期，单位为秒。
@property (nonatomic, assign) unsigned long long expiresIn;
/// 用于刷新 Access Token, 有效期为10年。
@property (nonatomic, copy) NSString *refreshToken;
/// Access Token 最终的访问权限，即用户的实际授权列表。
@property (nonatomic, copy) NSString *scope;

@end

NS_ASSUME_NONNULL_END
