//
//  BDPanUploadModelProtocol.h
//  BDPanUpload
//
//  Created by Zhang,Rui(PCS) on 2020/3/12.
//  Copyright © 2020 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BDPanUploadStep) {
    BDPanUploadStep_DataProcess = 0,
    BDPanUploadStep_Precreate = 1,
    BDPanUploadStep_UploadData = 2,
    BDPanUploadStep_Create = 3,
};

typedef NS_ENUM(NSUInteger, AssetType) {
    AssetTypeVideo = 0,        //视频
    AssetTypePhoto = 1,        //照片
    AssetTypeCaptureFile = 2,  //拍照上传
    AssetTypeInbox = 3,        // inbox转存
    AssetTypeFile = 4,         //本地文件
    AssetTypeUnzip = 5,        //解压文件
    AssetTypeImage = 6,        //UIImage上传
    AssetTypeLivePhoto = 7,    //Live Photo
    AssetTypeStoryVideo = 8,    //故事视频 （沙盒文件）
    AssetTypeFolder = 9      // 文件夹
};

typedef NS_ENUM(NSUInteger, AutoUploadStatus) {
    AutoUploadNoStatus = 0,
    AutoUploadInit = 1, //正在查找待备份的文件
    AutoUploadComplete = 2, //备份任务完成或无新增备份任务
    AutoUploadWork = 3, //工作状态，包括等待Wi-Fi和正在上传
    AutoUploadPause = 4, //用户手动暂停备份任务
    AutoUploadSuspend = 5, //被动被挂起
    AutoUploadEmpty = 6, //读取本地相册相簿，无数据
    AutoUploadClose = 7, //用户未开启自动备份 或 用户未登录
    AutoUploadLoadingList = 8, //拉取已备份List中
    AutoUploadInitSuspend = 9, //刚开始扫描相册就被动挂起（自动备份开关关闭或有更高优任务）
    AutoUploadError = 13, //扫码相册出错
    AutoUploadAccountBan = 14, //帐号封禁
    AutoUploadNetNoSpace = 15, //云端空间已满或不足
    AutoUploadAccountExpired = 16   // 账号过期
};

typedef NS_ENUM(NSUInteger, TransType) {
    TransTypeUpload = 0,        //上传
    TransTypeOfflineFavorite,   //离线收藏
    TransTypeAutoBackUp,        //自动备份
    TransTypeDownload,          //下载
    TransTypeSaveToLocalSpace,  //保存至本地相册
    TransTypeExternalDlinkDownload, //外部直链下载
};

typedef NS_ENUM(NSInteger, TransStatus) {
    TransStatusFail     = -1,
    TransStatusNormal   = 0,
    TransStatusSuccess  = 1,
    TransStatusPause    = 2
};

// 底层传输数据使用的原因，包含错误和普通的一些中间状态
typedef NS_ENUM(NSUInteger, TransReason) {
    TransReasonNormal = 0,
    TransReasonWaitWifi = 1,
    TransReasonWaitNetwork = 2,
    TransReasonNoPhoto = 3,
    TransReasonNoLocalSapce = 4,
    TransReasonNoNetworkSpace = 5,                   // 用户云端空间不足
    TransReasonFileOverSize = 6,
    TransReasonNoVideo = 7,
    TransReasonNoPermissionAccessAlbum = 8,         // 没有相册访问权限
    TransReasonNoFile = 9,
    TransReasonTranscodeError = 10,                 //
    TransReasonFileHasIllegalContent = 11,          //
    TransReasonNoPermissionToSaveToLocalSpace = 12, //
    TransReasonNoLocalSpaceToSaveImage = 13,        //
    TransReasonLocalImageHadBeenDeleted = 14,       //
    TransReasonNoPermissionToUpload = 15,           // 用户没有权限上传，非会员上传原图和视频时出现
    TransReasonInvalidBlocksPresent = 16,           // 上传下载分片为0封禁
    TransReasonAccountBan = 17,                     // 帐号封禁
    TransReasonFileIllegalFileName = 18,            // 上传文件文件名非法
    TransReasonImageFormatUnsupport = 19,           // 非A9处理器机型&iOS11设备或系统不支持将heif照片保存到系统相册
    TransReasonPhotoAlreadyUploadICloud = 20,       // 此图片已上传至iCloud,本地未找到原图
    TransReasonVideoAlreadyUploadICloud = 21,       // 此视频已上传至iCloud,本地未找到原图
    TransReasonICloudImageDownloadError = 22,       // iCloud照片下载失败
    TransReasonICloudVideoDownloadError = 23,       // iCloud视频下载失败
    TransReasonWriteIncompatibleData = 24,          // 保存至本地相册，数据不兼容
    TransReasonSavePhotoToLocalSizeExceed = 25,     // 保存相册至本地Size过大
    TransReasonIllegalFile = 26,                    // 文件格式异常，上传失败
    TransReasonLivePhotoZipError = 27,              // 文件打包失败，可能因手机空间不足
    TransReasonAntiStealingLinkError = 28,          // 命中防盗链,
    TransReasonRandError = 29,                      // 命中防盗链策略，rand校验失败
    TransReasonVideoDurationOverRange = 30,         // 视频文件时长超过4.5小时（仅限转码下载失败）
    TransReasonUploadPramError = 31,                // 上传失败，参数错误
    TransReasonUploadToMuchFiles = 32,              // 批量上传文件数超过500万
    TransReasonUploadFileOverSize = 33,             // 文件大小超过4G
    TransReasonNoCloudFile = 34,                    // 下载404错误，与TransReasonNoFile分开处理
    TransReasonNeedResetTransList = 35,             // 需要重置传输列表
    TransReasonNetworkError = 36,                   // 网络内部错误
    TransReasonFileSystemError = 37,                // 文件系统错误
    TransReasonFileLinkExpired = 38,                // 文件链接过期
    TransReasonFileDataError = 39,                  // 文件数据异常
    TransReasonLoginExpired = 40,                   // 账号过期，需重新登录
    TransReasonFileAlreadyExist = 41,               // 文件已存在
    TransReasonNetworkSpaceFilled = 42,             // 用户云端空间已满
    TransReasonMBoxGroupShareMessageIsNotExisted = 43,
    TransReasonPrivacyCapacityIsInsufficient = 44,  // 隐藏空间容量不足
    TransReasonNoUploadId = 45,                     // 没有上传ID
};

// 业务层使用的失败原因，用于业务判断TransFailReason
typedef NS_ENUM(NSUInteger, TransFailReason) {
    TransFailReasonPCSError = 3,                // 3 PCS接口上传错误
    TransFailReasonNoFile = 4,                  // 4. 源文件不存在
    TransFailReasonNoNetworkSpace = 5,          // 5. 百度网盘空间已满（下载：手机空间已满）
    TransFailReasonAblumReadError = 6,          // 6. 读取相册失败
    TransFailReasonServerError = 7,             // 7. 网盘服务器返回错误码
    TransFailReasonLocal_NetworkError = 8,      // 8. 本地网络连接失败
    TransFailReasonLocal_GenralError = 9,
    TransFailReasonLocal_CancelError = 10,      // 9,10 上传本地逻辑错误
    TransFailReasonLocal_PrecreateError = 11,   // 11 precreate错误
    TransFailReasonLocal_CreateError = 12,      // 12 create错误
    TransFailReasonLocal_NoLocalSapce = 13,     // 13 收藏本地空间不足
    TransFailReasonLocal_DownLogicError = 14,   // 14 收藏本地逻辑错误
    TransFailReasonLocal_TokenError = 15,       // token过期
    TransFailReasonPCSError_FileSizeWrong = 16, // 文件大小出错
    TransFailReasonNoPermissionToUpload = 17,   // 用户没有权限上传，非会员上传原图和视频时出现
    TransFailReasonInvalidBlocksPresent = 18,   // 上传下载分片为0封禁
    TransFailReasonAccountBan = 19,             // 帐号封禁
    TransFailReasonFileIllegalFileName = 20,    // 上传文件文件名非法
    TransFailReasonAlreadyUploadICloud = 21,    // 此图片已上传至iCloud,本地未找到原图
    TransFailReasonICloudDownloadError = 22,    // iCloud下载失败
    TransFailReasonIllegalFile = 23,            // 文件格式异常，上传失败
    TransFailReasonLivePhotoZipError = 24,      // 文件打包失败，可能因手机空间不足
    TransFailReasonUploadPramError = 25,        // 上传失败，参数错误
    TransFailReasonUploadToMuchFiles = 26,      // 批量上传文件数超过500万
    TransFailReasonUploadFileOverSize = 27,     // 文件大小超过4G
    TransFailReasonFileAlreadyExist = 28,        // 文件已存在
    TransFailReasonPrivacyCapacityIsInsufficient = 29,        // 隐私空间储存已达上限
};

typedef enum {
    UploadResult_Success = 1,
    UploadResult_AutoPhotoFail = 2,
    UploadResult_AutoVideoFail = 3,
    UploadResult_AutoSuccess = 4,
    UploadResult_CompressUploadSuccess = 5,         // 压缩上传
    UploadResult_CompressBackupSuccess = 6,         // 压缩备份
    UploadResult_CompressOriginalUploadSuccess = 7, // 压缩前提下，低于200K高于阀值的照片是以原图上传
    UploadResult_CompressOriginalBackupSuccess = 8, // 压缩前提下，低于200K高于阀值的照片是以原图备份
    UploadResult_LivePhotoSuccess = 9,              // LivePhoto上传成功
    UploadResult_LivePhotoAutoSuccess = 10,         // LivePhoto自动备份成功
    UploadResult_NetdiskToAlbumSuccess = 11,        // 网盘下载照片、视频进相册
    UploadResult_AutoPhotoFailiCloudNotExist = 12,  // 自动备份中触发iCloud下载时，iCloud中不存在该文件时使用该错误码
} UploadResultType;

//区分不同的上传模式:手动上传,批量上传,文件备份,照片备份,视频备份
typedef enum {
    FileCreateModel_None = 0,
    FileCreateModel_Manual = 1,
    FileCreateModel_Batch = 2,
    FileCreateModel_FileBackup = 3,
    FileCreateModel_PhotoBackup = 4,
    FileCreateModel_VideoBackup = 5
} FileCreateModel;

typedef enum: NSInteger {
    CreateFileRenameType_None,
    CreateFileRenameType_ForceRename,            //强制重命名
    CreateFileRenameType_ForceNoRename            //强制不重命名
} CreateFileRenameType;

typedef enum: NSInteger {
    UnknownType = -1,
    MultiFileType = 0,
    VideoType = 1,
    SoundType = 2,
    ImageType = 3,
    FileType = 4,
    AppType = 5,
    OtherType = 6,
    ReservedType = 7,
    FolderType = 900,
    AlbumType = 1000,
    SafeboxType = 2000,
    CardCatalogType = 3000,
    ReceiveShareDirType = 4000,
    NovelType = 5000,
    BoughtGoodsType = 6000,
    NoteType = 7000, // 笔记
    NovelServiceType = 8000, // 小说服务
} BDPanFileCategory;

NS_ASSUME_NONNULL_BEGIN

/// 上传模型的协议定义，约定了上传文件需要的基本字段
@protocol BDPanUploadModelProtocol <NSObject>

/* 上传标记 */
// 本地ID，一般有数据库插入后自动生成
@property (nonatomic, assign) NSInteger uploadId;
// Server ID，标记整个上传任务
@property (nonatomic, copy) NSString *serverUploadId;
// Server 签名，用于共享文件夹
@property (nonatomic, copy) NSString *serverUploadSign;
// 上传结果
@property(nonatomic, assign) UploadResultType uploadReslut;
// 传输类型，目前保留字段，为了兼容主端
@property (nonatomic, assign) TransType transType;
// 传输状态
@property (nonatomic, assign) TransStatus transStatus;
// 当前传输模型记录的transReason，和业务层使用的TransFailReason存在映射关系，但值不相同
@property (nonatomic, assign) TransReason transReason;
// 当前处于上传状态
@property (nonatomic, assign) BDPanUploadStep uploadStep;
// 当前已上传文件大小
@property(nonatomic, assign) unsigned long long transferSize;
// 上传任务创建时间
@property (nonatomic, strong) NSDate *uploadCTime;
// 上传任务修改时间
@property (nonatomic, strong) NSDate *uploadMTime;
/// 上传任务开始传输时间
@property (nonatomic, strong) NSDate *uploadStartTime;
/// 上传任务暂停时间
@property (nonatomic, strong) NSDate *uploadPauseTime;
/// 上传任务暂停时长
@property (nonatomic, assign) unsigned long long uploadPauseDuration;
// 上传任务速度
@property (nonatomic, assign) unsigned long long transferSpeed;

/* 文件基础信息 */
// 文件名
@property (nonatomic, copy) NSString *fileName;
// 服务器文件名
@property (nonatomic, copy) NSString *serverFileName;
// 文件服务器全路径
@property (nonatomic, copy) NSString *serverFullPath;
// 文件上传Server地址：文件夹地址
@property (nonatomic, copy) NSString *targetPath;
// 文件fid，由上传完成时Server返回
@property(nonatomic, assign) unsigned long long fid;
// 文件大小
@property (nonatomic, assign) unsigned long long fileSize;
// 文件全文MD5
@property (nonatomic, copy) NSString *fileMd5;
// 文件分片MD5数组的JSON串MD5(BlockListMD5)
@property (nonatomic, copy) NSString *blockListMd5;
// 文件分片数据MD5数组
@property (nonatomic, strong) NSArray *blockMd5List;
// 文件前256K数据MD5
@property (nonatomic, copy) NSString *sliceMd5;
// 创建文件类型
@property (nonatomic, assign) FileCreateModel createMode;
// 文件种类
@property (nonatomic, assign) BDPanFileCategory fileCategory;
// exif信息
@property (nonatomic, copy) NSString *exif;
// 压缩比例，默认100%
@property (nonatomic, assign) NSInteger compressQuality;
// 上传的类型
@property (nonatomic, assign) AssetType assetType;
// 上传的文件本地地址，可能是file:///，可能是相册中的数据
@property (nonatomic, copy) NSString *assetStr;
//用于存储上传失败错误码
@property (nonatomic, copy) NSString *errorInfo;
// 上传失败错误
@property (nonatomic, strong) NSError *error;
//本地资源修改时间
@property(nonatomic, strong) NSDate *assetMTime;

/* 辅助信息 */
// 重命名策略
@property (nonatomic, assign) CreateFileRenameType renameType;
// 日志串联参数ID
@property (nonatomic, copy) NSString *transServerLogID;
// 源文件上传是否检查目标目录下有源文件/压缩文件存在，用于压缩上传
@property (nonatomic, assign) BOOL checkExist;
// 支持压缩文件的源文件上传，用于控制请求参数
@property (nonatomic, assign) BOOL changeRtype;
// 文件是否来时沙盒目录
@property (nonatomic, assign) BOOL isFromSandbox;


/// 重名文件策略
@property (nonatomic, assign) NSInteger dupPolicy;

@end

NS_ASSUME_NONNULL_END
