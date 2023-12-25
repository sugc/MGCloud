//
//  BDPanUploadFileModel.h
//  BDPanUpload
//
//  Created by Zhang,Rui(PCS) on 2020/3/17.
//  Copyright © 2020 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDPanUploadModelProtocol.h"
#import "BDPanUploadSDKDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface BDPanUploadFileModel : NSObject <BDPanUploadModelProtocol>

/// 获取业务错误码
- (BDPanUploadErrorCode)errorCode;
/// 获取model用于小程序通信的字典
- (NSDictionary *)uploadModelDic;

@end

NS_ASSUME_NONNULL_END
