//
//  BDPanFileManagerResponseProtocol.h
//  BDPanAPaaSSDK
//
//  Created by luochao04 on 2022/4/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BDpanFileOperationDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BDPanCopyMoveFileInfoModelProtocol <NSObject>

/// copy&move 时用，操作文件目录
@property (nonatomic, copy) NSString *from;

/// copy&move 时用，移动到目录
@property (nonatomic, copy) NSString *to;

@end

@protocol BDPanDeleteRenameFileInfoModelProtocol <NSObject>

/// 重名名&删除时用，文件路径
@property (nonatomic, copy) NSString *path;

@end

@protocol BDPanFileInfoModelProtocol <BDPanCopyMoveFileInfoModelProtocol, BDPanDeleteRenameFileInfoModelProtocol>

/// 错误码，0-成功
@property (nonatomic, assign) NSInteger errCode;

@end

@protocol BDPanFileManagerResponseProtocol <NSObject>

/// 任务 id，用于异步任务查询用
@property (nonatomic, copy) NSNumber *asyncTaskId;

/// 文件操作类型
@property (nonatomic, assign) BDPanFileOperationType opeartionType;

/// async=NO时，文件操作为同步任务时取文件操作状态列表，包含成功失败
@property (nonatomic, strong) NSArray<id<BDPanFileInfoModelProtocol>> *successList;
@property (nonatomic, strong) NSArray<id<BDPanFileInfoModelProtocol>> *failedList;

@end

@protocol BDPanAsyncTaskModelProtocol <NSObject>

@property(nonatomic, copy) NSString *taskId;
@property(nonatomic, assign) BDPanTaskStatus status;
@property(nonatomic, assign) CGFloat progress;
@property(nonatomic, assign) CGFloat total;
@property (nonatomic, strong) NSArray<id<BDPanFileInfoModelProtocol>> *successList;
@property (nonatomic, strong) NSArray<id<BDPanFileInfoModelProtocol>> *failedList;

@end

NS_ASSUME_NONNULL_END
