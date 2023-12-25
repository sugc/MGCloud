//
//  BDPanAPaaSDownloadBaseProtocol.h
//  BDPanAPaaSSDK
//
//  Created by suyoulong on 2022/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BDPanAPaaSDownloadBaseProtocol <NSObject>

/// 下载任务状态
typedef NS_ENUM(NSInteger, BDPanAPaaSDownloadTaskStatus) {
    BDPanAPaaSDownloadTaskStatusInit = 1,
    BDPanAPaaSDownloadTaskStatusWait = 2,
    BDPanAPaaSDownloadTaskStatusRunning = 3,
    BDPanAPaaSDownloadTaskStatusStop = 5,
    BDPanAPaaSDownloadTaskStatusError = 6,
    BDPanAPaaSDownloadTaskStatusComplete = 8,
    BDPanAPaaSDownloadTaskStatusAll = 9,
};

/// 下载配置参数key
typedef NS_ENUM(NSInteger, BDPanAPaaSDownloadParameterKey) {
    BDPanAPaaSDownloadParameterDataPathKey = 7,
};

@end

NS_ASSUME_NONNULL_END
