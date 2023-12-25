//
//  BDpanFileOperationDefines.h
//  Pods
//
//  Created by luochao04 on 2022/4/18.
//

#ifndef BDpanFileOperationDefines_h
#define BDpanFileOperationDefines_h


typedef NS_ENUM(NSInteger, BDPanFileOperationType) {
    BDPanFileOperationUnknown = 0,
    BDPanFileOperationDelete = 1, // 删除
    BDPanFileOperationRename = 2, // 重命名
    BDPanFileOperationMove = 3,   // 移动
    BDPanFileOperationCopy = 4,   // 复制
    BDPanFileOperationTransfer = 5,   //转存
};

// 文件操作状态
typedef NS_ENUM(NSInteger, BDPanFileTaskRequestOptions) {
    BDPanFileTaskRequestOptionsSync      = 0,   // 同步
    BDPanFileTaskRequestOptionsAuto      = 1,   // 自适应
    BDPanFileTaskRequestOptionsAsync     = 2    // 异步
};


// 异步任务查询状态，pending 和 running 状态下说明任务未执行完成，需要继续查询任务状态
typedef NS_ENUM(NSInteger, BDPanTaskStatus) {
    BDPanTaskStatusPending = 0,     // 任务待执行
    BDPanTaskStatusRunning,     // 任务执行中
    BDPanTaskStatusSuccessed,   // 任务执行成功
    BDPanTaskStatusFailed,      // 任务执行失败
};

// 遇到重复文件的处理策略
typedef NS_ENUM(NSInteger, BDPanFileConflictPolicy) {
    BDPanFileConflictPolicyFail = 0,        // 失败
    BDPanFileConflictPolicyOverwrite,   // 覆盖文件
    BDPanFileConflictPolicyNewCopy,     // 重命名文件
    BDPanFileConflictPolicySkip         // 跳过该文件操作
};


// 排序
typedef NS_ENUM(NSInteger, BDPanFileCategoryOrderType) {
    BDPanFileCategoryOrderByTime = 0,   // 按修改时间排序
    BDPanFileCategoryOrderByName = 1,   // 按文件名称排序
    BDPanFileCategoryOrderBySize = 2,   // 文件大小排序
};



#endif /* BDpanFileOperationDefines_h */
