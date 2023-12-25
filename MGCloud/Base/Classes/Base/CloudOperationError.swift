//
//  CloudOperationError.swift
//  MGCloud
//
//  Created by sugc on 2023/10/18.
//

import Foundation

public enum CloudOperationError : Error {
    
    //文件冲突,
    public enum ConflictReason {
        //上传时文件存在
        case fileExist(at:URL)
        
        //更新时文件不存在？
        case fileMissing(at:URL)
        
        case dictionaryCreateFailed(at:URL)
    }
    
    //服务端挂了...
    public enum SysFailedReason {
        
        case networkUnReachAble
        case wifiUnReachAble  //wifi未授权
        case sdkUnInitialized //SDK未初始化
        case serverFailed(sysError:Error?)
        case unKnown //SDK未初始化
        
    }
    
    case confilct(reason:ConflictReason)
    case sysFailed(reason:SysFailedReason)
    
}
