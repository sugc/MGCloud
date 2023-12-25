//
//  iCloudManager.swift
//  MGCloud
//
//  Created by sugc on 2023/10/13.
//

import Foundation
import CloudKit
import UIKit

//
public class iCloudManager : CloudManager {
    
    var hasInited : Bool = false
    var query : NSMetadataQuery = NSMetadataQuery.init()

    
    public override var cloudType: CloudType {
        return .apple
    }
    
    override init() {
        super.init()
        //监听数据变化和获取
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishGetDocument(notify: )), name: Notification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(documentDidiChange(notify:)), name: .NSMetadataQueryDidUpdate, object: nil)
    }
    
    
    public override func setup(cloudSetting:CloudSettingItem, completion:((_ success : Bool)->Void)?) {
        
        if hasInited {
            completion?(true)
            return
        }
        
        DispatchQueue.global(priority: .low).async {
            self.containerUrl = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.magic.sugc.encryptor")
            print(self.containerUrl)
            if self.containerUrl != nil {
                //获取本地缓存的更新点，避免每次都重复获取
                self.containerUrl = self.containerUrl?.appendingPathComponent("Documents")
                //                 FileManager.default.deleteDictionaryRecursiveAtPath(path: self.containerUrl.absoluteString)
            }
            
            DispatchQueue.main.async {
                self.hasInited = true
                self.setupFromLocal()
                completion?(self.containerUrl != nil)
            }
        }
    }
    
    
    //更新所有数据
    public override func fetchDocumentDetails(completion: (() -> Void)?) {
        
        if completion != nil {
            fetchCompletions.append(completion!)
        }
        
        if isRequestingRemote {
            return
        }
        
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.start()
    }
    
    
    //    - 0 : "kMDItemFSContentChangeDate"
    //    - 1 : "NSMetadataUbiquitousSharedItemOwnerNameComponentsKey"
    //    - 2 : "NSMetadataUbiquitousSharedItemMostRecentEditorNameComponentsKey"
    //    - 3 : "NSMetadataUbiquitousSharedItemLastEditorNameComponentsKey"
    //    - 4 : "NSMetadataUbiquitousItemIsDownloadingKey"
    //    - 5 : "NSMetadataUbiquitousSharedItemRoleKey"
    //    - 6 : "BRMetadataItemFileObjectIdentifierKey"
    //    - 7 : "BRURLTagNamesKey"
    //    - 8 : "NSMetadataUbiquitousSharedItemOwnerNameKey"
    //    - 9 : "NSMetadataUbiquitousSharedItemLastEditorNameKey"
    //    - 10 : "NSMetadataUbiquitousSharedItemCurrentUserRoleKey"
    //    - 11 : "BRMetadataUbiquitousItemUploadingSizeKey"
    //    - 12 : "kMDItemDisplayName"
    //    - 13 : "NSMetadataItemIsUbiquitousKey"
    //    - 14 : "BRModifiedSinceSharedKey"
    //    - 15 : "kMDItemContentTypeTree"
    //    - 16 : "NSMetadataUbiquitousItemPercentUploadedKey"
    //    - 17 : "BRMetadataCreatorNameComponentsKey"
    //    - 18 : "BRMetadataItemParentFileIDKey"
    //    - 19 : "NSMetadataUbiquitousItemContainerDisplayNameKey"
    //    - 20 : "NSMetadataUbiquitousItemIsUploadingKey"
    //    - 21 : "NSMetadataUbiquitousItemDownloadingStatusKey"
    //    - 22 : "BRMetadataIsTopLevelSharedItemKey"
    //    - 23 : "kMDItemFSSize"
    //    - 24 : "NSMetadataItemContainerIdentifierKey"
    //    - 25 : "kMDItemFSName"
    //    - 26 : "NSMetadataUbiquitousItemUploadingErrorKey"
    //    - 27 : "NSMetadataUbiquitousItemIsSharedKey"
    //    - 28 : "NSMetadataUbiquitousItemHasUnresolvedConflictsKey"
    //    - 29 : "kMDItemFSCreationDate"
    //    - 30 : "NSMetadataUbiquitousItemPercentDownloadedKey"
    //    - 31 : "kMDItemPath"
    //    - 32 : "NSMetadataUbiquitousItemIsExternalDocumentKey"
    //    - 33 : "NSMetadataUbiquitousSharedItemPermissionsKey"
    //    - 34 : "NSMetadataUbiquitousItemURLInLocalContainerKey"
    //    - 35 : "NSMetadataUbiquitousItemDownloadingErrorKey"
    //    - 36 : "kMDItemURL"
    //    - 37 : "NSMetadataUbiquitousSharedItemCurrentUserPermissionsKey"
    //    - 38 : "NSMetadataUbiquitousItemIsUploadedKey"
    //    - 39 : "kMDItemContentType"
    //    - 40 : "NSMetadataUbiquitousItemIsDownloadedKey"
    //    - 41 : "NSMetadataUbiquitousItemDownloadRequestedKey"
    //    - 42 : "BRMetadataUbiquitousItemDownloadingSizeKey"
    //获取到全部数据
    @objc func didFinishGetDocument(notify:NSNotification) {
        
        hasGetRemote = true
        isRequestingRemote = false
        
        
        
        self.detail = nil
        guard let query = notify.object as? NSMetadataQuery else {
            return
        }
        
        
        var itemDic : Dictionary<URL,Array<CloudMetadataItem>> = [:]
        var dicArray : Array<CloudMetadataItem> = []
        //获取到数据后重建本地的索引
        query.enumerateResults { item, index, stop in
            
            guard let metaDataItem = item as? NSMetadataItem else {
                return
            }

            guard let fileUrl = metaDataItem.value(forAttribute: NSMetadataItemURLKey) as? URL else {
                return
            }
            guard let fileName = metaDataItem.value(forAttribute: NSMetadataItemFSNameKey) as? String else {
                return
            }
            
            let type = metaDataItem.value(forKey: NSMetadataItemContentTypeKey) as? String
            
            
            //写入Size是否有效?
            let size = metaDataItem.value(forAttribute: NSMetadataItemFSSizeKey) as? Int
            let createTime = metaDataItem.value(forAttribute: NSMetadataItemFSCreationDateKey) as? Date
            let modifyTime = metaDataItem.value(forAttribute: NSMetadataItemFSContentChangeDateKey) as? Date
            
            var cloudMetaDataItem = CloudMetadataItem.init()
            cloudMetaDataItem.url = fileUrl
            cloudMetaDataItem.name = fileName
            cloudMetaDataItem.createTime = createTime
            cloudMetaDataItem.modifyTime = modifyTime
            cloudMetaDataItem.size = size ?? -1
            if type != nil {
                cloudMetaDataItem.contentType = type!
            }
            
            if itemDic[cloudMetaDataItem.dictionaryUrl] == nil {
                itemDic[cloudMetaDataItem.dictionaryUrl] = []
            }
            
            if cloudMetaDataItem.isDictionary {
                dicArray.append(cloudMetaDataItem)
            }else {
                itemDic[cloudMetaDataItem.dictionaryUrl]!.append(cloudMetaDataItem)
                
                let data = try? Data.init(contentsOf: cloudMetaDataItem.url)
                
                let res = FileManager.default.fileExists(atPath: cloudMetaDataItem.url.path)
                
                
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
        
        var root = dicArray.removeFirst()
        var unsolveArray : Array<CloudMetadataItem> = [root]
       
        while true {
            guard let currentItem = unsolveArray.first else {
                break
            }
            
            var temp : Array<CloudMetadataItem> = []
            let tempArray = dicArray
            for item in tempArray {
                if item.url.deletingLastPathComponent() == currentItem.url {
                    dicArray.removeAll { metaItem in
                        return metaItem.url == item.url
                    }
                    temp.append(item)
                    unsolveArray.append(item)
                }
            }
            
            let bal = itemDic[currentItem.url]
            
            temp.append(contentsOf: itemDic[currentItem.url] ?? [])
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
    
    //文件发生变更时
    @objc func documentDidiChange(notify:NSNotification) {
        
        
        print("xxxxxxxxxxxxxxx")
    }
    
    
    public override func isRemoteFileExist(forLocal:URL)->Bool {
        if super.isRemoteFileExist(forLocal: forLocal) {
            return true
        }
        
        let remoteUrl  = self.getRemoteUrl(fromLocalUrl: forLocal)
        do {
            if try  FileManager.default.fileExists(atPath: remoteUrl.path) {
                return true
            }
        }catch {
            
        }
        return false
    }

    
}
