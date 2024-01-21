//
//  BDPanUploadSDKManager.h
//  BDPanUpload
//
//  Created by Zhang,Rui(PCS) on 2020/3/16.
//  Copyright © 2020 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "BDPanUploadFileModel.h"
#import "BDPanUploadSDKDefines.h"
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

/// 上传恢复类型
typedef NS_ENUM(NSUInteger, BDPanUploadResumeType) {
    BDPanUploadResumeTypePause,     // 暂停恢复
    BDPanUploadResumeTypeAbnormal,  // 异常恢复，使用该类型，默认读取所有normal状态且没有实际上传任务对应的任务：PP异常退出，并重新上传
    BDPanUploadResumeTypeFailed     // 失败恢复
};

/// 获取上传数据Block，models为TransStatus和数据的字典，由SDK返回时自动根据状态聚类
typedef void(^BDPanUploadDataQueryBlock)(BOOL success, NSDictionary<NSNumber *, NSArray<BDPanUploadFileModel *> *>  * _Nullable models, NSError * _Nullable error);
/// 执行操作的Block
typedef void(^BDPanUploadOperationBlock)(BOOL success, NSError * _Nullable error);
/// 判断文件是否存在的 Block，existInfo 为【文件地址 -> 文件是否存在】的字典
typedef void(^BDPanUploadFileExistBlock)(BOOL success, NSDictionary <NSString *, NSNumber *> * _Nullable existInfo, NSError * _Nullable error);
/// 进度信息回调，进度&状态&速度
typedef void(^BDPanUploadProgressInfoBlock)(BDPanUploadFileModel *_Nullable model, NSError *_Nullable error);

#warning BDPanUploadDelegate 已废弃，统一使用 block 获取上传状态信息
@protocol BDPanUploadDelegate <NSObject>
@optional
/// 状态变化时回调
/// @param currentStatus 上传任务状态
/// @param uploadModel 上传任务信息
- (void)uploadStateChanged:(TransStatus)currentStatus
                     model:(BDPanUploadFileModel *)uploadModel;

/// 任务进度变化时回调
/// @param uploadModel 上传任务信息
/// @param progress 上传进度
- (void)uploadProgressChange:(BDPanUploadFileModel *)uploadModel
                withProgress:(double)progress;
/// 任务添加时回调
/// @param uploadModel 上传任务信息
- (void)uploadModelDidAdd:(BDPanUploadFileModel *)uploadModel;

/// 任务删除时回调
/// @param uploadModel 上传任务信息
- (void)uploadModelDidDelete:(BDPanUploadFileModel *)uploadModel;

@end

/// 上传接口类，提供上传任务的增删改查相关操作
@interface BDPanUploadSDKManager : NSObject

+ (instancetype)sharedInstance;

#pragma mark - 获取上传数据接口

/// 根据上传状态获取对应的列表
/// @param status 传输状态  -1:失败；0:上传中；1:上传成功；2:暂停中
/// @param completion 回调
- (void)getUploadModelsWithStatus:(TransStatus)status withCompletion:(BDPanUploadDataQueryBlock)completion;


/// 获取所有类型的上传任务
/// @param completion 回调
- (void)getAllUploadModels:(BDPanUploadDataQueryBlock)completion;


/// 根据ID获取上传任务信息
/// @param uploadIds 任务ID列表
/// @param completion 回调
- (void)getUploadModels:(NSArray<NSNumber *> *)uploadIds
         withCompletion:(BDPanUploadDataQueryBlock)completion;


/// 根据本地文件地址获取上传任务信息
/// @param fileURLs 本地文件地址列表
/// @param completion 回调
- (void)getUploadModelsWithFileURLs:(NSArray<NSURL *> *)fileURLs
                     withCompletion:(BDPanUploadDataQueryBlock)completion;

#pragma mark - 获取文件状态接口
/// 判断文件是否在网盘存在
/// 注意：请求的文件数过多，回调会较慢，请注意分页查询
/// @param fileURLs 本地文件地址列表
/// @param completion 回调
- (void)checkFileExistWithFileURLs:(NSArray<NSURL *> *)fileURLs
                        completion:(BDPanUploadFileExistBlock)completion;

#pragma mark - 上传控制接口

/// 开始上传接口 - 重名文件默认 BDPanUploadDuplicatePolicyRenameAppendNumber
/// @param serverPath 服务器文件夹路径，举例："/来自：手机百度App"
/// @param uploadFileURLList 文件URL数组，本地文件路径
/// @param completion 回调，包含进度&速度&状态信息
- (void)uploadToServerPath:(NSString *)serverPath
                  fileURLS:(NSArray<NSURL *> *)uploadFileURLList
                completion:(BDPanUploadProgressInfoBlock)completion;

/// 开始上传接口
/// @param serverPath 服务器文件夹路径，举例："/来自：手机百度App"
/// @param uploadFileURLList 文件URL数组，本地文件路径
/// @param ondup 重名文件策略
/// @param completion 回调，包含进度&速度&状态信息
- (void)uploadToServerPath:(NSString *)serverPath
                  fileURLS:(NSArray<NSURL *> *)uploadFileURLList
                     ondup:(BDPanUploadDuplicatePolicy)ondup
                completion:(BDPanUploadProgressInfoBlock)completion;



/// 开始上传接口 - 重名文件默认 BDPanUploadDuplicatePolicyRenameAppendNumber
/// @param serverPath 服务器文件夹路径，举例："/来自：手机百度App"
/// @param identifiers 本地相册资源数据PHAsset.LocalIdentifiers
/// @param completion 回调，包含进度&速度&状态信息
- (void)uploadToServerPath:(NSString *)serverPath
                    assets:(NSArray<NSString *> *)identifiers
                completion:(BDPanUploadProgressInfoBlock)completion;

/// 开始上传接口
/// @param serverPath 服务器文件夹路径，举例："/来自：手机百度App"
/// @param identifiers 本地相册资源数据PHAsset.LocalIdentifiers
/// @param ondup 重名文件策略
/// @param completion 回调，包含进度&速度&状态信息
- (void)uploadToServerPath:(NSString *)serverPath
                    assets:(NSArray<NSString *> *)identifiers
                     ondup:(BDPanUploadDuplicatePolicy)ondup
                completion:(BDPanUploadProgressInfoBlock)completion;



/// 开始上传接口 - 文件夹上传 - 重名文件默认 BDPanUploadDuplicatePolicyRenameAppendNumber
/// @param serverPath 服务器文件夹路径，举例："/来自：手机百度App"
/// @param dirURLS 文件URL数组，本地文件夹路径
/// @param completion 回调，包含进度&速度&状态信息
- (void)uploadToServerPath:(NSString *)serverPath
                   dirURLS:(NSArray<NSURL *> *)dirURLS
                completion:(BDPanUploadProgressInfoBlock)completion;

/// 开始上传接口 - 文件夹上传
/// @param serverPath 服务器文件夹路径，举例："/来自：手机百度App"
/// @param dirURLS 文件URL数组，本地文件夹路径
/// @param ondup 重名文件策略
/// @param completion 回调，包含进度&速度&状态信息
- (void)uploadToServerPath:(NSString *)serverPath
                   dirURLS:(NSArray<NSURL *> *)dirURLS
                     ondup:(BDPanUploadDuplicatePolicy)ondup
                completion:(BDPanUploadProgressInfoBlock)completion;

/// 暂停上传接口
/// @param taskIDList 上传ID列表
/// @param completion 回调
- (void)pauseUploadlist:(NSArray<NSNumber *> *)taskIDList
             completion:(BDPanUploadOperationBlock)completion;

/// 继续上传接口
/// @param resumeType 恢复任务类型，0:暂停任务恢复 1:异常任务恢复
/// @param taskIDList 上传ID列表
/// @param completion 回调
- (void)resumeUpload:(BDPanUploadResumeType)resumeType
                list:(NSArray<NSNumber *> *)taskIDList
          completion:(BDPanUploadOperationBlock)completion;

/// 删除上传接口
/// @param taskIDList 上传ID列表
/// @param completion 回调
- (void)deleteUploadList:(NSArray<NSNumber *> *)taskIDList
             completion:(BDPanUploadOperationBlock)completion;


/// 取消所有上传任务
/// @param completion 回调
- (void)cancelAllUploadTask:(BDPanUploadOperationBlock)completion;

#pragma mark - 进度获取

/// 查询上传进度信息 - 主动回调，无需循环调用
/// @param uploadId uploadId
/// @param completion 回调，包含进度&速度&状态信息
- (void)fetchProgressInfoWithUploadId:(NSNumber *)uploadId
                           completion:(BDPanUploadProgressInfoBlock)completion;

#pragma mark - 废弃方法，请按指引更新到新方法调用

/// 开始上传接口
/// @param serverPath 服务器文件夹路径，举例："/来自：手机百度App"
/// @param uploadFileURLList 文件URL数组，本地文件路径
/// @param completion 回调
- (void)startUploadToServerPath:(NSString *)serverPath
                       fileURLS:(NSArray<NSURL *> *)uploadFileURLList
                     completion:(BDPanUploadOperationBlock)completion NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，状态信息回调均使用uploadToServerPath:fileURLS:completion:代替");

/// 开始上传接口
/// @param serverPath 服务器文件夹路径，举例："/来自：手机百度App"
/// @param identifiers 本地相册资源数据PHAsset.LocalIdentifiers
/// @param completion 回调
- (void)startUploadToServerPath:(NSString *)serverPath
                         assets:(NSArray<NSString *> *)identifiers
                     completion:(BDPanUploadOperationBlock)completion NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，状态信息回调均使用uploadToServerPath:assets:completion:代替");

/// 开始上传接口 - 文件夹上传
/// @param serverPath 服务器文件夹路径，举例："/来自：手机百度App"
/// @param dirURLS 文件URL数组，本地文件夹路径
/// @param completion 回调
- (void)startUploadToServerPath:(NSString *)serverPath
                        dirURLS:(NSArray<NSURL *> *)dirURLS
                     completion:(BDPanUploadOperationBlock)completion NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，状态信息回调均使用uploadToServerPath:dirURLS:completion:代替");


/// 注册代理类，强持有，默认主线程回调
/// @param delegate 代理实现类
- (void)registerDelegate:(id<BDPanUploadDelegate>)delegate NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，状态信息回调均使用block");

/// 反注册代理类
/// @param delegate 代理实现类
- (void)unregisterDelegate:(id<BDPanUploadDelegate>)delegate NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，状态信息回调均使用block");

@end


NS_ASSUME_NONNULL_END

