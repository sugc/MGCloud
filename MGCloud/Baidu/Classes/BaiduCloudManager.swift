//
//  BaiduCloudManager.swift
//  MGCloud
//
//  Created by sugc on 2023/10/13.
//

import Foundation
import BDPanOpenPlatformSDK
import BDPanCloudFileSDK
import BDPanOpenPlatformDownloadSDK
import BDPanUploadSDK


class BaiduCloudManager : CloudManager {
    
    var accessToken : String! = ""
    
    
    
    public override var cloudType: CloudType {
        return .badidu
    }
    
    override init() {
        super.init()
        self.rootUrl = URL(string: "https://pan.baidu.com")
        //从本地读取相关配置
        
    }
    
    
    override func setup(cloudSetting:CloudSettingItem, completion:((_ success : Bool)->Void)?) {
        
        
        var item = cloudSetting
        if item.type != .badidu || !item.isValid() {
            completion?(false)
            return
        }
        hasGetRemote = false
        self.containerDic = item.rootDic
        self.containerUrl = URL(string: "https://pan.baidu.com")!.appendingPathComponent(item.rootDic)
        
        var config = BDPanSDKConfig()
        config.appId = 43898618
        config.spaceToken = item.token
        
        //wait to fix here
        config.userIdentifier = "xxx"
        config.debugEnable = true
        
        BDPanAPaaSSDK.sharedInstance().initializeSDKForOpenPlatform(with: config) { error in
            
            let err = error as? NSError
            
            if err != nil {
                //判断token失效的
                if err!.code == BDPanSDKErrorCode.spaceTokenInvalid.rawValue {
                    self.resetWhenTokenInvaliad()
                }
                completion?(false)
                return
            }
            
            
            self.hasSetup = true
            completion?(true)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01, execute: DispatchWorkItem(block: {
                self.fetchDocumentDetails(completion: nil)
            }))
            return
        }
        
        BDPanAPaaSSDK.sharedInstance().spaceTokenInvalidBlock = {
            self.resetWhenTokenInvaliad()
        }
    }
    
    public override func changeRootDic(rootDic:String, completion: ((_ success : Bool) -> Void)?) {
        //        self.containerDic = item.rootDic
        //        self.containerUrl = URL(string: "https://pan.baidu.com" + containerDic)
        
        BDPanAPaaSCloudFileManager.executeRenameFileTask(withFilePaths: [self.containerDic],
                                                         newNames: [rootDic],
                                                         async: .sync,
                                                         ondup: .fail) { error, res in
            if error == nil {
                self.containerDic = rootDic
                self.containerUrl = URL(string: "https://pan.baidu.com")!.appendingPathComponent(rootDic)
                self.lock.lock()
                self.detail?.changeRootPath(rootPath: rootDic)
                self.lock.unlock()
            }
            
            completion?(error == nil)
            print("xxxxx")
        }
        
        
    }
    
    func resetWhenTokenInvaliad() {
        BDPanAPaaSSDK.sharedInstance().destroyAPaaS {
            DispatchQueue.main.async {
                var item = CloudSettingManager.shared.currentCloudItem!
                item.token = ""
                CloudSettingManager.shared.saveCurrentSetting(item: item)
            }
        }
    }
    
    override func fetchDocumentDetails(completion: (() -> Void)?) {
        if completion != nil {
            self.fetchCompletions.append(completion!)
        }
        
        if self.isRequestingRemote {
            return
        }
        self.isRequestingRemote = true
        
        self.fetchAllDocumentRecursive(curFileList: [],subDirs: [],  path: containerDic, page: 1) { fileList, hasMore, error in
            
            if let err = error as? NSError  {
                if err.code != -9 {
                    completion?()
                    return
                }
            }
            
            
            self.hasGetRemote = true
            self.process(bdCloudFileList: fileList ?? [])
        }
    }
    
    
    
    //递归获取文件夹下的所有文件信息
    func fetchAllDocumentRecursive(curFileList:Array<BDPanCloudFileProtocol>,subDirs:Array<BDPanCloudFileProtocol>, path:String!, page:Int,  completion:@escaping BDPanAPaaSSDKFetchCloudFilesBlock) {
        
        
        BDPanAPaaSCloudFileManager.fetchCloudFileList(withDirPath: path,
                                                      isDesc: true,
                                                      orderType: .byTime,
                                                      page: page,
                                                      filesNum: 1000,
                                                      thumbExpireHour: 1) { fileList, hasMore, error in
            
            var curFiles = curFileList
            curFiles.append(contentsOf: fileList ?? [])
            var curSubDirs = subDirs
            
            for item in fileList ?? [] {
                if item.isdir {
                    curSubDirs.append(item)
                }
            }
            
            
            if let err = error as? NSError  {
                completion(curFiles,hasMore,error)
                return
            }
            
            
            //还有内容，递归下载
            if hasMore {
                self.fetchAllDocumentRecursive(curFileList: curFiles,subDirs:curSubDirs ,  path: path, page: page + 1, completion: completion)
                return
            }
            
            //子文件夹需要遍历 ...
            guard let sub = curSubDirs.first else {
                completion(curFiles,false,nil)
                return
            }
            
            curSubDirs.removeFirst()
            self.fetchAllDocumentRecursive(curFileList: curFiles,subDirs:curSubDirs ,  path: sub.path, page: 1, completion: completion)
            
        }
    }
    
    func process(bdCloudFileList:Array<BDPanCloudFileProtocol>) {
     
        
        hasGetRemote = true
        isRequestingRemote = false
        
        self.detail = nil
        if bdCloudFileList.isEmpty {
            return
        }
        
        
        var itemDic : Dictionary<String,Array<CloudMetadataItem>> = [:]
        var dicArray : Array<CloudMetadataItem> = []
        //获取到数据后重建本地的索引
        
        for item in bdCloudFileList {
            
            let path = item.path
            let type = item.category
            
            //写入Size是否有效?
            let size = item.size
            
            let createTime = item.server_ctime
            let modifyTime = item.server_mtime
            
            var cloudMetaDataItem = CloudMetadataItem.init()
            cloudMetaDataItem.url = rootUrl.appendingPathComponent(path)
            cloudMetaDataItem.name = item.server_filename
            cloudMetaDataItem.createTime = createTime
            cloudMetaDataItem.modifyTime = modifyTime
            cloudMetaDataItem.size = Int(size)
            
            var extroInfoDic = [
                "fid" : "\(item.fid)",
                "fsize" :"\(item.size)"
            ]
            
            var extroData = try? JSONEncoder().encode(extroInfoDic)
            cloudMetaDataItem.extroInfo = extroInfoDic
            
            if type == .photo {
                cloudMetaDataItem.contentType = "public.image"
            }
            
            if item.isdir {
                cloudMetaDataItem.contentType = "public.folder"
            }
            
            if itemDic[cloudMetaDataItem.dictionaryUrl.path] == nil {
                itemDic[cloudMetaDataItem.dictionaryUrl.path] = []
            }
            
            if cloudMetaDataItem.isDictionary {
                dicArray.append(cloudMetaDataItem)
            }else {
                itemDic[cloudMetaDataItem.dictionaryUrl.path]!.append(cloudMetaDataItem)
    
                print("xxxxxxx")
            }
        }
        
        if dicArray.count == 0 {
            DispatchQueue.main.async {
                for com in self.fetchCompletions {
                    com()
                }
                self.fetchCompletions.removeAll()
            }
            return
        }
        
        //排序
        dicArray = dicArray.sorted { item1, item2 in
            return item1.path.count < item2.path.count
        }
        
        var defaultItem = CloudMetadataItem.init()
        defaultItem.url = containerUrl
        defaultItem.contentType = "public.folder"
        dicArray.insert(defaultItem, at: 0)
        //        itemDic[defaultItem.dictionaryUrl] = [defaultItem]
        
        var root = dicArray.removeFirst()
        var unsolveArray : Array<CloudMetadataItem> = [root]
        
        while true {
            guard let currentItem = unsolveArray.first else {
                break
            }
            
            var temp : Array<CloudMetadataItem> = []
            let tempArray = dicArray
            for item in tempArray {
                if item.url.deletingLastPathComponent().path == currentItem.url.path {
                    dicArray.removeAll { metaItem in
                        return metaItem.url == item.url
                    }
                    temp.append(item)
                    unsolveArray.append(item)
                }
            }
            
            temp.append(contentsOf: itemDic[currentItem.url.path] ?? [])
            currentItem.subItems = temp
            _ = unsolveArray.removeFirst()
        }
        
        //处理完成, 赋值，写入本地
        DispatchQueue.main.async {
            self.detail = root
            self.syncDetailToLocal()
            for com in self.fetchCompletions {
                com()
            }
            self.fetchCompletions.removeAll()
        }
    }
    
}
