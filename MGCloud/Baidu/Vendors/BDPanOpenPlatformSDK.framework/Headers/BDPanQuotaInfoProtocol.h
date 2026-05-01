//
//  BDPanQuotaInfoProtocol.h
//  BDPanUploadSDK
//
//  Created by luochao04 on 2022/3/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BDPanQuotaInfoProtocol <NSObject>

/// 总空间-单位byte
@property (nonatomic, assign) long long totalSpace;
/// 已用空间-单位byte
@property (nonatomic, assign) long long usedSpace;


@end

NS_ASSUME_NONNULL_END
