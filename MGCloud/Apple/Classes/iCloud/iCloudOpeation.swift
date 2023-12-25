//
//  iCloudOpeation.swift
//  MGCloud
//
//  Created by sugc on 2023/10/19.
//

import Foundation
//
class iCloudOpeation : CloudOperation {
   
    //上传并更新
    public override func updateFile(remoteUrl: URL, data: Data, completion: CloudOperationCallBack?) {
        
        createDictionary(url: remoteUrl) { success in
            if !success {
                completion?(self.operationObj, CloudOperationError.confilct(reason: .dictionaryCreateFailed(at: remoteUrl)))
                return
            }
            let docuemnt = CloudDocument.init(fileURL: remoteUrl)
            docuemnt.data = data
            docuemnt.save(to: remoteUrl, for: .forOverwriting) { success in
                if success {
                    completion?(self.operationObj, nil)
                }else {
                    
                }
            }
        }
    }
    
    //上传并更新
    public override func updateFile(remoteUrl: URL, localUrl: URL, completion: CloudOperationCallBack?) {
        
        guard let data = try? Data.init(contentsOf: localUrl) else {
            completion?(self.operationObj, CloudOperationError.confilct(reason: .fileMissing(at: localUrl)))
            return
        }
        
        self.updateFile(remoteUrl: remoteUrl, data: data, completion: completion)
    }
    
    //首次上传
    public override func uploadFile(remoteUrl: URL, localUrl: URL, completion: CloudOperationCallBack?) {
        

        guard let data = try? Data.init(contentsOf: localUrl) else {
            completion?(self.operationObj, CloudOperationError.confilct(reason: .fileMissing(at: localUrl)))
            return
        }
        
        self.uploadFile(remoteUrl: remoteUrl, data: data, completion: completion)
    }
    
    //首次上传
    public override func uploadFile(remoteUrl: URL, data: Data, completion: CloudOperationCallBack?) {
        //判断文件是否存在
        createDictionary(url: remoteUrl) { success in
            if !success {
                completion?(self.operationObj, CloudOperationError.confilct(reason: .dictionaryCreateFailed(at: remoteUrl)))
                return
            }
            let docuemnt = CloudDocument.init(fileURL: remoteUrl)
            docuemnt.data = data
            docuemnt.save(to: remoteUrl, for: .forCreating) { success in
                if success {
                    completion?(self.operationObj, nil)
                }else {
                    
                }
            }
        }
    }
  
    //创建文件夹，
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
        
        var isDic : ObjCBool = false
        if !FileManager.default.fileExists(atPath: remoteUrl.path, isDirectory: &isDic) {
            completion?(self.operationObj, CloudOperationError.confilct(reason: .fileMissing(at: remoteUrl)))
            return
        }
        
        if isDic.boolValue {
            let res = FileManager.default.deleteDictionaryRecursiveAtPath(path: remoteUrl.path)
            completion?(self.operationObj, res ? nil : CloudOperationError.sysFailed(reason: .serverFailed(sysError: nil)))
            return
        }
        
        do {
            try FileManager.default.removeItem(at: remoteUrl)
        }catch {
            completion?(self.operationObj, nil)
            return
        }
       completion?(self.operationObj, nil)
    }
    
    
    //下载文件
    override func downloadFile(remoteUrl: URL, localUrl: URL, completion: CloudOperationCallBack?) {
        let docuemnt = CloudDocument.init(fileURL: remoteUrl)
        weak var doc = docuemnt
        docuemnt.open { success in
            if !success {
                completion?(self.operationObj, CloudOperationError.sysFailed(reason: .serverFailed(sysError: nil)))
                return
            }
            self.createDictionary(url: localUrl) { success in
                do {
                    try doc?.data?.write(to: localUrl)
                }catch {
                    completion?(self.operationObj, CloudOperationError.sysFailed(reason: .serverFailed(sysError: nil)))
                    return
                }
            }
           
            completion?(self.operationObj, nil)
        }
    }
    
    //移动云端的位置
    override func moveFile(fromUrl: URL, toUrl: URL, completion: CloudOperationCallBack?) {
        
        //直接使用FileManager进行处理
        //测试一下是否能直接移动整个文件夹
        
        
//        FileManager.default.moveItem(at: <#T##URL#>, to: <#T##URL#>)
        
        
        
    }
}
