//
//  BaiduCloudOperation.swift
//  MGCloud
//
//  Created by sugc on 2023/12/8.
//

import Foundation
import BDPanUploadSDK
import BDPanOpenPlatformDownloadSDK
import BDPanCloudFileSDK
import Alamofire
import BDPanOpenPlatformSDK

class BaiduCloudOperation : CloudOperation {
    //上传并更新
    public override func updateFile(remoteUrl: URL, data: Data, completion: CloudOperationCallBack?) {
        assert(false)
        
    }
    
    //上传并更新
    public override func updateFile(remoteUrl: URL, localUrl: URL, completion: CloudOperationCallBack?) {
        
        self.uploadFile(remoteUrl: remoteUrl, localUrl: localUrl, completion: completion)
        
    }
    
    //首次上传
    public override func uploadFile(remoteUrl: URL, localUrl: URL, completion: CloudOperationCallBack?) {
        
        print("upload file begin at pat:\(localUrl.path) to:\(remoteUrl.path)")
        BDPanUploadSDKManager.sharedInstance().upload(toServerPath: remoteUrl.deletingLastPathComponent().path,
                                                      fileURLS: [localUrl],
                                                      ondup: .cover) { model, error in
            if let err = error as? NSError  {
                print("upload file success at pat:\(localUrl.path) to:\(remoteUrl.path)")
                completion?(self.operationObj, CloudOperationError.sysFailed(reason: .serverFailed(sysError: err)))
                return
            }
            
            guard let nonnilModel = model else {
                completion?(self.operationObj, CloudOperationError.sysFailed(reason: .unKnown))
                return
            }
            
            if nonnilModel.transStatus == .fail {
                completion?(self.operationObj, CloudOperationError.sysFailed(reason: .unKnown))
                return
            }
            
            if nonnilModel.transStatus == .success {
                
                print("upload file failed at pat:\(localUrl.path) to:\(remoteUrl.path)")
                
                completion?(self.operationObj,nil)
            }
           

        }
    }
    
    //此接口禁用
    public override func uploadFile(remoteUrl: URL, data: Data, completion: CloudOperationCallBack?) {
        //随便搞个地址，保存，上传
        assert(false)
        
        
    }
    
    //创建文件夹
    public override func createDictionary(url:URL, completion:(_ success: Bool)->Void) {
        let dicUrl = url.deletingLastPathComponent()
        if FileManager.default.fileExists(atPath: dicUrl.absoluteString) {
            completion(true)
            return
        }
        
        do {
            try FileManager.default.createDirectory(at: dicUrl, withIntermediateDirectories: true)
        }catch {
            completion(false)
            return
        }
        completion(true)
    }
    
    public override func deleteFile(remoteUrl: URL, completion: CloudOperationCallBack?) {
        
        
        print("delete file at pat:\(remoteUrl.path)")
        
        
        BDPanAPaaSCloudFileManager.executeDeleteFileTask(withFilePaths: [remoteUrl.path],
                                                         async: .auto) { err, res in
            if err != nil {
                completion?(self.operationObj, CloudOperationError.sysFailed(reason: .serverFailed(sysError: err as? NSError)))
                return
            }
            
            guard let nonNilRes = res else {
                completion?(self.operationObj, CloudOperationError.sysFailed(reason: .unKnown))
                return
            }
            
            if nonNilRes.successList.count <= 0 {
                completion?(self.operationObj, CloudOperationError.sysFailed(reason: .unKnown))
                return
            }
            
            completion?(self.operationObj,nil)
        }
    }
    
    
    //下载文件
    override func downloadFile(remoteUrl: URL, localUrl: URL, completion: CloudOperationCallBack?) {
        
        //先获取文件信息，再进行下载
        let extroData = self.operationObj.extroInfo
        guard let fidStr = extroData?["fid"] as? String else{
            completion?(self.operationObj,.confilct(reason: .fileMissing(at: remoteUrl)))
            return
        }
        guard let fid = UInt64(fidStr) else{
            completion?(self.operationObj,.confilct(reason: .fileMissing(at: remoteUrl)))
            return
        }
        guard let fsizeStr = extroData?["fsize"] as? String else{
            completion?(self.operationObj,.confilct(reason: .fileMissing(at: remoteUrl)))
            return
        }
        guard let fsize = UInt64(fsizeStr) else{
            completion?(self.operationObj,.confilct(reason: .fileMissing(at: remoteUrl)))
            return
        }
        
        
      
        
        if FileManager.default.fileExists(atPath: localUrl.path) {
            
            try? FileManager.default.removeItem(atPath: localUrl.path)
            print("")
        }else {
            createDictionary(url: localUrl) { success in
            
                
            }
        }
        
        
        BDPanAPaaSCloudFileManager.fetchCloudFileList(withFids: [NSNumber(value: fid)],
                                                      dirPaths: [],
                                                      needDlink: 1,
                                                      thumbExpireHour: 1) { list, hasMore, err in
            
            
            guard let dlink = list?.first?.dlink else {
                completion?(self.operationObj,.sysFailed(reason: .serverFailed(sysError: err as? NSError)))
                return
            }
            
            //
            let header = [
                "User-Agent" : "pan.baidu.com",
                "access_token" : BDPanAPaaSSDK.sharedInstance().sdkConfig.spaceToken
            ]
            
            AF.request(dlink,method: .get,parameters: header).response { res in
                
                if res.error != nil {
                    completion?(self.operationObj, .sysFailed(reason: .serverFailed(sysError: res.error as? NSError)))
                    return
                }
                
                guard let data = res.data else {
                    //保存到文件夹中
                    completion?(self.operationObj, .sysFailed(reason: .serverFailed(sysError: nil)))
                    return
                }
                
                do {
                    try data.write(to: localUrl)
                }catch {
                    completion?(self.operationObj, .sysFailed(reason: .serverFailed(sysError: nil)))
                    return
                }
                completion?(self.operationObj,nil)
            }
            
           
        }
        
        
    
        
       
        
    }
    
    //移动云端的位置
    override func moveFile(fromUrl: URL, toUrl: URL, completion: CloudOperationCallBack?) {
        
        //移动文件，包括文件夹
        BDPanAPaaSCloudFileManager.executeMoveFileTask(withFilePaths: [fromUrl.path],
                                                       destPaths: [toUrl.path],
                                                       async: .auto,
                                                       ondup: BDPanFileConflictPolicy.overwrite) { error, res in
            if error != nil {
                completion?(self.operationObj, CloudOperationError.sysFailed(reason: .serverFailed(sysError: error as? NSError)))
                return
            }
            
            guard let nonNilRes = res else {
                completion?(self.operationObj, CloudOperationError.sysFailed(reason: .unKnown))
                return
            }
            
            if nonNilRes.successList.count <= 0 {
                completion?(self.operationObj, CloudOperationError.sysFailed(reason: .unKnown))
                return
            }
            
            completion?(self.operationObj,nil)
        }
    }
    

    
}
