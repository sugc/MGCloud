//
//  CloundManager.swift
//  CommonUtil
//
//  Created by sugc on 2023/7/14.
//

import Foundation
import CloudKit
import UIKit
import Alamofire

//初始化成功通知
public let kClouManagerInitialSuceesNotificationName = Notification.Name.init("kClouManagerInitialSuceesNotification")

//文件信息发生变更
public let kClouManagerDocDetailsChangedNotification = Notification.Name.init("kClouManagerDocDetailsChangedNotification")



let CloudRootDicPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! + "/Documents/Cloud"


public typealias CloudOperationCallBack = (_ obj:CloudOpeationObj?, _ error:CloudOperationError?)->Void


public protocol CloudManagerProtocl {

    //根目录文件夹
    var cloudType : CloudType {get}
    
//    var fileDetails : CloudMetadataItem { get set }
    
    //获取当前的文件目录的详情
     func fetchDocumentDetails(completion:(()->Void)?)
    
    //文件url映射
    func getRemoteUrl(fromLocalUrl:URL)->URL
    
    func getLocalUrl(fromRemoteUrl:URL)->URL
    
    func getTempUrl(fromRemoteUrl:URL)->URL
    
    func setup(cloudSetting:CloudSettingItem, completion:((_ success : Bool) -> Void)?)
    
    func showLogInViewIfNeed(completion:(_ success:Bool)->Void)->Bool
}

//监听
public protocol CloudManagerObserverProtocl {
    
    //    func documentDidChangeInUrl(url:URL)
}


public class CloudManager : NSObject, CloudManagerProtocl {
   
    public var hasSetup : Bool = false
    var rootUrl : URL!
    var containerUrl: URL!
    var containerDic : String!
    var results : Array<Any> = []
    var lock : NSLock = NSLock()
    public var detail : CloudMetadataItem? = nil
    
    public var hasGetRemote : Bool = false
    var isRequestingRemote : Bool = false
    var fetchCompletions : Array<()->Void> = []
    
    private static var _networkReachablityManager : NetworkReachabilityManager?
    public static var networkReachablityManager : NetworkReachabilityManager {
        get {
            if _networkReachablityManager == nil {
                _networkReachablityManager =  NetworkReachabilityManager(host: "www.apple.com")
            }
            return _networkReachablityManager!
        }
    }
    
    public var cloudType: CloudType {
        return .unknown
    }
    
    private static var _CloudManager : CloudManager?
    private static var _LastCloudManager : CloudManager?
    
    var operationQueue : OperationQueue!
    
    public override init() {
        super.init()
    
        let rootPath = self.rooPath(forType: self.cloudType)
        if !FileManager.default.fileExists(atPath: rootPath) {
            do {
                try FileManager.default.createDirectory(atPath: rootPath, withIntermediateDirectories: true)
            }catch {
                
            }
        }

        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 5
        self.setupFromLocal()
    }
    
    //初始化化SDK
    public static func setupSDK(completion:((_ success:Bool)->Void)?) {
        setupSDK(cloudSetting: CloudSettingManager.shared.currentCloudItem, completion: completion)
    }
    
    //根据信息进行初始化
    public static func setupSDK(cloudSetting:CloudSettingItem,  completion:((_ success:Bool)->Void)?) {
        if !cloudSetting.isValid() {
            completion?(false)
            return
        }
        
        let manager =  managerWith(cloudType: cloudSetting.type) as! CloudManager
        manager.setup(cloudSetting: cloudSetting) { success in
            if success {
                _CloudManager = manager
                NotificationCenter.default.post(Notification(name: kClouManagerInitialSuceesNotificationName))
            }
            completion?(success)
            
        }
    }
    
    
    public static func sharedCloudManager()->CloudManager {
        
        if _CloudManager == nil {
            //读取当前的配置
            _CloudManager = managerWith(cloudType: CloudSettingManager.shared.currentCloudItem.type) as! CloudManager
        }
        return _CloudManager!
    }
    
    
    
    public static func managerWith(cloudType:CloudType)->CloudManager {
        
        var manager : CloudManager!
        switch cloudType {
        case .unknown:
            manager = CloudManager()
            break
        case .apple:
            manager = iCloudManager()
            break
        case .badidu:
            manager = BaiduCloudManager()
           
            break
        case .google:
            break
        }
        return manager
    }
    
    
    //从本地初始化, 初始化数据
    func setupFromLocal() {
        //从本地读取文件信息, 创建索引
        let detailPath = self.remoteDetailFilePath(forType: self.cloudType)
        if FileManager.default.fileExists(atPath:detailPath) {
            do {
                let data = try Data.init(contentsOf: URL.init(fileURLWithPath: detailPath))
                self.detail = try JSONDecoder().decode(CloudMetadataItem.self, from: data)
            }catch {
                
            }
        }
    }
    
    //
    public func setup(cloudSetting:CloudSettingItem, completion: ((_ success : Bool) -> Void)?) {
        self.operationQueue.cancelAllOperations()
        completion?(true)
    }
    
    public func changeRootDic(rootDic:String, completion: ((_ success : Bool) -> Void)?) {
        completion?(false)
    }
   
    
    func syncDetailToLocal() {
        guard let nonNilDetail = self.detail else {
            return
        }
        
        do {
            let data = try JSONEncoder().encode(nonNilDetail)
            try data.write(to: URL.init(fileURLWithPath:self.remoteDetailFilePath(forType: self.cloudType)))
        }catch {
            
        }
    }
    
    
    func rooPath(forType:CloudType)->String {
        var subPath = ""
        switch forType {
        case .unknown:
            break
        case .apple:
            subPath = "iCloud"
            break
        case .badidu:
            subPath = "BaiduCloud"
            break
        case .google:
            subPath = "GoogleCloud"
            break
        }
        return CloudRootDicPath + "/" + subPath
    }
    
    func taskFilePath(forType:CloudType)->String {
        var subPath = "/Task.json"
        return rooPath(forType: forType) + subPath
    }
    
    func remoteDetailFilePath(forType:CloudType)->String {
        var subPath = "/RemoteDetails.json"
        return rooPath(forType: forType) + subPath
    }
    
    
    public func addTask(toGroup:String, type:CloudOpeationType, remoteUrl:URL, localUrl:URL?,newFileName:String? = nil, removeOriginFileAfterFinished:Bool,autoUpdateModifyTime:Bool, callBack:CloudOperationCallBack?)->CloudOpeationObj {
        
        var operation = CloudOpeationObj.init(localUrl:localUrl, remoteUrl: remoteUrl, newFileName: newFileName, actionType: type, groupId: toGroup,removeOriginFileAfterFinished: removeOriginFileAfterFinished, autoUpdateModifyTime: autoUpdateModifyTime)
        
        self.addTasks(operations: [operation], callBack: callBack, barrierBlock: nil)
        return operation
    }
    
    
    
    
    public func addBarrierBlock(barrierBlock:@escaping (()->Void))->Void {
        if #available(iOS 13.0, *) {
            operationQueue.addBarrierBlock(barrierBlock)
        }
    }
    
    public func addTasks(operations:Array<CloudOpeationObj>,callBack:CloudOperationCallBack?, barrierBlock:(()->Void)?)->Void {
        
        //判断网络情况，网络不可使用的情况下，直接失败
        if  CloudManager.networkReachablityManager.status == .notReachable {
            callBack?(nil,CloudOperationError.sysFailed(reason: .networkUnReachAble))
            barrierBlock?()
            return
        }
        
        for obj in operations {
            let remoteObj = self.detail?.getItem(at: obj.remoteUrl)
            obj.extroInfo = remoteObj?.extroInfo
            let operation = CloudOperation.instance(type: self.cloudType,
                                                   operationObj: obj) { obj, error in
                if error == nil && obj != nil {
                    self.processAfterTaskFinished(task: obj!)
                }
                callBack?(obj, error)
            }!
          
            operationQueue.addOperation(operation)
        }
        
        if barrierBlock != nil {
            if #available(iOS 13.0, *) {
                operationQueue.addBarrierBlock(barrierBlock!)
            }
        }
    }
    
    //
    public func removeTasks(operations:Array<CloudOpeationObj>) {
        if operations.isEmpty {
            return
        }
        let currentOperations = self.operationQueue.operations as? Array<CloudOperation> ?? []
        
        for operation in currentOperations {
            if operations.contains(where: { obj in
                return obj == operation.operationObj
            }) {
                operation.cancel()
            }
        }
    }
    
    
    //根据本地地址获取云端地址
    public func getRemoteUrl(fromLocalUrl: URL) -> URL {
        var str =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        
        //写文章专用注释： absoluteString 和 path引起的编码行为不一致
        //var fileName = fromLocalUrl.absoluteString.replacingOccurrences(of: str ?? "", with: "").replacingOccurrences(of: "file://", with: "")
        var fileName = fromLocalUrl.path.replacingOccurrences(of: str ?? "", with: "").replacingOccurrences(of: "file://", with: "")
        if fileName.hasPrefix("/") {
            fileName = fileName.substring(from: fileName.index(after: fileName.startIndex))
        }
        fileName = fileName.replacingOccurrences(of: "Documents/", with: "")
        
        let res = self.containerUrl!.appendingPathComponent(fileName)
        return res
    }
    
    
    //根据云端地址获取本地地址
    public func getLocalUrl(fromRemoteUrl: URL) -> URL {
        
        var fileName = fromRemoteUrl.path.replacingOccurrences(of: self.containerUrl?.path ?? "", with: "")
        if fileName.hasPrefix("/") {
            fileName = fileName.substring(from: fileName.index(after: fileName.startIndex))
        }
        
        var str =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        
        return URL.init(fileURLWithPath: str!).appendingPathComponent("Documents").appendingPathComponent(fileName)
    }
    
    //获取临时的下载地址
    public func getTempUrl(fromRemoteUrl: URL) -> URL {
        var fileName = fromRemoteUrl.path.replacingOccurrences(of: self.containerUrl?.path ?? "", with: "")
        if fileName.hasPrefix("/") {
            fileName = fileName.substring(from: fileName.index(after: fileName.startIndex))
        }
        var str = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
 
        return URL.init(fileURLWithPath: str! + "/" + "CryptVolume" + "/" + fileName)
    }
    
    
    public func getTempUrl(fromLocalUrl: URL) -> URL {
        
        var str =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        
        //写文章专用注释： absoluteString 和 path引起的编码行为不一致
        //var fileName = fromLocalUrl.absoluteString.replacingOccurrences(of: str ?? "", with: "").replacingOccurrences(of: "file://", with: "")
        var fileName = fromLocalUrl.path.replacingOccurrences(of: str ?? "", with: "").replacingOccurrences(of: "file://", with: "")
        if fileName.hasPrefix("/") {
            fileName = fileName.substring(from: fileName.index(after: fileName.startIndex))
        }
        fileName = fileName.replacingOccurrences(of: "Documents/", with: "")
        
        
        var temp = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        
        return URL.init(fileURLWithPath: temp! + "/" + "CryptVolume" + "/" + fileName)
    }
    
    public func isRemoteFileExist(forLocal:URL)->Bool {
        guard let detail = self.detail else {
            return false
        }
        
        let remoteUrl  = self.getRemoteUrl(fromLocalUrl: forLocal)
        return detail.isFileExist(at: remoteUrl)
    }
    
    //
    public func fetchDocumentDetails(completion: (() -> Void)?) {
        
    }
    
    public func showLogInViewIfNeed(completion: (Bool) -> Void) -> Bool {
        return false
    }
    
  
    
    func processAfterTaskFinished(task:CloudOpeationObj) {
        if task.actionType == .delete {
            self.deletRemoteItem(remoteUrl: task.remoteUrl)
        }else {
            self.addRemoteItem(localUrl: task.localUrl!, remoteUrl: task.remoteUrl)
        }
    }
    //删除remote item
    func deletRemoteItem(remoteUrl:URL) {
        lock.lock()
        self.detail?.deleteSubItemAtUrl(url: remoteUrl)
        lock.unlock()
    }
    
    //新增remoteItem
    func addRemoteItem(localUrl:URL, remoteUrl:URL) {
        lock.lock()
        let remoteItem = self.detail?.getItem(at: remoteUrl)
        if remoteItem != nil {
            lock.unlock()
            return
        }
        let size = try? FileManager.default.attributesOfItem(atPath: localUrl.path)[FileAttributeKey.size] as? Int
        var item = CloudMetadataItem.init()
        item.url = remoteUrl
        item.size = size ?? 0
        self.detail?.addSubItem(subItem: item)
        lock.unlock()
    }
    
}
