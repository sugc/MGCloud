//
//  BDPanAPaaSDownloadManager.h
//  BDPanAPaaSSDK
//
//  Created by suyoulong on 2022/5/11.
//

#import <Foundation/Foundation.h>
#import "BDPanAPaaSDownloadCreateInfo.h"
#import "BDPanAPaaSDownloadProgressProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BDPanAPaaSCreateDownloadTaskBlock)(int taskId, BOOL isSucceed);

typedef void(^BDPanAPaaSOperationMultiTaskBlock)(int succeedCount, NSArray<NSDictionary *> *taskResult);

/// 创建下载任务回调
/// @param taskId 创建任务生成的id，唯一标识该任务
/// @param error 若 error 为 nil 说明任务创建成功，否则任务创建失败
typedef void(^BDPanCreateDownloadTaskBlock)(int taskId, NSError *_Nullable error);

/// 下载任务状态&进度回调
/// @param progressInfo 任务状态信息，包含进度&状态&速度&taskid
/// @param error 若 error 不为 nil 说明出错
typedef void(^BDPanDownloadFileBlock)(id<BDPanAPaaSDownloadProgressProtocol> _Nullable progressInfo, NSError *_Nullable error);

/// 下载任务查询回调
/// @param taskList 任务 list
/// @param error 若 error 不为 nil 说明出错
typedef void(^BDPanDownloadTaskQueryBlock)(NSArray<id<BDPanAPaaSDownloadProgressProtocol>> *_Nullable taskList, NSError *_Nullable error);

@interface BDPanAPaaSDownloadManager : NSObject

+ (instancetype)sharedInstance;
   
/// 初始化下载
/// @return 是否成功
- (BOOL)initDownloadSDK;

/// 清理下载
/// @return 是否成功
- (BOOL)cleanDownloadSDK;

/// 设置初始化下载前的各种全局参数：APP_ID、APP_DATA_PATH
/// @param object 参数object
/// @param key 参数key
/// @return 是否成功
- (BOOL)setDownloadParameter:(NSString *)object
                      forKey:(BDPanAPaaSDownloadParameterKey)key;

/// 创建下载任务
/// @param createInfo 创建信息
/// @param resultBlock 结果回调
- (void)createDownloadTask:(BDPanAPaaSDownloadCreateInfo *)createInfo
               resultBlock:(BDPanAPaaSCreateDownloadTaskBlock)resultBlock NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，请使用createDownloadTask:completion方法.");

/// 创建下载任务
/// @param createInfo 创建信息
/// @param completion 结果回调
- (void)createDownloadTask:(BDPanAPaaSDownloadCreateInfo *)createInfo
               completion:(BDPanCreateDownloadTaskBlock)completion;

/// 启动/恢复单个下载任务
/// @param taskId 任务id
/// @return 是否成功
- (BOOL)startDownloadTask:(int)taskId NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，请使用startDownloadTask:completion方法.");

/// 启动/恢复单个下载任务
/// @param taskId 创建任务生成 taskId
/// @param completion 回调，进度&速度&状态
- (void)startDownloadTask:(int)taskId
               completion:(BDPanDownloadFileBlock)completion;

/// 启动/恢复所有status状态的下载任务
/// @param status 状态
/// @param resultBlock 结果回调
- (void)startAllDownloadTask:(BDPanAPaaSDownloadTaskStatus)status
                 resultBlock:(BDPanAPaaSOperationMultiTaskBlock)resultBlock NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，请使用 startAllDownloadTask:completion 方法.");

/// 启动/恢复所有status状态的下载任务
/// @param status 状态
/// @param completion 结果回调 进度&速度&状态
- (void)startAllDownloadTask:(BDPanAPaaSDownloadTaskStatus)status
                 completion:(BDPanDownloadFileBlock)completion;

/// 获取单个下载任务进度
/// @param taskId 任务id
/// @return 进度信息
- (id<BDPanAPaaSDownloadProgressProtocol>)getDownloadTaskProgressInfo:(int)taskId NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，请使用 getDownloadTaskProgressInfo:completion 方法.");

/// 根据 taskid 获取任务进度信息
/// @param taskId 创建任务生成 taskId
/// @param completion 回调，进度&速度&状态 信息，主动回调，外不调用无需轮询
- (void)getDownloadTaskProgressInfo:(int)taskId
                         completion:(BDPanDownloadFileBlock)completion;


/// 获取status状态的下载任务进度
/// @param status 状态
/// @return 进度信息的数组
- (NSArray<id<BDPanAPaaSDownloadProgressProtocol>> *)getMultiDownloadTaskProgressInfos:(BDPanAPaaSDownloadTaskStatus)status;

/// 暂停单个下载任务
/// @param taskId 任务id
/// @return 是否成功
- (BOOL)stopDownloadTask:(int)taskId;

/// 暂停所有status状态的下载任务
/// @param status 状态
/// @param resultBlock 结果回调
- (void)stopAllDownloadTask:(BDPanAPaaSDownloadTaskStatus)status
                resultBlock:(BDPanAPaaSOperationMultiTaskBlock)resultBlock;

/// 删除单个下载任务
/// @param taskId 任务id
/// @param withFile YES:同时删除下载文件 NO:保留下载文件
/// @return 是否成功
- (BOOL)deleteDownloadTask:(int)taskId
                  withFile:(BOOL)withFile;

/// 删除所有status状态的下载任务
/// @param status 状态
/// @param withFile YES:同时删除下载文件 NO:保留下载文件
/// @param resultBlock 结果回调
- (void)deleteAllDownloadTask:(BDPanAPaaSDownloadTaskStatus)status
                     withFile:(BOOL)withFile
                  resultBlock:(BDPanAPaaSOperationMultiTaskBlock)resultBlock;

/// 获取status状态的下载任务id
/// @param status 状态
/// @return 下载任务id数组
- (NSArray<NSNumber *> *)getDownloadTaskIds:(BDPanAPaaSDownloadTaskStatus)status;

/// 获取下载总速度
/// @return 单位：字节每秒
- (NSInteger)getDownloadTotalSpeed;

/// 限制下载总速度
/// @param maxSpeed 最大下载总速度
/// @return 是否成功
- (BOOL)setSpeedLimit:(int)maxSpeed;


/// 根据错误码获取错误描述信息
/// @param errorCode error code
/// @return 错误码对应错误描述信息
- (NSString *)errorMessageWith:(int)errorCode;

#pragma mark - 任务列表查询

/// 设置视频图片下载完成后是否自动保存到相册
/// @param enable YES - 自动保存到相册，默认不自动保存
/// @param albumName 相册名，不传则取当前APP名创建相册
- (void)setAutoSaveAlbumEnable:(BOOL)enable albumName:(NSString *_Nullable)albumName;

/// 查询全部任务 list - 暂不支持分页&排序，默认查询全部
/// @param startPos 起始位置
/// @param limit 查询数量
/// @param orderType 1-降序 0-升序
/// @param completion 回调
- (void)queryAllTaskWithStartPos:(NSInteger)startPos
                           limit:(NSInteger)limit
                       orderType:(NSInteger)orderType
                      completion:(BDPanDownloadTaskQueryBlock)completion;



@end

NS_ASSUME_NONNULL_END
