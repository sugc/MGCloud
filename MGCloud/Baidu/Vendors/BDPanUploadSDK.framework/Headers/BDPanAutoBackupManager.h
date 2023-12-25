//
//  BDPanAutoBackupManager.h
//  BDPanUploadSDK
//
//  Created by luochao04 on 2022/11/25.
//

#import <Foundation/Foundation.h>
#import "BDPanUploadSDKDefines.h"
#import "BDPanAutoBackupManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// 回调
/// error - 报错信息，为 nil 则为操作成功
typedef void(^BDPanBackupOperationCompletion)(NSError *_Nullable);

/// 当前备份信息的Block success, 标识是否获取成功  error 具体错误码
/// 获取成功信息包含: 本次备份状态、备份总数量、已备份数量
typedef void(^BDPanAutoBackupInfoBlock)(NSError * _Nullable error, BDPanAutoBackupState status, NSInteger totalCount, NSInteger uploadedCount);

@interface BDPanAutoBackupManager : NSObject

+ (instancetype)sharedInstance;

/// 设置备份开关(内部持久化)
/// @param enable 开关状态
/// @param backupType 备份类型
/// @param localDirs 本地沙盒文件夹 list，
/// 文档类型时须传此参数；
/// 图片/视频类型如不传入，备份相册；若传入，则备份传入文件夹(图片/视频)&相册
/// @param completion 回调 (包括结果，error 信息)
- (void)setAutoBackupEnable:(BOOL)enable
                 backupType:(BDPanAutoBackupType)backupType
                  localDirs:(NSArray<NSString *> *_Nullable)localDirs
                 serverPath:(NSString *)serverPath
                 completion:(__nullable BDPanBackupOperationCompletion)completion;


/// 设置文档备份支持类型 不设置默认全部支持 (pdf&word&ppt&excel&txt)
/// @param supportType 支持类型
/// @param completion 回调
- (void)setDocumentBackupSupportType:(BDPanDocumentBackupType)supportType
                          completion:(BDPanBackupOperationCompletion)completion;

/// 获取备份开关
/// @param backupType 备份类型
- (BOOL)autoBackupenableWithType:(BDPanAutoBackupType)backupType;


/// 移动网络备份开关
- (BOOL)cellularBackupEnable;

/// 设置移动网络是否允许备份 - 默认不允许
/// - Parameters:
///   - enable: YES - 允许备份
///   - completion: 回调
- (void)setCellularBackupEnable:(BOOL)enable
                     completion:(BDPanBackupOperationCompletion)completion;

/// 设置重名文件策略 - 默认(BDPanUploadDuplicatePolicyRenameAppendNumber)
/// - Parameters:
///   - dupPolicy: 重名文件策略
///   - completion: 回调
- (void)setFileDupPolicy:(BDPanUploadDuplicatePolicy)dupPolicy
              completion:(BDPanBackupOperationCompletion)completion;

/// 自动备份状态
- (BDPanAutoBackupState)autoBackupStatus;

/// 打开相册监听
/// @param changeObserve 监听状态 YES - 打开 
/// @param completion 回调
- (void)setAutoBackupPhotoLibraryChangeObserve:(BOOL)changeObserve
                                    completion:(__nullable BDPanBackupOperationCompletion)completion;

/// 获取备份信息，状态&数量
/// @param completion 回调
- (void)fetchUploadAutoBackupInfoWithCompletion:(BDPanAutoBackupInfoBlock)completion;

#pragma mark - backup control

/// 开始备份
/// @param completion 回调 (包括结果，error 信息)
- (void)startAutoBackup:(__nullable BDPanBackupOperationCompletion)completion;

/// 暂停备份
/// @param completion 回调 (包括结果，error 信息)
- (void)pauseAutoBackup:(__nullable BDPanBackupOperationCompletion)completion;

/// 恢复备份
/// @param completion 回调 (包括结果，error 信息)
- (void)resumeAutoBackup:(__nullable BDPanBackupOperationCompletion)completion;

/// 停止备份(清空队列任务)
/// @param completion 回调 (包括结果，error 信息)
- (void)stopAutoBackup:(__nullable BDPanBackupOperationCompletion)completion;

#pragma mark - 注册 & 反注册代理

/// 注册代理类，默认主线程回调，可注册多个
/// @param delegate 代理实现类
- (void)registerDelegate:(id<BDPanAutoBackupManagerDelegate>)delegate;

/// 反注册代理类
/// @param delegate 代理实现类
- (void)unregisterDelegate:(id<BDPanAutoBackupManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
