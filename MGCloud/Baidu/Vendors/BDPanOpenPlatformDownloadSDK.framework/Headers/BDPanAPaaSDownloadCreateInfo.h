//
//  BDPanAPaaSDownloadCreateInfo.h
//  BDPanAPaaSSDK
//
//  Created by suyoulong on 2022/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BDPanAPaaSDownloadCreateInfo : NSObject

/// 文件唯一标识，若 fid 为零，则必需在 extraInfo 中提供文件的 dlink 信息
@property (nonatomic, assign) unsigned long long fid;
/// 文件长度
@property (nonatomic, assign) unsigned long long fileSize;
/// 下载的本地路径，包含文件名的全路径，业务方负责保证多个用户的文件不发生冲突
@property (nonatomic, copy) NSString *localPath;
/// json格式扩展信息，存放诸如 md5、dlink（fid为零时，必需提供dlink）等信息
@property (nonatomic, copy) NSString *extraInfo;

@end

NS_ASSUME_NONNULL_END

