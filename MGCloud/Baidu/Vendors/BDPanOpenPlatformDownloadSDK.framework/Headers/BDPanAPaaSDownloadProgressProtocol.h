//
//  BDPanAPaaSDownloadProgressProtocol.h
//  BDPanAPaaSSDK
//
//  Created by suyoulong on 2022/5/11.
//

#import <Foundation/Foundation.h>
#import "BDPanAPaaSDownloadBaseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BDPanAPaaSDownloadProgressProtocol <NSObject, BDPanAPaaSDownloadBaseProtocol>

/// 操作结果
@property (nonatomic, assign) int errCode;
/// 错误信息
@property (nonatomic, copy) NSString *errMsg;
/// 任务状态
@property (nonatomic, assign) BDPanAPaaSDownloadTaskStatus status;
/// 下载任务唯一标识、用于后续操作任务
@property (nonatomic, assign) int taskId;
/// file md5
@property (nonatomic, copy) NSString *fileMd5;
/// 文件唯一标识
@property (nonatomic, assign) unsigned long long fid;
/// 文件字节数
@property (nonatomic, assign) unsigned long long fileSize;
/// 文件已下载字节数
@property (nonatomic, assign) unsigned long long downloadedSize;
/// 下载速度，单位：字节每秒
@property (nonatomic, assign) int downloadSpeed;
/// 下载的本地路径，包含文件名的全路径，业务方负责保证多个用户的文件不发生冲突
@property (nonatomic, copy) NSString *localPath;
/// 扩展信息
@property (nonatomic, copy) NSString *extraInfo;
/// 任务创建时间
@property (nonatomic, strong) NSDate *downloadCTime;
/// 任务修改时间
@property (nonatomic, strong) NSDate *downloadMTime;

@end

NS_ASSUME_NONNULL_END
