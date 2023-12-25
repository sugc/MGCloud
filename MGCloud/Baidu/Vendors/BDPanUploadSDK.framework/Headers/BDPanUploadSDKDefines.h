//
//  BDPanUploadSDKDefines.h
//  BDPanUploadSDK
//
//  Created by Zhang,Rui(PCS) on 2020/4/7.
//  Copyright © 2020 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BDPanUploadFileModel;

NS_ASSUME_NONNULL_BEGIN

/*****************      NotificationNames         **************/

/// 上传数量改变
extern NSNotificationName BDPanUploadCountChangedNotification;
/// 上传全部完成
extern NSNotificationName BDPanAllUploadCompleteNotification;
/// 某个上传任务开始
extern NSNotificationName BDPanUploadStartNotification;
/// 某个上传任务进行中，以下面格式取进度数据
/*
    object:uploadModel
    userInfo:{
        BDPanUploadProgressSize : @(progress),
        BDPanUploadProgressTotal : @(totalSize),
        BDPanUploadProgressIncreaseSize : @(increaseSize)
    }
 */
extern NSNotificationName BDPanUploadProgressNotification;
/// 某个上传任务结束
extern NSNotificationName BDPanUploadDoneNotification;
/// 某个上传任务状态改变
extern NSNotificationName BDPanUploadReasonChangeNotification;
/// 某个上传任务被删除
extern NSNotificationName BDPanUploadDeleteNotification;
/// 某个上传任务暂停
extern NSNotificationName BDPanUploadPauseNotification;

/// 某个上传任务的当前进度
extern NSString *BDPanUploadProgressSize;
/// 某个上传任务的总共要上传的大小
extern NSString *BDPanUploadProgressTotal;
/// 某个上传任务的每次回调上传新增的大小
extern NSString *BDPanUploadProgressIncreaseSize;

/*****************      NotificationNames         **************/

/*****************      Error         **************/
extern NSErrorDomain BDPanUploadErrorDomain;
// 自动备份类型
typedef NS_ENUM(NSUInteger, BDPanAutoBackupType) {
    BDPanAutoBackupTypePhoto,    // 照片
    BDPanAutoBackupTypeVideo,    // 视频
    BDPanAutoBackupTypeDocument, // 文档
};

// 文档备份类型
typedef NS_OPTIONS (NSUInteger, BDPanDocumentBackupType) {
    BDPanDocumentBackupNOType = 0,
    BDPanDocumentBackupTypePDF = 1 << 0,
    BDPanDocumentBackupTypeDOC = 1 << 1,
    BDPanDocumentBackupTypePPT = 1 << 2,
    BDPanDocumentBackupTypeXLS = 1 << 3,
    BDPanDocumentBackupTypeTXT = 1 << 4,
};

// 视频自动备份来源
typedef NS_OPTIONS(NSUInteger, BDPanVideoBackupSource) {
    BDPanVideoBackupSourceNone = 0,
    BDPanVideoBackupSourceAsset = 1 << 0,   // 系统相册
    BDPanVideoBackupSourceSandbox = 1 << 1, // 沙盒
};

// 上传重名文件策略，1 和 2命名方式不同，1在原文件名后边拼接上传日期，2在愿文件名后拼接(1)
typedef NS_ENUM(NSInteger, BDPanUploadDuplicatePolicy) {
    BDPanUploadDuplicatePolicyError = 0,                 // 若云端存在同名文件返回错误
    BDPanUploadDuplicatePolicyRenameAppendDate = 1,      // 若云端存在同名文件进行重命名 origin.jpg -> origin_20221122_110537.jpg
    BDPanUploadDuplicatePolicyRenameAppendNumber = 2,    // 若云端存在同名文件进行重命名 origin.jpg -> origin(1).jpg
    BDPanUploadDuplicatePolicyCover = 3,                 // 若云端存在同名文件对该文件进行覆盖
};

// 自动备份状态码
typedef NS_ENUM(NSUInteger, BDPanAutoBackupState) {
    BDPanAutoBackupStateNone = 0,           // 默认状态
    BDPanAutoBackupStateInit = 1000,        // 自动备份初始化
    BDPanAutoBackupStateWorking = 1001,     // 自动备份中
    BDPanAutoBackupStatePaused = 1002,      // 自动备份被暂停
    BDPanAutoBackupStateCompleted = 1003,   // 自动备份已完成
    
    BDPanAutoBackupStateAccountBanned = 2001,   // 自动备份异常:账号被封禁
    BDPanAutoBackupStateNoSpace = 2002,         // 自动备份异常:云空间已满
    BDPanAutoBackupStateAccountExpired = 2003,  // 自动备份异常:账号已过期
    BDPanAutoBackupStateAccountWaitNet = 2004,  // 自动备份异常:等待网络
};

// 错误枚举定义
typedef NS_ENUM(NSUInteger, BDPanUploadErrorCode) {
    BDPanUploadErrorCodeDefault,
    BDPanUploadErrorCodeUnknow,                         // 未知错误
    BDPanUploadErrorCodeNoNetwork = 1001,               // 当前无网络，无法上传
    BDPanUploadErrorCodeWifiOnly = 1002,                // 当前上传仅Wi-Fi上传，移动网络无法上传
    BDPanUploadErrorSpaceTokenInvalid = 10104,          // 当前spacetoken失效
    BDPanUploadErrorCodeNoAccount = 2001,               // 当前未初始化
    BDPanUploadErrorCodeAccountExpired = 2002,          // 登录过期
    BDPanUploadErrorCodeNoSpace = 2003,                 // 网盘空间不足
    BDPanUploadErrorCodeAccountBan = 2004,              // 账号封禁
    BDPanUploadErrorCodeNoLocalFile = 3001,             // 本地文件不存在
    BDPanUploadErrorCodeVideoUploadNotAllowed = 3002,   // 非会员不允许上传视频
    BDPanUploadErrorCodeIllegalFormat = 3003,           // 文件名非法
    BDPanUploadErrorCodeTooMuchFiles = 3004,            // 上传文件数过多，超过500W
    BDPanUploadErrorCodeFileOverSize = 3005,            // 上传文件超过4G
    BDPanUploadErrorCodeAccessAlbumDenied = 3006,       // 无权限访问相册
    BDPanUploadErrorCodeiCloudDownloadError = 3007,     // iCloud下载失败
    BDPanUploadErrorCodeLivePhotoZipError = 3008,       // LivePhoto打包失败，可能因手机空间不足
    BDPanUploadErrorCodeParamsError = 4001,             // 参数错误
    BDPanUploadErrorCodeDBUpdateFail = 4002,            // 数据库更新失败
};

@interface BDPanUploadSDKDefines : NSObject

+ (NSError *)errorWith:(BDPanUploadErrorCode)errorCode;

+ (NSError *)error:(BDPanUploadErrorCode)errorCode withUploadModel:(BDPanUploadFileModel *)model;

+ (NSString *)errorMsg:(BDPanUploadErrorCode)errorCode;

@end

NS_ASSUME_NONNULL_END
