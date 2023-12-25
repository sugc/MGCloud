//
//  BDPanAutoBackupManagerDelegate.h
//  BDPanUploadSDK
//
//  Created by luochao04 on 2022/12/2.
//

#import <Foundation/Foundation.h>
#import "BDPanUploadSDKDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BDPanAutoBackupManagerDelegate <NSObject>

/// 备份状态改变
/// @param status 改变后的备份状态，也可以使用 autoBackupStatus 方法获取
- (void)autoBackupStatusChanged:(BDPanAutoBackupState)status;

/// 备份数量改变
/// @param status 备份状态
/// @param uploadedCount  已上传数量
/// @param totalCount 总数量
- (void)autoBackupCountChanged:(BDPanAutoBackupState)status
                 uploadedCount:(NSInteger)uploadedCount
                    totalCount:(NSInteger)totalCount;

@end

NS_ASSUME_NONNULL_END
