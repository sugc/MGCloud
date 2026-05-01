//
//  BDPanAPaaSCloudFileManager.h
//  BDPanAPaaSSDK
//
//  Created by luochao04 on 2022/4/21.
//

#import <Foundation/Foundation.h>
#import "BDpanFileOperationDefines.h"
#import "BDPanCloudFileProtocol.h"
#import "BDPanFileManagerResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 获取云文件列表回调
/// @param fileList 文件信息 list
/// @param hasMore 分页数据是否还有更多
/// @param error 若 error 为 nil 说明获取文件列表成功，否则获取失败
typedef void(^BDPanAPaaSSDKFetchCloudFilesBlock)(NSArray<id<BDPanCloudFileProtocol>> *_Nullable fileList, BOOL hasMore, NSError *_Nullable error);

/// 文件操作回调
/// @param error 错误信息
/// @param responseModel 文件操作返回结果
typedef void(^BDPanAPaaSSDKCloudFileOperationBlock)(NSError *_Nullable error, id<BDPanFileManagerResponseProtocol> _Nullable responseModel);

/// 异步任务查询结果回调
/// @param error 错误信息
/// @param responseModel 异步任务查询结果
typedef void(^BDPanAPaaSSDKCloudFileAsyncTaskQueryBlock)(NSError *_Nullable error, id<BDPanAsyncTaskModelProtocol> _Nullable responseModel);

@interface BDPanAPaaSCloudFileManager : NSObject

#pragma mark - 文件列表

/// 获取指定目录下文件列表
/// @param dirPath 指定文件夹，默认为根目录: /
/// @param isDesc 是否为降序 YES - 降序  NO - 升序
/// @param orderType 排序类型，按 time/name/size排序
/// @param page 页码 从1开始
/// @param filesNum 每页数量，默认为100，最大为1000
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)fetchCloudFileListWithDirPath:(NSString *)dirPath
                                     isDesc:(BOOL)isDesc
                                  orderType:(BDPanFileCategoryOrderType)orderType
                                       page:(NSInteger)page
                                   filesNum:(NSInteger)filesNum
                                 completion:(BDPanAPaaSSDKFetchCloudFilesBlock)completion NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，请使用fetchCloudFileListWithDirPath:isDesc:orderType:page:filesNum:thumbExpireHour:completion: 方法.");

/// 获取指定目录下文件列表
/// @param dirPath 指定文件夹，默认为根目录: /
/// @param isDesc 是否为降序 YES - 降序  NO - 升序
/// @param orderType 排序类型，按 time/name/size排序
/// @param page 页码 从1开始
/// @param filesNum 每页数量，默认为100，最大为1000
/// @param thumbExpireHour 缩略图过期时间(单位小时)
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)fetchCloudFileListWithDirPath:(NSString *)dirPath
                                     isDesc:(BOOL)isDesc
                                  orderType:(BDPanFileCategoryOrderType)orderType
                                       page:(NSInteger)page
                                   filesNum:(NSInteger)filesNum
                            thumbExpireHour:(NSInteger)thumbExpireHour
                                 completion:(BDPanAPaaSSDKFetchCloudFilesBlock)completion;


/// 根据文件类型获取文件列表-所有文件
/// @param fileCategory 文件类型
/// @param orderType 排序类型，按 time/name/size排序
/// @param isDesc 是否为降序 YES - 降序  NO - 升序
/// @param page 页码 从1开始
/// @param filesNum 每页数量，最大为1000
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)fetchCloudFileListWithFileCategory:(BDPanFileType)fileCategory
                                          isDesc:(BOOL)isDesc
                                       orderType:(BDPanFileCategoryOrderType)orderType
                                            page:(NSInteger)page
                                        filesNum:(NSInteger)filesNum
                                      completion:(BDPanAPaaSSDKFetchCloudFilesBlock)completion NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，请使用fetchCloudFileListWithFileCategory:isDesc:orderType:page:filesNum:thumbExpireHour:completion: 方法.");

/// 根据文件类型获取文件列表-所有文件
/// @param fileCategory 文件类型
/// @param categoryList 文件类型列表，可以获取多个类型，与 fileCategory 二选一。1 视频、2 音频、3 图片、4 文档、5 应用、6 其他、7 种子
/// @param orderType 排序类型，按 time/name/size排序
/// @param isDesc 是否为降序 YES - 降序  NO - 升序
/// @param page 页码 从1开始
/// @param filesNum 每页数量，最大为1000
/// @param thumbExpireHour 缩略图过期时间(单位小时)
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)fetchCloudFileListWithFileCategory:(BDPanFileType)fileCategory
                                    categoryList:(NSArray *_Nullable)categoryList
                                          isDesc:(BOOL)isDesc
                                       orderType:(BDPanFileCategoryOrderType)orderType
                                            page:(NSInteger)page
                                        filesNum:(NSInteger)filesNum
                                 thumbExpireHour:(NSInteger)thumbExpireHour
                                      completion:(BDPanAPaaSSDKFetchCloudFilesBlock)completion;

/// 根据文件id或文件路径获取文件信息，fids和dirPaths二选一
/// @param fids 文件id数组
/// @param dirPaths 文件目录数组
/// @param needDlink 是否需要下载地址,0-不需要，1-需要
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)fetchCloudFileListWithFids:(NSArray<NSNumber *> *)fids
                                dirPaths:(NSArray<NSString *> *_Nullable)dirPaths
                               needDlink:(NSInteger)needDlink
                              completion:(BDPanAPaaSSDKFetchCloudFilesBlock)completion NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，请使用fetchCloudFileListWithFids:dirPaths:needDlink:thumbExpireHour:completion: 方法.");

/// 根据文件id或文件路径获取文件信息，fids和dirPaths二选一
/// @param fids 文件id数组
/// @param dirPaths 文件目录数组
/// @param needDlink 是否需要下载地址,0-不需要，1-需要
/// @param thumbExpireHour 缩略图过期时间(单位小时)
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)fetchCloudFileListWithFids:(NSArray<NSNumber *> *)fids
                                dirPaths:(NSArray<NSString *> *_Nullable)dirPaths
                               needDlink:(NSInteger)needDlink
                         thumbExpireHour:(NSInteger)thumbExpireHour
                              completion:(BDPanAPaaSSDKFetchCloudFilesBlock)completion;


/// 根据关键词搜索指定目录下文件
/// @param keyword 搜索关键词
/// @param dirPath 目录 ，"/" 为根目录
/// @param fileCategory 文件类型
/// @param page 页码 从1开始
/// @param filesNum 每页数量，默认为100，最大为1000
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)searchCloudFileListWithKeyword:(NSString *)keyword
                                     dirPath:(NSString *)dirPath
                                fileCategory:(BDPanFileType)fileCategory
                                        page:(NSInteger)page
                                    filesNum:(NSInteger)filesNum
                                  completion:(BDPanAPaaSSDKFetchCloudFilesBlock)completion NS_DEPRECATED_IOS(2_0, 8_0, "方法已废弃，请使用searchCloudFileListWithKeyword:dirPaths:fileCategory:page:filesNum:thumbExpireHour:completion: 方法.");

/// 根据关键词搜索指定目录下文件
/// @param keyword 搜索关键词
/// @param dirPath 目录 ，"/" 为根目录
/// @param fileCategory 文件类型
/// @param page 页码 从1开始
/// @param filesNum 每页数量，默认为100，最大为1000
/// @param thumbExpireHour 缩略图过期时间(单位小时)
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)searchCloudFileListWithKeyword:(NSString *)keyword
                                     dirPath:(NSString *)dirPath
                                fileCategory:(BDPanFileType)fileCategory
                                        page:(NSInteger)page
                                    filesNum:(NSInteger)filesNum
                             thumbExpireHour:(NSInteger)thumbExpireHour
                                  completion:(BDPanAPaaSSDKFetchCloudFilesBlock)completion;

#pragma mark - 文件操作：复制/移动/删除/重命名

/// 执行文件拷贝操作
/// @param filePaths 待拷贝文件路径(BDPanCloudFileProtocol-path)数组
/// @param destPaths 拷贝到目标路径(全路径)数组
/// @param async 任务类型，详见 0 - 同步，1 - 自适应，2 - 异步，建议使用自适应
/// @param ondup 遇到重复文件的处理策略
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)executeCopyFileTaskWithFilePaths:(NSArray<NSString *> *)filePaths
                                     destPaths:(NSArray<NSString *> *)destPaths
                                         async:(BDPanFileTaskRequestOptions)async
                                         ondup:(BDPanFileConflictPolicy)ondup
                                    completion:(BDPanAPaaSSDKCloudFileOperationBlock)completion;


/// 执行文件删除操作
/// @param filePaths 待删除文件路径(BDPanCloudFileProtocol-path)数组
/// @param async 任务类型，详见 0 - 同步，1 - 自适应，2 - 异步，建议使用自适应
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)executeDeleteFileTaskWithFilePaths:(NSArray<NSString *> *)filePaths
                                           async:(BDPanFileTaskRequestOptions)async
                                      completion:(BDPanAPaaSSDKCloudFileOperationBlock)completion;

/// 执行文件重命名操作
/// @param filePaths 待重命名文件路径(BDPanCloudFileProtocol-path)数组
/// @param newNames 重命名后文件全路径(文件路径+新名字)数组
/// @param async 任务类型，详见 0 - 同步，1 - 自适应，2 - 异步，建议使用自适应
/// @param ondup 遇到重复文件的处理策略
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)executeRenameFileTaskWithFilePaths:(NSArray<NSString *> *)filePaths
                                        newNames:(NSArray<NSString *> *)newNames
                                           async:(BDPanFileTaskRequestOptions)async
                                           ondup:(BDPanFileConflictPolicy)ondup
                                      completion:(BDPanAPaaSSDKCloudFileOperationBlock)completion;


/// 执行文件移动
/// @param filePaths 待移动文件路径(BDPanCloudFileProtocol-path)数组
/// @param destPaths 移动到目标路径(全路径)数组
/// @param async 任务类型，详见 0 - 同步，1 - 自适应，2 - 异步，建议使用自适应
/// @param ondup 遇到重复文件的处理策略
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)executeMoveFileTaskWithFilePaths:(NSArray<NSString *> *)filePaths
                                     destPaths:(NSArray<NSString *> *)destPaths
                                         async:(BDPanFileTaskRequestOptions)async
                                         ondup:(BDPanFileConflictPolicy)ondup
                                    completion:(BDPanAPaaSSDKCloudFileOperationBlock)completion;


/// 根据 taskid 查询异步任务执行状态
/// @param taskId 执行文件复制/删除/重命名/移动 操作时，回调返回的taskId
/// @param completion 回调
/// @return requestid ，可用于取消对应请求
+ (NSUInteger)executeAsyncTaskueryWithTaskId:(NSNumber *)taskId
                                  completion:(BDPanAPaaSSDKCloudFileAsyncTaskQueryBlock)completion;


@end

NS_ASSUME_NONNULL_END
