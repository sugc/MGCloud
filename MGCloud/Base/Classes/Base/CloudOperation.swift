//
//  CloudOpeation.swift
//  Pods
//
//  Created by sugc on 2023/10/18.
//

import Foundation

public enum CloudOpeationType : Int, Codable {
    case none = 0
    case upload = 1
    case update = 2
    case delete = 3
    case download = 4
    case rename = 5
}

open class CloudOpeationObj : Codable {
    
    //如何处理App重启路径变化问题
    public var localUrl : URL?  //当actionType == rename时，此时localUrl为旧的url
    public var remoteUrl : URL
    public var newFileName : String?
    public var actionType : CloudOpeationType
    public var groupId : String = "" //分组id
    public var removeOriginFileAfterFinished : Bool = false
    public var autoUpdateModifyTime : Bool = true
    public var extroInfo : Dictionary<String,String>?  //
    
    public init(localUrl: URL?, remoteUrl: URL, newFileName:String?, actionType: CloudOpeationType,groupId:String, removeOriginFileAfterFinished:Bool, autoUpdateModifyTime:Bool) {
        self.localUrl = localUrl
        self.remoteUrl = remoteUrl
        self.actionType = actionType
        self.groupId = groupId
        self.newFileName = newFileName
        self.removeOriginFileAfterFinished = removeOriginFileAfterFinished
        self.autoUpdateModifyTime = autoUpdateModifyTime
    }
    
    public static func == (lhs: CloudOpeationObj, rhs: CloudOpeationObj) -> Bool {
        if lhs === rhs {
            return true
        }
        let res = (
            lhs.localUrl == rhs.localUrl &&
            lhs.remoteUrl == rhs.remoteUrl &&
            lhs.newFileName == rhs.newFileName &&
            lhs.actionType == rhs.actionType &&
            lhs.groupId == rhs.groupId &&
            lhs.removeOriginFileAfterFinished == rhs.removeOriginFileAfterFinished &&
            lhs.autoUpdateModifyTime == rhs.autoUpdateModifyTime &&
            lhs.extroInfo == rhs.extroInfo
        )
        return res
    }
    
    
    public static func similar(lhs: CloudOpeationObj, rhs: CloudOpeationObj) -> Bool {
        
        let res = (
            lhs.localUrl == rhs.localUrl &&
            lhs.remoteUrl == rhs.remoteUrl
        )
        
        return res
    }
}

//云端操作
public protocol CloudOperationProtocol {
    //上传文件,
    func uploadFile(remoteUrl:URL, localUrl:URL, completion:CloudOperationCallBack?)
    
    func updateFile(remoteUrl:URL, localUrl:URL, completion:CloudOperationCallBack?)
    
    func deleteFile(remoteUrl:URL, completion:CloudOperationCallBack?)
    
    func downloadFile(remoteUrl:URL, localUrl:URL, completion:CloudOperationCallBack?)
    
    func moveFile(fromUrl:URL, toUrl:URL, completion:CloudOperationCallBack?)
}

//
class CloudOperation : Operation, CloudOperationProtocol {
  
    
    var operationObj : CloudOpeationObj
    var finishBlock : CloudOperationCallBack?

    
    private var _finished : Bool = false {
        willSet {
            self.willChangeValue(forKey: "isFinished");
        }
        didSet{
            self.didChangeValue(forKey: "isFinished");
        }
    }
    
    private var _executing : Bool = false {
        willSet {
            self.willChangeValue(forKey: "isExecuting");
        }
        didSet{
            self.didChangeValue(forKey: "isExecuting");
        }
    }
    private var _cancelled : Bool = false {
        willSet {
            self.willChangeValue(forKey: "isCancelled");
        }
        didSet{
            self.didChangeValue(forKey: "isCancelled");
        }
    }
    
    override var isFinished: Bool {
        get {
            return _finished
        }
    }
    
    override var isExecuting: Bool {
        get {
            return _executing
        }
    }
    
    override var isCancelled: Bool {
        get {
            return _cancelled
        }
        
        set(val) {
            _cancelled = val
        }
        
    }
    
    static func instance(type:CloudType,operationObj: CloudOpeationObj, finishBlock: CloudOperationCallBack?)->CloudOperation! {
        var operation : CloudOperation!
        switch type {
        case .badidu:
            operation = BaiduCloudOperation(operationObj: operationObj, finishBlock: finishBlock)
            break
        case .unknown:
            break
        case .apple:
            operation = iCloudOpeation(operationObj: operationObj, finishBlock: finishBlock)
            break
        case .google:
            break
        }
        return operation
    }
    
    init(operationObj: CloudOpeationObj, finishBlock: CloudOperationCallBack?) {
        self.operationObj = operationObj
        self.finishBlock = finishBlock
    }
    
    override func start() {
        super.start()
        _executing = true
        
    }
    
    override func main() {
        super.main()
        if _cancelled {
            markFinished()
            return
        }
        //处理图片
        weak var weakSelf = self
        switch operationObj.actionType {
        case .none:
            break
        case .upload:
            self.uploadFile(remoteUrl: operationObj.remoteUrl, localUrl: operationObj.localUrl!) {obj, error in
                weakSelf?.finishWithRes(obj: obj, res:error)
            }
            break
        case .update:
            self.updateFile(remoteUrl: operationObj.remoteUrl, localUrl: operationObj.localUrl!) {obj, error in
                weakSelf?.finishWithRes(obj: obj,res: error)
            }
            break
        case .delete:
            self.deleteFile(remoteUrl: operationObj.remoteUrl) {obj, error in
                weakSelf?.finishWithRes(obj: obj, res: error)
            }
            break
        case .download:
            self.downloadFile(remoteUrl: operationObj.remoteUrl, localUrl: operationObj.localUrl!) { obj, error in
                weakSelf?.finishWithRes(obj: obj, res: error)
            }
            break
        case .rename:
            self.moveFile(fromUrl: operationObj.remoteUrl, toUrl:  operationObj.localUrl!) { obj, error in
                weakSelf?.finishWithRes(obj: obj, res: error)
            }
            break
        }
    }
    
    func finishWithRes(obj:CloudOpeationObj?, res:CloudOperationError?) {
        if obj != nil && obj!.localUrl != nil && obj!.autoUpdateModifyTime == true && (obj!.actionType == .update && obj!.actionType == .upload) {
            //更新本地的
            try? FileManager.default.setAttributes([FileAttributeKey.modificationDate:Date()], ofItemAtPath: obj!.localUrl!.path)
        }
        self.finishBlock?(obj, res)
        self.markFinished()
    }
    
    
    func markFinished() {
        self.willChangeValue(forKey: "");
        _executing = false
        _finished = true
        self.didChangeValue(forKey: "");
    }
    
    
    public func uploadFile(remoteUrl: URL, data: Data, completion: CloudOperationCallBack?) {
//        completion?(self.operationObj,nil)
    }
    
    public func updateFile(remoteUrl: URL, data: Data, completion: CloudOperationCallBack?) {
//        completion?(self.operationObj,nil)
    }
    
    public func uploadFile(remoteUrl: URL, localUrl: URL, completion: CloudOperationCallBack?) {
//        completion?(self.operationObj,nil)
    }
    
    public func updateFile(remoteUrl: URL, localUrl: URL, completion: CloudOperationCallBack?) {
//        completion?(self.operationObj,nil)
    }
    
    public func deleteFile(remoteUrl: URL, completion: CloudOperationCallBack?) {
//        completion?(self.operationObj,nil)
    }
    
    public func createDictionary(url:URL, completion:(_ success: Bool)->Void) {
//        completion?(true)
    }
    
    
    func downloadFile(remoteUrl: URL, localUrl: URL, completion: CloudOperationCallBack?) {
//        completion?(self.operationObj,nil)
    }
    
    func moveFile(fromUrl: URL, toUrl: URL, completion: CloudOperationCallBack?) {
//        completion?(self.operationObj,nil)
    }
}
