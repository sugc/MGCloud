//
//  BDPanCloudFileProtocol.h
//  BDPanUploadSDK
//
//  Created by luochao04 on 2022/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BDPanVideoMetaProtocol <NSObject>

/// 视频分辨率 width 1920
@property (nonatomic, assign) NSInteger width;
/// 视频分辨率 height 1080
@property (nonatomic, assign) NSInteger height;
/// 帧率
@property (nonatomic, assign) NSInteger frameRate;
/// 时长 s
@property (nonatomic, assign) NSInteger duration;
/// 时长 ms
@property (nonatomic, assign) NSInteger durationMs;
/// 额外信息
@property (nonatomic, strong) NSString *extraInfo;

/// 分辨率 "width:1920,height:1080"
@property (nonatomic, copy) NSString *resolution;

@end

@protocol BDPanCloudFileProtocol <NSObject>

typedef NS_ENUM(NSUInteger, BDPanFileType) {
    BDPanFileTypeUnknown = 0,      // 未知
    BDPanFileTypeVideo = 1,        // 视频
    BDPanFileTypeAudio = 2,        // 音频
    BDPanFileTypePhoto = 3,        // 图片
    BDPanFileTypeDocument = 4,     // 文档
    BDPanFileTypeIAPP = 5,         // 应用
    BDPanFileTypeOther = 6,        // 其它
    BDPanFileTypeSeed = 7,         // 种子
};

/// 文件在云端的唯一标识ID
@property(nonatomic, assign) unsigned long long fid;
/// 文件的绝对路径
@property(nonatomic, copy) NSString *path;
/// 文件名称
@property(nonatomic, copy) NSString *server_filename;
/// 文件大小，单位B
@property(nonatomic, assign) unsigned long long size;
/// 文件在服务器修改时间
@property(nonatomic, strong) NSDate *server_mtime;
/// 文件在服务器创建时间
@property(nonatomic, strong) NSDate *server_ctime;
/// 文件在客户端修改时间
@property(nonatomic, strong) NSDate *local_mtime;
/// 文件在客户端创建时间
@property(nonatomic, strong) NSDate *local_ctime;
/// 是否目录，0 文件、1 目录
@property(nonatomic, assign) BOOL isdir;
/// 文件类型，1 视频、2 音频、3 图片、4 文档、5 应用、6 其他、7 种子
@property(nonatomic, assign) BDPanFileType category;
/// 文件的md5值，只有是文件类型时，该KEY才存在
@property (nonatomic, copy) NSString *md5;
/// 该条目分类为图片时，该KEY才存在，包含三个尺寸的缩略图URL
@property(nonatomic, copy) NSString *thumbUrl;
/// 包含三个尺寸的缩略图URL
@property(nonatomic, strong) NSDictionary *thumbs;
/// 下载链接
@property(nonatomic, copy) NSString *dlink;


/// video 信息
@property (nonatomic, strong) id<BDPanVideoMetaProtocol> videoInfo;

@end

NS_ASSUME_NONNULL_END
